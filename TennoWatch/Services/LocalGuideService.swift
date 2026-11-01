import Foundation
import HuggingFace
import MLXHuggingFace
import MLXLLM
import MLXLMCommon
import Tokenizers

protocol LocalGuideService: Sendable {
    func prepare(progress: @escaping @Sendable (Double) async -> Void) async throws
    func explain(context: String, itemOnly: Bool, update: @escaping @Sendable (String) async -> Void) async throws
}

actor MLXLocalGuideService: LocalGuideService {
    static let modelID = "mlx-community/Qwen3-1.7B-4bit"

    static var isSupported: Bool {
        #if targetEnvironment(simulator) || !arch(arm64)
        false
        #else
        true
        #endif
    }

    private var model: ModelContainer?
    private var isBusy = false

    func prepare(progress: @escaping @Sendable (Double) async -> Void) async throws {
        guard Self.isSupported else { throw GuideError.unsupported }
        guard !isBusy else { throw GuideError.busy }
        guard model == nil else { return }
        isBusy = true
        defer { isBusy = false }
        let loaded = try await #huggingFaceLoadModelContainer(
            configuration: ModelConfiguration(id: Self.modelID),
            progressHandler: { value in
                let fraction = value.fractionCompleted
                Task { await progress(fraction) }
            }
        )
        try Task.checkCancellation()
        model = loaded
    }

    func explain(
        context: String,
        itemOnly: Bool,
        update: @escaping @Sendable (String) async -> Void
    ) async throws {
        guard !isBusy else { throw GuideError.busy }
        guard let model else { throw GuideError.notReady }
        isBusy = true
        defer { isBusy = false }
        let session = ChatSession(
            model,
            instructions: """
            You explain Warframe mastery facts supplied by TennoWatch. Use ONLY the supplied facts.
            Never invent acquisition sources, prerequisites, drop chances, resource ownership, or current availability.
            Missing source data means unknown, not that an item is unavailable. Recommend checking the linked wiki.
            A mastery shortlist is not a verified fastest farming route. The user may lack quest or resource prerequisites.
            Do not add items to the supplied shortlist. Do not assume an unranked item is owned.
            Do not infer difficulty, value, or progression from build cost. Preserve category names exactly.
            A crafting ingredient is not an acquisition source. When the acquisition route is UNKNOWN, say to check the wiki.
            Always name each supplied item explicitly. Never describe a missing source as a known acquisition route.
            Answer concisely in English, under 250 words. Explain gilding when the supplied flag requires it.
            """,
            generateParameters: .init(maxTokens: 450, temperature: 0.7, topP: 0.8, topK: 20),
            additionalContext: ["enable_thinking": false]
        )
        let request = itemOnly
            ? "Explain how to obtain and master this item using the recorded facts. Clearly identify missing acquisition steps."
            : "Write a numbered list in the supplied order. For each item give its exact name, remaining mastery XP, and one verified acquisition step. If no acquisition source is recorded, say to check the wiki. Started items are ranked first, then remaining mastery XP. Do not speculate."
        var response = ""
        for try await chunk in session.streamResponse(to: request + "\n\n" + context) {
            try Task.checkCancellation()
            response += chunk
            await update(response)
        }
        try Task.checkCancellation()
        guard !response.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw GuideError.emptyResponse
        }
    }
}

enum GuideError: Error {
    case unsupported, busy, notReady, emptyResponse
}

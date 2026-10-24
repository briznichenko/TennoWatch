//
//  AppErrorsTests.swift
//  TennoWatchTests
//
//  Created by Andrii Bryzhnychenko on 10/24/26.
//

import Foundation
import SwiftData
import Testing
import WebKit
import UserNotifications
@testable import TennoWatch

@Suite("User-facing errors")
@MainActor
struct AppErrorsTests {
    @Test("Common HTTP failures have actionable messages", arguments: [400, 401, 403, 404, 408, 409, 410, 422, 429, 500, 501, 502, 503, 504, 599, 418])
    func httpMessages(status: Int) {
        let expected: String
        switch status {
        case 400, 422: expected = Strings.Errors.badRequest
        case 401: expected = Strings.Errors.unauthorized
        case 403: expected = Strings.Errors.forbidden
        case 404, 410: expected = Strings.Errors.notFound
        case 408, 504: expected = Strings.Errors.requestTimeout
        case 409: expected = Strings.Errors.conflict
        case 429: expected = Strings.Errors.rateLimited
        case 500...599: expected = Strings.Errors.serviceUnavailable
        default: expected = Strings.Errors.httpFailure
        }
        #expect(AppErrors.message(for: APIError.httpStatus(status)) == expected)
    }

    @Test("Connectivity failures work as Swift and bridged Foundation errors", arguments: [
        URLError.notConnectedToInternet, .dataNotAllowed, .internationalRoamingOff, .callIsActive,
        .networkConnectionLost, .timedOut, .cannotFindHost, .cannotConnectToHost, .dnsLookupFailed,
        .secureConnectionFailed, .serverCertificateHasBadDate, .serverCertificateUntrusted,
        .serverCertificateHasUnknownRoot, .serverCertificateNotYetValid,
        .clientCertificateRejected, .clientCertificateRequired
    ])
    func connectivityMessages(code: URLError.Code) {
        let expected: String
        switch code {
        case .notConnectedToInternet, .dataNotAllowed, .internationalRoamingOff, .callIsActive:
            expected = Strings.Errors.offline
        case .networkConnectionLost: expected = Strings.Errors.connectionLost
        case .timedOut: expected = Strings.Errors.requestTimeout
        case .cannotFindHost, .cannotConnectToHost, .dnsLookupFailed: expected = Strings.Errors.unreachable
        default: expected = Strings.Errors.secureConnection
        }
        #expect(AppErrors.message(for: URLError(code)) == expected)
        #expect(AppErrors.message(for: NSError(domain: NSURLErrorDomain, code: code.rawValue)) == expected)
    }

    @Test("SwiftData failures have a local-data message")
    func swiftDataMessages() {
        for error in [SwiftDataError.loadIssueModelContainer, .modelValidationFailure, .missingModelContext] {
            #expect(AppErrors.message(for: error) == Strings.Errors.database)
        }
    }

    @Test("Core Data validation, store, migration and save errors are recognized", arguments: [1550, 1560, 1570, 1600, 1620, 1670, 1680, 1690, 132000, 133000, 134030, 134060, 134100, 134110])
    func databaseMessages(code: Int) {
        let error = NSError(domain: NSCocoaErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey: "Internal database details"])
        #expect(AppErrors.message(for: error) == Strings.Errors.database)
    }

    @Test("Unrecognized domains and unrelated file errors keep their existing descriptions")
    func unmappedMessages() {
        let errors: [Error] = [
            NSError(domain: NSCocoaErrorDomain, code: NSFileReadNoSuchFileError),
            NSError(domain: "Other", code: 134030)
        ]
        for error in errors {
            #expect(AppErrors.message(for: error) == error.localizedDescription)
        }
    }

    @Test("Invalid links and responses have actionable messages")
    func invalidRequests() {
        #expect(AppErrors.message(for: APIError.invalidResponse) == Strings.Errors.invalidResponse)
        for code in [URLError.badURL, .unsupportedURL] {
            #expect(AppErrors.message(for: URLError(code)) == Strings.Errors.invalidURL)
        }
        for code in [URLError.badServerResponse, .zeroByteResource] {
            #expect(AppErrors.message(for: URLError(code)) == Strings.Errors.invalidResponse)
        }
    }

    @Test("All JSON decoding failure kinds share a readable-data message")
    func decodingErrors() {
        let context = DecodingError.Context(codingPath: [], debugDescription: "Internal payload details")
        let errors: [Error] = [
            DecodingError.dataCorrupted(context), DecodingError.typeMismatch(String.self, context),
            DecodingError.valueNotFound(String.self, context),
            DecodingError.keyNotFound(DecodingKey.value, context)
        ]
        for error in errors {
            #expect(AppErrors.message(for: error) == Strings.Errors.decoding)
        }
        for code in [URLError.cannotDecodeRawData, .cannotDecodeContentData, .cannotParseResponse] {
            #expect(AppErrors.message(for: URLError(code)) == Strings.Errors.decoding)
        }
    }

    @Test("Profile errors distinguish missing saved data from an invalid player ID")
    func profileErrors() {
        #expect(AppErrors.message(for: PersistentProfileRepository.ProfileError.noData) == Strings.Errors.profileNotFound)
        #expect(AppErrors.message(for: PersistentProfileRepository.ProfileError.noPlayerId) == Strings.Errors.playerNotFound)
    }

    @Test("Catalog errors distinguish bundled files, missing data and categories")
    func catalogErrors() {
        #expect(AppErrors.message(for: PersistentCatalogRepository.CatalogError.wrongFilename) == Strings.Errors.catalogFile)
        #expect(AppErrors.message(for: PersistentCatalogRepository.CatalogError.noCatalogAvailable) == Strings.Errors.catalogUnavailable)
        #expect(AppErrors.message(for: PersistentCatalogRepository.CatalogError.wrongCategory) == Strings.Errors.catalogCategory)
    }

    @Test("Notification messages distinguish permission, authorization and scheduling failures")
    func notificationErrors() {
        let underlying = NSError(domain: "NotificationTest", code: 42)
        #expect(AppErrors.message(for: NotificationError.notAllowed) == Strings.Errors.notificationPermission)
        let authorization = NotificationError.authorizationFailed(underlying: underlying)
        #expect(AppErrors.message(for: authorization) == Strings.Errors.notificationAuthorization)
        let scheduling = NotificationError.schedulingFailed(underlying: underlying)
        #expect(AppErrors.message(for: scheduling) == Strings.Errors.notificationScheduling)
        if case .schedulingFailed(let original) = scheduling {
            #expect((original as NSError) === underlying)
        }
        let denied = NSError(domain: UNErrorDomain, code: UNError.Code.notificationsNotAllowed.rawValue)
        #expect(AppErrors.message(for: denied) == Strings.Errors.notificationPermission)
        #expect(AppErrors.message(for: NotificationError.authorizationFailed(underlying: denied)) == Strings.Errors.notificationPermission)
        #expect(AppErrors.message(for: NotificationError.schedulingFailed(underlying: denied)) == Strings.Errors.notificationPermission)
        #expect(AppErrors.message(for: NSError(domain: UNErrorDomain, code: UNError.Code.attachmentInvalidURL.rawValue)) == Strings.Errors.notificationScheduling)
    }

    @Test("Cache configuration failures explain why clearing failed")
    func cacheErrors() {
        #expect(AppErrors.message(for: SettingsViewModel.ClearCacheError.missingBundleIdentifier) == Strings.Errors.cacheConfiguration)
    }

    @Test("A failed database launch retains its error and never creates a replacement store")
    func failedStartup() {
        let failure = NSError(domain: NSCocoaErrorDomain, code: 134100)
        var attempts = 0
        let state = AppStartupState(makeContainer: {
            attempts += 1
            throw failure
        })
        guard case .failed(let error) = state else {
            Issue.record("The app must stay out of the ready state when the database cannot open")
            return
        }
        #expect((error as NSError) === failure)
        #expect(attempts == 1)
    }

    @Test("Successful startup shares its database with app dependencies")
    func successfulStartup() throws {
        let container = try ModelContainer(
            for: ProfileDataModel.self, MasteryCatalogDataModel.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let state = AppStartupState(makeContainer: { container })
        guard case .ready(let openedContainer, let dependencies) = state else {
            Issue.record("A working database must allow normal startup")
            return
        }
        #expect(openedContainer === container)
        let persistence = dependencies.persistencyService as? DefaultPersistencyService
        #expect(persistence?.modelContainer === container)
    }

    @Test("Cancellation stays silent and the queue preserves original failures")
    func errorQueue() {
        let manager = DefaultErrorManager()
        manager.append(CancellationError())
        manager.append(URLError(.cancelled))
        manager.append(NSError(domain: NSURLErrorDomain, code: NSURLErrorCancelled))
        #expect(manager.errorQueue.isEmpty)
        manager.append(APIError.httpStatus(429))
        manager.append(URLError(.notConnectedToInternet))
        #expect(manager.errorQueue.count == 2)
        #expect((manager.currentError as? URLError)?.code == .notConnectedToInternet)
        manager.finishPresentation()
        #expect(AppErrors.message(for: manager.currentError ?? URLError(.unknown)) == Strings.Errors.rateLimited)
        manager.finishPresentation()
        #expect(manager.currentError == nil)
    }

    @Test("Wiki failures use the shared messages and ignore cancelled navigation")
    func wikiErrors() throws {
        let url = try #require(URL(string: "https://example.com"))
        let model = WikiBrowserViewModel(url: url)
        model.webView(model.webView, didFailProvisionalNavigation: nil, withError: URLError(.notConnectedToInternet))
        #expect(model.errorMessage == Strings.Errors.offline)
        model.webView(model.webView, didFail: nil, withError: URLError(.timedOut))
        #expect(model.errorMessage == Strings.Errors.requestTimeout)
        model.webView(model.webView, didFail: nil, withError: URLError(.cancelled))
        #expect(model.errorMessage == Strings.Errors.requestTimeout)
    }
}

private enum DecodingKey: String, CodingKey {
    case value
}

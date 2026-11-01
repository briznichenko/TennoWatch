# Mastery guide

Open Mastery → Mastery guide. The shortlist works without a model or network connection once a profile/catalog is available. Search by item name, filter by category, or restrict to records with a known blueprint price.

A blueprint price does not establish a Market vendor: the upstream field also covers clan research. Vendor information remains unknown unless recorded separately.

The planner excludes mastered/unobtainable entries and known mastery-rank requirements above a synced profile's rank. Unknown requirements remain eligible. It sorts started items first, then remaining mastery XP, with catalog IDs as a deterministic tie-breaker. It does not estimate farming effort or verify quests, owned resources, gilding prerequisites, or current availability. Local profiles have no verified account progress/rank.

Acquisition facts are a compact snapshot of WFCD/warframe-items, keyed by catalog unique name. Missing fields remain unknown. Recorded drops can include vaulted relics and historical events; they are not proof of current availability. The UI links the pinned dataset revision and item wiki, and exposes component sources independently of generated text. WFCD attribution is bundled in Resources/WFCD-LICENSE.txt.

## Local explanations

The optional Qwen3-1.7B 4-bit model is loaded through MLX Swift LM 3.32.3. The user explicitly starts the approximately 1 GB download. Hugging Face's downloader caches weights/tokenizer files for reuse. Once cached, generation is local; cold loads can still involve cache/revision checks by the upstream downloader. Model cache management is separate from the app's profile/catalog cache clearing.

Generation is available on physical arm64 devices; simulator and Intel Mac users retain the deterministic guide. Device-specific latency, peak memory, and answer quality require validation on intended hardware. MLX compilation requires Apple's optional Metal Toolchain. The Hugging Face integration uses a Swift macro; approve the package macro in Xcode, or pass `-skipMacroValidation` for a trusted command-line build.

The model receives at most five candidates, twelve components each, six item sources and four sources per component. It cannot select new candidates or mutate account data. Each explanation uses a fresh session, non-thinking mode, and a 450-token output cap. Instructions constrain it to supplied facts, but do not guarantee factuality; generated content is labelled accordingly. Natural-language filter extraction and free-form chat are not implemented.

The service actor owns the model and prevents overlapping load/generation operations across suspension points. The main-actor observable ViewModel owns presentation. Cancellation closes the MLX stream; request IDs reject late progress/text updates. A new operation may briefly report busy while the previous generation unwinds. Navigation away cancels the operation. The guide's model is released when its ViewModel/service lifetime ends; cached files remain on disk.

## Refreshing acquisition data

Download these JSON files from `https://raw.githubusercontent.com/WFCD/warframe-items/63cf904c903536b9a84c5faa2b851fd690f73d18/data/json/` into a temporary directory:

Primary, Secondary, Melee, Warframes, Archwing, Arch-Gun, Arch-Melee, Pets, Sentinels, SentinelWeapons, Components, Resources, Misc.

Run `python3 Scripts/generate_guide_data.py /path/to/downloaded/files`. The generator joins component names/drop locations by uniqueName and intersects records with the existing mastery catalog. To refresh to a new upstream revision, update the revision/date constants, fetch that revision's files, regenerate, and review changes. This pipeline does not change the mastery catalog or persistence schema.

Existing tests remain the regression check; no new tests were added by request. All 74 tests passed on macOS and iOS simulator during implementation. A native macOS smoke check exercised navigation, search/empty states, model download/load, and generation. Generated answers still need quality evaluation; the first response was generic and prompted stricter per-item instructions. Live model downloads and generated answers are not exercised by the automated suite.

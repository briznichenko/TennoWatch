#if os(macOS)
import SwiftUI

struct MacSettingsView: View {
    @State private var profileViewModel: ProfileViewModel
    @AppStorage(UserDefaultsAccountIDStore.storageKey) private var currentAccountID: String?

    let dependencies: AppDependencies
    let onCacheCleared: () -> Void

    init(dependencies: AppDependencies, onCacheCleared: @escaping () -> Void) {
        self.dependencies = dependencies
        self.onCacheCleared = onCacheCleared
        _profileViewModel = State(initialValue: ProfileViewModel(
            profileRepository: dependencies.profileRepository,
            errorManager: dependencies.errorManager
        ))
    }

    var body: some View {
        SettingsView(
            viewModel: .init(
                persistencyService: dependencies.persistencyService,
                catalogRepository: dependencies.catalogRepository,
                profileRepository: dependencies.profileRepository,
                worldStateRepository: dependencies.worldStateRepository,
                notificationService: dependencies.notificationService,
                voidTraderNotificationScheduler: dependencies.voidTraderNotificationScheduler,
                errorManager: dependencies.errorManager
            ),
            displayName: profileViewModel.displayName,
            onCacheCleared: onCacheCleared
        )
        .frame(width: 520, height: 640)
        .task(id: currentAccountID) {
            await profileViewModel.load()
        }
    }
}
#endif

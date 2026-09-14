//
//  Strings.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/14/26.
//

import Foundation

struct Strings {
    private init() {}

    fileprivate static var currentLocale: Locale {
        AppLanguage.current.locale ?? .current
    }

    struct Main {
        private init() {}
        static var tabWorldState: String { String(localized: "main_tab_world_state_key", defaultValue: "World state", locale: currentLocale) }
        static var tabMastery: String { String(localized: "main_tab_mastery_key", defaultValue: "Mastery", locale: currentLocale) }
        static var tabOpenings: String { String(localized: "main_tab_openings_key", defaultValue: "Openings", locale: currentLocale) }
        static var openingsPlaceholder: String {
            String(localized: "main_openings_placeholder_key", defaultValue: "Openings will be here", locale: currentLocale)
        }
        static var tabProfile: String { String(localized: "main_tab_profile_key", defaultValue: "Profile", locale: currentLocale) }
    }

    struct Invasions {
        private init() {}
        static var title: String { String(localized: "invasions_title_key", defaultValue: "Invasions", locale: currentLocale) }
        static var loading: String { String(localized: "invasions_loading_key", defaultValue: "Loading...", locale: currentLocale) }
    }

    struct Settings {
        private init() {}
        static var themeLabel: String { String(localized: "settings_theme_label_key", defaultValue: "Theme", locale: currentLocale) }
        static var appearanceHeader: String {
            String(localized: "settings_appearance_header_key", defaultValue: "Appearance", locale: currentLocale)
        }
        static var languageHeader: String {
            String(localized: "settings_language_header_key", defaultValue: "Language", locale: currentLocale)
        }
        static var languageLabel: String {
            String(localized: "settings_language_label_key", defaultValue: "Language", locale: currentLocale)
        }
        static var accountLabel: String { String(localized: "settings_account_label_key", defaultValue: "Account", locale: currentLocale) }
        static var accountHeader: String { String(localized: "settings_account_header_key", defaultValue: "Account", locale: currentLocale) }
        static var catalogVersionLabel: String {
            String(localized: "settings_catalog_version_label_key", defaultValue: "Catalog version", locale: currentLocale)
        }
        static var catalogVersionPlaceholder: String {
            String(localized: "settings_catalog_version_placeholder_key", defaultValue: "—", locale: currentLocale)
        }
        static var generatedLabel: String { String(localized: "settings_generated_label_key", defaultValue: "Generated", locale: currentLocale) }
        static var refreshCatalog: String {
            String(localized: "settings_refresh_catalog_key", defaultValue: "Refresh catalog", locale: currentLocale)
        }
        static var catalogHeader: String { String(localized: "settings_catalog_header_key", defaultValue: "Catalog", locale: currentLocale) }
        static var title: String { String(localized: "settings_title_key", defaultValue: "Settings", locale: currentLocale) }
    }

    struct Mastery {
        private init() {}
        static var title: String { String(localized: "mastery_title_key", defaultValue: "Mastery", locale: currentLocale) }
        static var categoriesHeader: String {
            String(localized: "mastery_categories_header_key", defaultValue: "Categories", locale: currentLocale)
        }
        static var sortBy: String { String(localized: "mastery_sort_by_key", defaultValue: "Sort by", locale: currentLocale) }
        static var sortOptionName: String { String(localized: "mastery_sort_option_name_key", defaultValue: "Name", locale: currentLocale) }
        static var sortOptionPointsRemaining: String {
            String(localized: "mastery_sort_option_points_remaining_key", defaultValue: "Points remaining", locale: currentLocale)
        }
        static var filterMissing: String { String(localized: "mastery_filter_missing_key", defaultValue: "Missing", locale: currentLocale) }
        static var filterMastered: String { String(localized: "mastery_filter_mastered_key", defaultValue: "Mastered", locale: currentLocale) }
        static var filterLocked: String { String(localized: "mastery_filter_locked_key", defaultValue: "Locked", locale: currentLocale) }
        static var itemStateMastered: String {
            String(localized: "mastery_item_state_mastered_key", defaultValue: "Mastered", locale: currentLocale)
        }
        static var itemStateUnobtainable: String {
            String(localized: "mastery_item_state_unobtainable_key", defaultValue: "Unobtainable", locale: currentLocale)
        }

        static func rankBadge(_ rank: Int) -> String {
            String(localized: "mastery_rank_format_key", defaultValue: "MR \(rank)", locale: currentLocale)
        }

        static func xpToNextRank(_ xpToNextRank: String, nextRank: Int) -> String {
            String(
                localized: "mastery_xp_to_next_rank_format_key",
                defaultValue: "\(xpToNextRank) XP to MR \(nextRank)",
                locale: currentLocale
            )
        }

        static func itemsLeft(_ count: Int) -> String {
            String(localized: "mastery_items_left_format_key", defaultValue: "\(count) items left", locale: currentLocale)
        }

        static func itemRankProgress(rank: Int, maxRank: Int, pointsRemaining: Int) -> String {
            String(
                localized: "mastery_item_state_rank_progress_format_key",
                defaultValue: "Rank \(rank) / \(maxRank) · +\(pointsRemaining) left",
                locale: currentLocale
            )
        }
    }

    struct Profile {
        private init() {}
        static var id: String { String(localized: "profile_id_key", defaultValue: "Player ID", locale: currentLocale) }
        static var idPlaceholder: String {
            String(localized: "profile_id_placeholder_key", defaultValue: "Enter player ID", locale: currentLocale)
        }
        static var title: String { String(localized: "profile_title_key", defaultValue: "Profile", locale: currentLocale) }
        static var displayNameUnknown: String {
            String(localized: "profile_display_name_unknown_key", defaultValue: "Unknown", locale: currentLocale)
        }
    }

    struct Theme {
        private init() {}
        static var system: String { String(localized: "theme_preference_system_key", defaultValue: "System", locale: currentLocale) }
        static var light: String { String(localized: "theme_preference_light_key", defaultValue: "Light", locale: currentLocale) }
        static var dark: String { String(localized: "theme_preference_dark_key", defaultValue: "Dark", locale: currentLocale) }
    }

    struct Language {
        private init() {}
        static var system: String { String(localized: "language_system_key", defaultValue: "System", locale: currentLocale) }
    }

    struct ErrorAlert {
        private init() {}
        static var title: String { String(localized: "error_alert_title_key", defaultValue: "An Error Occurred", locale: currentLocale) }
        static var okButton: String { String(localized: "error_alert_ok_button_key", defaultValue: "OK", locale: currentLocale) }
    }
}

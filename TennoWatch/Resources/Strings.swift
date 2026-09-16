//
//  Strings.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/14/26.
//

import Foundation

struct Strings {
    private init() {}

    private static var currentBundle: Bundle {
        guard
            let locale = AppLanguage.current.locale,
            let path = Bundle.main.path(forResource: locale.identifier, ofType: "lproj"),
            let bundle = Bundle(path: path)
        else {
            return .main
        }
        return bundle
    }

    fileprivate static func string(_ key: String, _ defaultValue: String) -> String {
        currentBundle.localizedString(forKey: key, value: defaultValue, table: "Localizable")
    }

    struct Main {
        private init() {}
        static var tabWorldState: String { Strings.string("main_tab_world_state_key", "World state") }
        static var tabMastery: String { Strings.string("main_tab_mastery_key", "Mastery") }
        static var tabOpenings: String { Strings.string("main_tab_openings_key", "Openings") }
        static var tabProfile: String { Strings.string("main_tab_profile_key", "Profile") }
    }

    struct WorldState {
        private init() {}
        static var title: String { Strings.string("world_state_title_key", "World state") }
        static var cyclesHeader: String { Strings.string("world_state_cycles_header_key", "Cycles") }
        static var invasionsHeader: String { Strings.string("world_state_invasions_header_key", "Invasions") }
        static var fissuresHeader: String { Strings.string("world_state_fissures_header_key", "Fissures") }
        static var sortieHeader: String { Strings.string("world_state_sortie_header_key", "Sortie") }
        static var archonHuntHeader: String { Strings.string("world_state_archon_hunt_header_key", "Archon hunt") }
        static var nightwaveHeader: String { Strings.string("world_state_nightwave_header_key", "Nightwave") }
        static var voidTraderHeader: String { Strings.string("world_state_void_trader_header_key", "Void trader") }
        static var vaultTraderHeader: String { Strings.string("world_state_vault_trader_header_key", "Prime vault") }
        static var steelPathHeader: String { Strings.string("world_state_steel_path_header_key", "Steel path") }
        static var alertsHeader: String { Strings.string("world_state_alerts_header_key", "Alerts") }
        static var archimedeaHeader: String { Strings.string("world_state_archimedea_header_key", "Archimedea") }
        static var calendarHeader: String { Strings.string("world_state_calendar_header_key", "Calendar") }
        static var expiresIn: String { Strings.string("world_state_expires_in_key", "Expires in") }
        static var inventoryHeader: String { Strings.string("world_state_inventory_header_key", "Inventory") }
        static var currentRewardHeader: String { Strings.string("world_state_current_reward_header_key", "Current reward") }
        static var rotationHeader: String { Strings.string("world_state_rotation_header_key", "Rotation") }
        static var evergreensHeader: String { Strings.string("world_state_evergreens_header_key", "Evergreens") }
        static var incursionHeader: String { Strings.string("world_state_incursion_header_key", "Incursion") }
        static var noActiveIncursion: String { Strings.string("world_state_no_active_incursion_key", "No active incursion") }
        static var cetusCycle: String { Strings.string("world_state_cetus_cycle_key", "Cetus") }
        static var vallisCycle: String { Strings.string("world_state_vallis_cycle_key", "Orb Vallis") }
        static var cambionCycle: String { Strings.string("world_state_cambion_cycle_key", "Cambion Drift") }
        static var zarimanCycle: String { Strings.string("world_state_zariman_cycle_key", "Zariman") }
        static var earthCycle: String { Strings.string("world_state_earth_cycle_key", "Earth") }
        static var cycleDay: String { Strings.string("world_state_cycle_day_key", "Day") }
        static var cycleNight: String { Strings.string("world_state_cycle_night_key", "Night") }
        static var cycleWarm: String { Strings.string("world_state_cycle_warm_key", "Warm") }
        static var cycleCold: String { Strings.string("world_state_cycle_cold_key", "Cold") }
        static var cycleCorpus: String { Strings.string("world_state_cycle_corpus_key", "Corpus") }
        static var cycleGrineer: String { Strings.string("world_state_cycle_grineer_key", "Grineer") }
        static var baroArrivesIn: String { Strings.string("world_state_baro_arrives_in_key", "Arrives in") }
        static var baroDepartsIn: String { Strings.string("world_state_baro_departs_in_key", "Departs in") }

        static func nightwaveChallengesCount(_ count: Int) -> String {
            String(format: Strings.string("world_state_nightwave_challenges_count_format_key", "%lld challenges"), count)
        }

        static func nightwaveStandingAvailable(_ standing: Int) -> String {
            String(format: Strings.string("world_state_nightwave_standing_available_format_key", "+%lld standing"), standing)
        }

        static func missionsCount(_ count: Int) -> String {
            String(format: Strings.string("world_state_missions_count_format_key", "%lld missions"), count)
        }

        static func ducats(_ ducats: Int) -> String {
            String(format: Strings.string("world_state_ducats_format_key", "%lld ducats"), ducats)
        }

        static func credits(_ credits: Int) -> String {
            String(format: Strings.string("world_state_credits_format_key", "%lld credits"), credits)
        }

        static func steelEssence(_ cost: Int) -> String {
            String(format: Strings.string("world_state_steel_essence_format_key", "%lld Steel Essence"), cost)
        }
    }

    struct Settings {
        private init() {}
        static var themeLabel: String { Strings.string("settings_theme_label_key", "Theme") }
        static var appearanceHeader: String { Strings.string("settings_appearance_header_key", "Appearance") }
        static var languageHeader: String { Strings.string("settings_language_header_key", "Language") }
        static var languageLabel: String { Strings.string("settings_language_label_key", "Language") }
        static var accountLabel: String { Strings.string("settings_account_label_key", "Account") }
        static var accountHeader: String { Strings.string("settings_account_header_key", "Account") }
        static var catalogVersionLabel: String { Strings.string("settings_catalog_version_label_key", "Catalog version") }
        static var catalogVersionPlaceholder: String { Strings.string("settings_catalog_version_placeholder_key", "—") }
        static var generatedLabel: String { Strings.string("settings_generated_label_key", "Generated") }
        static var refreshCatalog: String { Strings.string("settings_refresh_catalog_key", "Refresh catalog") }
        static var catalogHeader: String { Strings.string("settings_catalog_header_key", "Catalog") }
        static var title: String { Strings.string("settings_title_key", "Settings") }
    }

    struct Mastery {
        private init() {}
        static var title: String { Strings.string("mastery_title_key", "Mastery") }
        static var categoriesHeader: String { Strings.string("mastery_categories_header_key", "Categories") }
        static var sortBy: String { Strings.string("mastery_sort_by_key", "Sort by") }
        static var sortOptionName: String { Strings.string("mastery_sort_option_name_key", "Name") }
        static var sortOptionPointsRemaining: String { Strings.string("mastery_sort_option_points_remaining_key", "Points remaining") }
        static var filterMissing: String { Strings.string("mastery_filter_missing_key", "Missing") }
        static var filterMastered: String { Strings.string("mastery_filter_mastered_key", "Mastered") }
        static var filterLocked: String { Strings.string("mastery_filter_locked_key", "Locked") }
        static var itemStateMastered: String { Strings.string("mastery_item_state_mastered_key", "Mastered") }
        static var itemStateUnobtainable: String { Strings.string("mastery_item_state_unobtainable_key", "Unobtainable") }

        static func rankBadge(_ rank: Int) -> String {
            String(format: Strings.string("mastery_rank_format_key", "MR %lld"), rank)
        }

        static func xpToNextRank(_ xpToNextRank: String, nextRank: Int) -> String {
            String(format: Strings.string("mastery_xp_to_next_rank_format_key", "%@ XP to MR %lld"), xpToNextRank, nextRank)
        }

        static func itemsLeft(_ count: Int) -> String {
            String(format: Strings.string("mastery_items_left_format_key", "%lld items left"), count)
        }

        static func itemRankProgress(rank: Int, maxRank: Int, pointsRemaining: Int) -> String {
            String(
                format: Strings.string("mastery_item_state_rank_progress_format_key", "Rank %lld / %lld · +%lld left"),
                rank, maxRank, pointsRemaining
            )
        }
    }

    struct Openings {
        private init() {}
        static var title: String { Strings.string("openings_title_key", "Openings") }
        static var timeSensitiveHeader: String { Strings.string("openings_time_sensitive_header_key", "Time-sensitive") }
        static var permanentHeader: String { Strings.string("openings_permanent_header_key", "Permanent") }
        static var emptyTimeSensitive: String { Strings.string("openings_empty_time_sensitive_key", "No time-sensitive openings right now") }
        static var emptyPermanent: String { Strings.string("openings_empty_permanent_key", "No permanent openings right now") }

        static func invasionSource(node: String, faction: String, percent: Int) -> String {
            String(format: Strings.string("openings_invasion_source_format_key", "Invasion · %@ · %@ · %lld%%"), node, faction, percent)
        }

        static func voidTraderSource(location: String, timeLeft: String) -> String {
            String(format: Strings.string("openings_void_trader_source_format_key", "Baro Ki'Teer · %@ · %@"), location, timeLeft)
        }

        static func vaultTraderSource(location: String, timeLeft: String) -> String {
            String(format: Strings.string("openings_vault_trader_source_format_key", "Prime Vault · %@ · %@"), location, timeLeft)
        }
    }

    struct Profile {
        private init() {}
        static var id: String { Strings.string("profile_id_key", "Player ID") }
        static var idPlaceholder: String { Strings.string("profile_id_placeholder_key", "Enter player ID") }
        static var title: String { Strings.string("profile_title_key", "Profile") }
        static var displayNameUnknown: String { Strings.string("profile_display_name_unknown_key", "Unknown") }
        static var accountIdLabel: String { Strings.string("profile_account_id_label_key", "Account ID") }
        static var missionsCompletedLabel: String { Strings.string("profile_missions_completed_label_key", "Missions completed") }
        static var totalKillsLabel: String { Strings.string("profile_total_kills_label_key", "Total kills") }

        static var statsHeader: String { Strings.string("profile_stats_header_key", "Stats") }
        static var intrinsicsRow: String { Strings.string("profile_intrinsics_row_key", "Intrinsics") }
        static var intrinsicsTitle: String { Strings.string("profile_intrinsics_title_key", "Intrinsics") }
        static var railjackIntrinsics: String { Strings.string("profile_railjack_intrinsics_key", "Railjack Intrinsics") }
        static var drifterIntrinsics: String { Strings.string("profile_drifter_intrinsics_key", "Drifter Intrinsics") }

        static var itemsRow: String { Strings.string("profile_items_row_key", "Weapon & Warframe Stats") }
        static var itemsTitle: String { Strings.string("profile_items_title_key", "Weapon & Warframe Stats") }

        static var missionsRow: String { Strings.string("profile_missions_row_key", "Mission History") }
        static var missionsTitle: String { Strings.string("profile_missions_title_key", "Mission History") }

        static var statsRow: String { Strings.string("profile_account_stats_row_key", "Career Stats") }
        static var statsTitle: String { Strings.string("profile_account_stats_title_key", "Career Stats") }
        static var masteryRankLabel: String { Strings.string("profile_mastery_rank_label_key", "Mastery Rank") }

        static var statMeleeKills: String { Strings.string("profile_stat_melee_kills_key", "Melee Kills") }
        static var statDeaths: String { Strings.string("profile_stat_deaths_key", "Deaths") }
        static var statRevives: String { Strings.string("profile_stat_revives_key", "Revives") }
        static var statMissionsCompleted: String { Strings.string("profile_stat_missions_completed_key", "Missions Completed") }
        static var statTimePlayed: String { Strings.string("profile_stat_time_played_key", "Time Played") }
        static var statIncome: String { Strings.string("profile_stat_income_key", "Credits Earned") }
        static var statHealCount: String { Strings.string("profile_stat_heal_count_key", "Heals Given") }
        static var statPickupCount: String { Strings.string("profile_stat_pickup_count_key", "Items Picked Up") }
        static var statFishCaught: String { Strings.string("profile_stat_fish_caught_key", "Fish Caught") }
        static var statDestroyed: String { Strings.string("profile_stat_destroyed_key", "Objects Destroyed") }
        static var statCiphersSolved: String { Strings.string("profile_stat_ciphers_solved_key", "Hacks Solved") }
        static var statCiphersFailed: String { Strings.string("profile_stat_ciphers_failed_key", "Hacks Failed") }

        static var sortBy: String { Strings.string("profile_sort_by_key", "Sort by") }
        static var sortOptionName: String { Strings.string("profile_sort_option_name_key", "Name") }
        static var sortOptionKills: String { Strings.string("profile_sort_option_kills_key", "Kills") }
        static var sortOptionXP: String { Strings.string("profile_sort_option_xp_key", "XP") }
        static var sortOptionCompletes: String { Strings.string("profile_sort_option_completes_key", "Completes") }
        static var searchPlaceholder: String { Strings.string("profile_search_placeholder_key", "Search") }

        static func itemDetailText(kills: Int, headshots: Int, assists: Int) -> String {
            String(format: Strings.string("profile_item_detail_format_key", "%lld kills · %lld headshots · %lld assists"), kills, headshots, assists)
        }

        static func missionTierText(_ tier: Int) -> String {
            String(format: Strings.string("profile_mission_tier_format_key", "Tier %lld"), tier)
        }

        static func completesCount(_ count: Int) -> String {
            String(format: Strings.string("profile_completes_count_format_key", "%lld×"), count)
        }

        static func intrinsicRankText(rank: Int, maxRank: Int) -> String {
            String(format: Strings.string("profile_intrinsic_rank_format_key", "%lld / %lld"), rank, maxRank)
        }
    }

    struct Theme {
        private init() {}
        static var system: String { Strings.string("theme_preference_system_key", "System") }
        static var light: String { Strings.string("theme_preference_light_key", "Light") }
        static var dark: String { Strings.string("theme_preference_dark_key", "Dark") }
    }

    struct Language {
        private init() {}
        static var system: String { Strings.string("language_system_key", "System") }
    }

    struct ErrorAlert {
        private init() {}
        static var title: String { Strings.string("error_alert_title_key", "An Error Occurred") }
        static var okButton: String { Strings.string("error_alert_ok_button_key", "OK") }
    }

    struct Common {
        private init() {}
        static var loading: String { Strings.string("common_loading_key", "Loading") }
    }
}

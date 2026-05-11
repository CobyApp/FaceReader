import Foundation

/// Centralized user-facing copy. Honors `LanguageResolver` (Settings override or system language).
public enum L10n {
    public static var actionShare: String { tr("action_share") }
    public static var anonymousMonster: String { tr("anonymous_monster") }
    public static var appDisplayName: String { tr("app_display_name") }

    public static var btnBackToMeter: String { tr("btn_back_to_meter") }
    public static var btnCancel: String { tr("btn_cancel") }
    public static var btnMonsterExplanation: String { tr("btn_monster_explanation") }
    public static var btnOk: String { tr("btn_ok") }

    public static var faceCartoonNotice: String { tr("face_cartoon_notice") }
    public static var faceMeasurerTitle: String { tr("face_measurer_title") }
    public static var faceRatioIntro: String { tr("face_ratio_intro") }
    public static var faceRatioTip: String { tr("face_ratio_tip") }

    public static var helpDisasterLevelTitle: String { tr("help_disaster_level_title") }

    public static var languageOptionSystem: String { tr("language_option_system") }

    public static var posterDeadOrAlive: String { tr("poster_dead_or_alive") }
    public static var posterWanted: String { tr("poster_wanted") }

    public static var privacyCameraUsage: String { tr("privacy_camera_usage") }
    public static var privacyPhotoLibraryAdd: String { tr("privacy_photo_library_add") }

    public static var resultScreenTitle: String { tr("result_screen_title") }

    public static var settingsDone: String { tr("settings_done") }
    public static var settingsLanguage: String { tr("settings_language") }
    public static var settingsTitle: String { tr("settings_title") }

    public static var toastCaptureFace: String { tr("toast_capture_face") }

    public static func gradeName(for index: Int) -> String {
        switch index {
        case 0: return tr("grade_wolf_name")
        case 1: return tr("grade_tiger_name")
        case 2: return tr("grade_demon_name")
        case 3: return tr("grade_dragon_name")
        case 4: return tr("grade_god_name")
        default: return ""
        }
    }

    public static func gradeInfo(for index: Int) -> String {
        switch index {
        case 0: return tr("grade_wolf_info")
        case 1: return tr("grade_tiger_info")
        case 2: return tr("grade_demon_info")
        case 3: return tr("grade_dragon_info")
        case 4: return tr("grade_god_info")
        default: return ""
        }
    }

    public static func gradeDetail(for index: Int) -> String {
        switch index {
        case 0: return tr("grade_wolf_detail")
        case 1: return tr("grade_tiger_detail")
        case 2: return tr("grade_demon_detail")
        case 3: return tr("grade_dragon_detail")
        case 4: return tr("grade_god_detail")
        default: return ""
        }
    }

    public static func gradeLine(for index: Int) -> String {
        "\(gradeName(for: index)): \(gradeInfo(for: index))"
    }

    // VHS / Kitsch — 일부는 일부러 영문 유지 (VHS 미감의 일부)
    public static var vhsRec: String { tr("vhs_rec") }
    public static var vhsTrackingError: String { tr("vhs_tracking_error") }
    public static var vhsDanger: String { tr("vhs_danger") }
    public static var vhsChSelect: String { tr("vhs_ch_select") }
    public static var vhsReduceEffectsTitle: String { tr("vhs_reduce_effects_title") }
    public static var vhsReduceEffectsFooter: String { tr("vhs_reduce_effects_footer") }

    public static func vhsLevelLabel(_ index: Int) -> String {
        String(format: tr("vhs_level_format"), index + 1)
    }

    public static var nicknameTitle: String { tr("nickname_title") }
    public static var nicknameEditTitle: String { tr("nickname_edit_title") }
    public static var nicknameEditPlaceholder: String { tr("nickname_edit_placeholder") }
    public static var btnLandmarksToggle: String { tr("btn_landmarks_toggle") }

    public static var helpScreenTitle: String { tr("help_screen_title") }
    public static var helpIntroTitle: String { tr("help_intro_title") }
    public static var helpIntroBullet1: String { tr("help_intro_bullet_1") }
    public static var helpIntroBullet2: String { tr("help_intro_bullet_2") }
    public static var helpIntroBullet3: String { tr("help_intro_bullet_3") }
    public static var helpGradesSectionTitle: String { tr("help_grades_section_title") }

    /// Localized “bounty” style score using the active app language’s locale.
    public static func formattedScore(_ value: Int) -> String {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.locale = LanguageResolver.localeForFormatting
        let digits = nf.string(from: NSNumber(value: value)) ?? "\(value)"
        return String(
            format: tr("score_display_format"),
            locale: LanguageResolver.localeForFormatting,
            arguments: [digits] as [CVarArg]
        )
    }

    private static func tr(_ key: String) -> String {
        LanguageResolver.localizedString(key: key)
    }
}

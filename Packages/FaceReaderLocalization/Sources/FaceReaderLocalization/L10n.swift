import Foundation

/// Centralized user-facing copy. Resolves against the FaceReaderLocalization bundle (system language + English fallback).
public enum L10n {
    public static var mainRankingTitle: String { tr("main_ranking_title") }

    public static var termDaily: String { tr("term_daily") }
    public static var termMonthly: String { tr("term_monthly") }
    public static var termYearly: String { tr("term_yearly") }
    public static var termAllTime: String { tr("term_all_time") }

    public static var btnOk: String { tr("btn_ok") }
    public static var btnCancel: String { tr("btn_cancel") }

    public static var emptyRankList: String { tr("empty_rank_list") }
    public static var helpDisasterLevelTitle: String { tr("help_disaster_level_title") }

    public static var nicknameTitle: String { tr("nickname_title") }
    public static var nicknamePlaceholder: String { tr("nickname_placeholder") }
    public static var btnComplete: String { tr("btn_complete") }
    public static var toastNicknameInvalid: String { tr("toast_nickname_invalid") }

    public static func nicknameDecorated(_ name: String) -> String {
        String(
            format: tr("nickname_decorated_format"),
            locale: .current,
            arguments: [name] as [CVarArg]
        )
    }

    public static var actionShare: String { tr("action_share") }
    public static var posterWanted: String { tr("poster_wanted") }
    public static var posterDeadOrAlive: String { tr("poster_dead_or_alive") }
    public static var btnRegisterMonster: String { tr("btn_register_monster") }

    public static var resultScreenTitle: String { tr("result_screen_title") }
    public static var anonymousMonster: String { tr("anonymous_monster") }
    public static var toastRegisterDone: String { tr("toast_register_done") }

    public static var faceRatioIntro: String { tr("face_ratio_intro") }
    public static var faceRatioTip: String { tr("face_ratio_tip") }
    public static var faceCartoonNotice: String { tr("face_cartoon_notice") }
    public static var faceMeasurerTitle: String { tr("face_measurer_title") }
    public static var toastCaptureFace: String { tr("toast_capture_face") }

    public static var btnDeleteMonster: String { tr("btn_delete_monster") }
    public static var monsterPaperTitle: String { tr("monster_paper_title") }
    public static var alertDeleteTitle: String { tr("alert_delete_title") }
    public static var alertDeleteBody: String { tr("alert_delete_body") }

    public static var appDisplayName: String { tr("app_display_name") }

    public static var privacyCameraUsage: String { tr("privacy_camera_usage") }
    public static var privacyPhotoLibraryAdd: String { tr("privacy_photo_library_add") }

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

    public static var rankingTerms: [String] {
        [termDaily, termMonthly, termYearly, termAllTime]
    }

    /// In-app “bounty” style score: localized digit grouping + format string (e.g. "$1,234" in English).
    public static func formattedScore(_ value: Int) -> String {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.locale = .current
        let digits = nf.string(from: NSNumber(value: value)) ?? "\(value)"
        return String(
            format: tr("score_display_format"),
            locale: .current,
            arguments: [digits] as [CVarArg]
        )
    }

    private static func tr(_ key: String) -> String {
        String(localized: String.LocalizationValue(key), bundle: .module)
    }
}

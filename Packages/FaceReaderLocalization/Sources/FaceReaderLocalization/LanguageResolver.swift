import Foundation

/// Resolves which `*.lproj` to use: optional UserDefaults override, otherwise `Locale.preferredLanguages`.
public enum LanguageResolver {
    public static let storageKey = "FaceReader.preferredLanguageCode"

    private static let bundledTags: Set<String> = ["en", "ja", "ko"]

    /// Tags the app ships in `Resources` (override picker + fallbacks).
    public static let supportedOverrideTags: [String] = ["en", "ja", "ko"]

    /// Stored tag (`en` / `ja` / `ko`), or `nil` to follow the system language list.
    public static var storedOverrideTag: String? {
        let raw = UserDefaults.standard.string(forKey: storageKey)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !raw.isEmpty, bundledTags.contains(raw) else { return nil }
        return raw
    }

    /// Persists override. Pass `nil` to clear and follow the system.
    public static func saveOverrideTag(_ tag: String?) {
        if let tag, bundledTags.contains(tag) {
            UserDefaults.standard.set(tag, forKey: storageKey)
        } else {
            UserDefaults.standard.removeObject(forKey: storageKey)
        }
    }

    /// Which `.lproj` folder name to load under the FaceReaderLocalization bundle.
    public static func effectiveResourceTag(preferredLanguages: [String] = Locale.preferredLanguages) -> String {
        if let o = storedOverrideTag { return o }
        return tagFromSystemPreferred(preferredLanguages)
    }

    public static func tagFromSystemPreferred(_ prefs: [String]) -> String {
        for p in prefs {
            let pl = p.lowercased()
            if pl.hasPrefix("ja") { return "ja" }
            if pl.hasPrefix("ko") { return "ko" }
            if pl.hasPrefix("en") { return "en" }
        }
        return "en"
    }

    /// Looks up `key` in `FaceReaderLocalization` resources (override / system / English fallback).
    public static func localizedString(key: String, table: String? = "Localizable") -> String {
        let bundle = Bundle.module
        let tag = effectiveResourceTag()
        if let path = bundle.path(forResource: tag, ofType: "lproj"),
           let locBundle = Bundle(path: path) {
            let value = locBundle.localizedString(forKey: key, value: nil, table: table)
            if value != key { return value }
        }
        if let enPath = bundle.path(forResource: "en", ofType: "lproj"),
           let enBundle = Bundle(path: enPath) {
            return enBundle.localizedString(forKey: key, value: key, table: table)
        }
        return bundle.localizedString(forKey: key, value: key, table: table)
    }

    public static var localeForFormatting: Locale {
        Locale(identifier: effectiveResourceTag())
    }
}

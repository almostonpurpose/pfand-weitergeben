import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case de, en, ar, tr

    var id: String { rawValue }
    var nativeName: String {
        switch self {
        case .de: "Deutsch"
        case .en: "English"
        case .ar: "العربية"
        case .tr: "Türkçe"
        }
    }
    var isRightToLeft: Bool { self == .ar }
}

enum L10n {
    static var language: AppLanguage {
        AppLanguage(rawValue: UserDefaults.standard.string(forKey: "appLanguage") ?? "de") ?? .de
    }

    static var locale: Locale { Locale(identifier: language.rawValue) }

    static func string(_ key: String, _ arguments: CVarArg...) -> String {
        let format = bundle.localizedString(forKey: key, value: key, table: nil)
        return String(format: format, locale: locale, arguments: arguments)
    }

    static func currency(_ value: Double) -> String {
        value.formatted(.currency(code: "EUR").locale(locale))
    }

    private static var bundle: Bundle {
        guard let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj"),
              let localizedBundle = Bundle(path: path) else { return .main }
        return localizedBundle
    }
}


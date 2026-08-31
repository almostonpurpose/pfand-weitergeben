import SwiftUI

@main
struct PfandWeitergebenApp: App {
    @StateObject private var store = DemoOfferStore()
    @AppStorage("appLanguage") private var languageCode = AppLanguage.de.rawValue

    var body: some Scene {
        WindowGroup {
            RootView(store: store)
                .tint(AppTheme.green)
                .environment(\.locale, Locale(identifier: languageCode))
                .environment(\.layoutDirection, AppLanguage(rawValue: languageCode)?.isRightToLeft == true ? .rightToLeft : .leftToRight)
        }
    }
}

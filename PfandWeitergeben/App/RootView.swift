import SwiftUI

struct RootView: View {
    @ObservedObject var store: DemoOfferStore
    @State private var selection: AppTab = .nearby

    var body: some View {
        TabView(selection: $selection) {
            NearbyOffersView(store: store)
                .tabItem { Label("In der Nähe", systemImage: "map.fill") }
                .tag(AppTab.nearby)

            ActivityView(store: store)
                .tabItem { Label("Aktivität", systemImage: "clock.arrow.circlepath") }
                .tag(AppTab.activity)

            CreateOfferView(store: store) { selection = .activity }
                .tabItem { Label("Angebot", systemImage: "plus.circle.fill") }
                .tag(AppTab.create)

            SettingsView(store: store)
                .tabItem { Label("Einstellungen", systemImage: "gearshape") }
                .tag(AppTab.settings)
        }
        .toolbarBackground(AppTheme.ground.opacity(0.96), for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}

private enum AppTab: Hashable { case nearby, activity, create, settings }

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(store: DemoOfferStore())
            .environment(\.locale, Locale(identifier: "de"))
            .previewDisplayName("Deutsch · Standard")
    }
}

import SwiftUI
import MapKit

struct NearbyOffersView: View {
    @ObservedObject var store: DemoOfferStore
    let returnPointProvider: any ReturnPointProviding
    @State private var displayMode: DisplayMode = .map
    @State private var showSupermarkets = false
    @State private var showGlassRecycling = false
    @State private var selectedOfferID: UUID?
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 52.518, longitude: 13.385),
                           span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.24))
    )

    private var openOffers: [Offer] { store.offers.filter { $0.status == .open } }
    private var visibleReturnPoints: [ReturnPoint] {
        returnPointProvider.returnPoints.filter {
            ($0.kind == .supermarket && showSupermarkets) || ($0.kind == .glassRecycling && showGlassRecycling)
        }
    }

    init(store: DemoOfferStore, returnPointProvider: any ReturnPointProviding = BundledBerlinReturnPointProvider()) {
        self.store = store
        self.returnPointProvider = returnPointProvider
    }

    var body: some View {
        NavigationStack {
            ZStack {
                WarmBackground()
                VStack(spacing: 0) {
                    Picker("Darstellung", selection: $displayMode) {
                        Label("Karte", systemImage: "map").tag(DisplayMode.map)
                        Label("Liste", systemImage: "list.bullet").tag(DisplayMode.list)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)

                    LayerControls(showSupermarkets: $showSupermarkets, showGlassRecycling: $showGlassRecycling)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)

                    if showSupermarkets || showGlassRecycling {
                        MapLegend(
                            showSupermarkets: showSupermarkets,
                            showGlassRecycling: showGlassRecycling,
                            attribution: returnPointProvider.attribution,
                            sourceURL: returnPointProvider.sourceURL
                        )
                            .padding(.horizontal, 16)
                            .padding(.bottom, 8)
                    }

                    if displayMode == .map { mapContent } else { listContent }
                }
            }
            .navigationTitle("Pfand in deiner Nähe")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedOfferID) { id in
                OfferDetailView(store: store, offerID: id)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    private var mapContent: some View {
        Map(position: $position) {
            ForEach(openOffers) { offer in
                Annotation(L10n.string("offer.bottle_count_plain", offer.bottleCount), coordinate: offer.meetingPoint.coordinate) {
                    Button { selectedOfferID = offer.id } label: {
                        VStack(spacing: 3) {
                            Image(systemName: "waterbottle.fill")
                            Text("\(offer.bottleCount)")
                                .font(.caption.bold())
                        }
                        .foregroundStyle(.white)
                        .frame(width: 50, height: 50)
                        .background(AppTheme.green, in: Circle())
                        .overlay(Circle().stroke(.white, lineWidth: 3))
                        .shadow(color: .black.opacity(0.18), radius: 6, y: 3)
                    }
                    .accessibilityLabel(L10n.string("map.offer_accessibility", offer.bottleCount, offer.meetingPoint.neighbourhood))
                }
            }
            ForEach(visibleReturnPoints) { point in
                Annotation(point.displayName, coordinate: point.coordinate) {
                    Image(systemName: point.kind.symbol)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(point.kind.mapColor, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white, lineWidth: 2))
                        .accessibilityLabel(L10n.string("return.map_accessibility", point.kind.title, point.displayName, point.displayArea))
                        .accessibilityHint(Text(point.evidence.note))
                }
            }
        }
        .mapStyle(.standard(pointsOfInterest: .excludingAll))
        .overlay(alignment: .bottom) {
            VStack(spacing: 7) {
                Text("Standorte sind absichtlich ungefähr")
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(.ultraThinMaterial, in: Capsule())
                if let nearest = openOffers.first {
                    Button { selectedOfferID = nearest.id } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(L10n.string("offer.nearest_summary", nearest.bottleCount, nearest.distanceText))
                                    .font(.headline)
                                Text(L10n.string("offer.keep_deposit_approx", L10n.currency(nearest.estimatedDeposit)))
                                    .font(.subheadline)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .foregroundStyle(AppTheme.ink)
                        .cardStyle()
                    }
                }
            }
            .padding()
        }
    }

    private var listContent: some View {
        ScrollView {
            LazyVStack(spacing: 13) {
                HStack {
                    CareHeading(title: "Verfügbare Angebote", note: "im angezeigten Berliner Gebiet")
                    Spacer()
                }
                .padding(.bottom, 5)
                ForEach(openOffers) { offer in
                    Button { selectedOfferID = offer.id } label: { OfferCard(offer: offer) }
                        .buttonStyle(.plain)
                }

                if !visibleReturnPoints.isEmpty {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Rückgabestellen in Berlin")
                            .font(.title3.weight(.medium))
                            .foregroundStyle(AppTheme.ink)
                        Text("OpenStreetMap-Daten; nicht vollständig und ohne Echtzeit-Öffnungszeiten.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Text(verbatim: returnPointProvider.attribution)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        if let sourceURL = returnPointProvider.sourceURL {
                            Link("Quelle & Lizenz", destination: sourceURL)
                                .font(.caption.weight(.semibold))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 12)

                    ForEach(visibleReturnPoints) { point in
                        ReturnPointCard(point: point)
                    }
                }
            }
            .padding(16)
        }
    }
}

private enum DisplayMode: Hashable { case map, list }

private struct LayerControls: View {
    @Binding var showSupermarkets: Bool
    @Binding var showGlassRecycling: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Optionale Kartenebenen").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
            HStack(spacing: 8) {
                LayerButton(kind: .supermarket, isOn: $showSupermarkets)
                LayerButton(kind: .glassRecycling, isOn: $showGlassRecycling)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct LayerButton: View {
    let kind: ReturnPointKind
    @Binding var isOn: Bool

    var body: some View {
        Button { isOn.toggle() } label: {
            Label(kind.title, systemImage: isOn ? "checkmark.circle.fill" : kind.symbol)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 9)
                .foregroundStyle(isOn ? .white : kind.mapColor)
                .background(isOn ? kind.mapColor : kind.mapColor.opacity(0.10), in: Capsule())
        }
        .accessibilityValue(isOn ? Text("Eingeblendet") : Text("Ausgeblendet"))
    }
}

private struct MapLegend: View {
    let showSupermarkets: Bool
    let showGlassRecycling: Bool
    let attribution: String
    let sourceURL: URL?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 12) {
                Text("Legende · offene Daten").font(.caption.weight(.semibold))
                if showSupermarkets { LegendItem(kind: .supermarket) }
                if showGlassRecycling { LegendItem(kind: .glassRecycling) }
                Spacer()
            }
            Text(verbatim: attribution)
                .font(.caption2)
                .foregroundStyle(.secondary)
            if let sourceURL {
                Link("Quelle & Lizenz", destination: sourceURL)
                    .font(.caption2.weight(.semibold))
            }
        }
        .accessibilityElement(children: .combine)
    }
}

private struct LegendItem: View {
    let kind: ReturnPointKind
    var body: some View {
        Label(kind.title, systemImage: kind.symbol)
            .font(.caption)
            .foregroundStyle(kind.mapColor)
    }
}

private struct ReturnPointCard: View {
    let point: ReturnPoint
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: point.kind.symbol)
                .foregroundStyle(.white)
                .frame(width: 38, height: 38)
                .background(point.kind.mapColor, in: RoundedRectangle(cornerRadius: 11))
            VStack(alignment: .leading, spacing: 4) {
                Text(verbatim: point.displayName).font(.headline)
                Text(verbatim: "\(point.kind.title) · \(point.displayArea)").font(.subheadline).foregroundStyle(.secondary)
                Text(verbatim: point.evidence.note)
                    .font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .cardStyle()
        .accessibilityElement(children: .combine)
    }
}

private extension ReturnPointKind {
    var mapColor: Color {
        switch self {
        case .supermarket: AppTheme.coral
        case .glassRecycling: Color(red: 0.20, green: 0.43, blue: 0.68)
        }
    }
}

extension UUID: @retroactive Identifiable {
    public var id: UUID { self }
}

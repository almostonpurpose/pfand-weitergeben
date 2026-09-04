import SwiftUI

struct OfferCard: View {
    let offer: Offer

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack(alignment: .top) {
                Image(systemName: offer.bagSize.symbol)
                    .font(.title2)
                    .foregroundStyle(AppTheme.green)
                    .frame(width: 42, height: 42)
                    .background(AppTheme.sageTint, in: Circle())
                VStack(alignment: .leading, spacing: 3) {
                    Text(L10n.string("offer.bottle_count", offer.bottleCount))
                        .font(.headline)
                        .foregroundStyle(AppTheme.ink)
                    Text(offer.bagSize.title)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.secondaryInk)
                }
                Spacer()
                Text(offer.distanceText)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(AppTheme.sageTint, in: Capsule())
            }

            Label(offer.pickupTimeText, systemImage: "clock")
            Label(L10n.string("offer.approximate_location", offer.meetingPoint.neighbourhood), systemImage: "mappin.and.ellipse")
            Label(offer.handoverMethod.title, systemImage: offer.handoverMethod.symbol)

            HStack {
                Text("Du behältst das Pfand")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.green)
                Spacer()
                Text(L10n.currency(offer.estimatedDeposit))
                    .font(.headline)
                    .foregroundStyle(AppTheme.ink)
            }
        }
        .font(.subheadline)
        .foregroundStyle(AppTheme.secondaryInk)
        .cardStyle()
        .accessibilityElement(children: .combine)
        .accessibilityLabel(L10n.string("offer.accessibility", offer.bottleCount, offer.distanceText, offer.pickupTimeText, L10n.currency(offer.estimatedDeposit)))
    }
}

struct StatusPill: View {
    let status: OfferStatus

    var body: some View {
        Text(status.title)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .foregroundStyle(status == .cancelled ? .secondary : AppTheme.darkGreen)
            .background(status == .cancelled ? Color.secondary.opacity(0.12) : AppTheme.sageTint, in: Capsule())
    }
}

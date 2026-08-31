import SwiftUI

enum AppTheme {
    // Adapted from DesignDealer's “the next small thing” system.
    static let ground = Color(red: 0.980, green: 0.910, blue: 0.835)
    static let groundRecessed = Color(red: 0.953, green: 0.855, blue: 0.753)
    static let ink = Color(red: 0.176, green: 0.125, blue: 0.094)
    static let secondaryInk = Color(red: 0.353, green: 0.271, blue: 0.212)
    static let coral = Color(red: 0.910, green: 0.490, blue: 0.373)
    static let sage = Color(red: 0.569, green: 0.647, blue: 0.514)
    static let sageTint = Color(red: 0.867, green: 0.922, blue: 0.831)
    static let green = Color(red: 0.18, green: 0.42, blue: 0.27)
    static let darkGreen = Color(red: 0.08, green: 0.25, blue: 0.15)
    static let mint = sageTint
    static let amber = Color(red: 0.96, green: 0.62, blue: 0.18)
}

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(Color.white.opacity(0.67), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(.primary.opacity(0.07), lineWidth: 1)
            }
    }
}

extension View {
    func cardStyle() -> some View { modifier(CardModifier()) }
}

struct CareHeading: View {
    let title: String
    let note: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(LocalizedStringKey(title))
                .font(.system(.title2, design: .rounded, weight: .medium))
                .foregroundStyle(AppTheme.ink)
            CareBracket()
                .stroke(AppTheme.sage, style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                .frame(width: 180, height: 13)
            Text(LocalizedStringKey(note))
                .font(.system(.caption, design: .rounded).italic())
                .foregroundStyle(AppTheme.sage)
                .padding(.leading, 50)
        }
        .accessibilityElement(children: .combine)
    }
}

struct CareBracket: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let middle = rect.midX
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addCurve(to: CGPoint(x: middle - 8, y: rect.midY),
                      control1: CGPoint(x: rect.minX + 3, y: rect.midY),
                      control2: CGPoint(x: middle - 16, y: rect.midY))
        path.addCurve(to: CGPoint(x: middle, y: rect.maxY),
                      control1: CGPoint(x: middle - 3, y: rect.midY),
                      control2: CGPoint(x: middle, y: rect.maxY - 3))
        path.addCurve(to: CGPoint(x: middle + 8, y: rect.midY),
                      control1: CGPoint(x: middle, y: rect.maxY - 3),
                      control2: CGPoint(x: middle + 3, y: rect.midY))
        path.addCurve(to: CGPoint(x: rect.maxX, y: rect.minY),
                      control1: CGPoint(x: middle + 16, y: rect.midY),
                      control2: CGPoint(x: rect.maxX - 3, y: rect.midY))
        return path
    }
}

struct WarmBackground: View {
    var body: some View {
        AppTheme.ground.ignoresSafeArea()
    }
}

struct PrimaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .foregroundStyle(.white)
            .background(configuration.isPressed ? AppTheme.darkGreen : AppTheme.green,
                        in: Capsule())
    }
}

//
//  LiquidGlass.swift
//  NotitApp
//
import SwiftUI

extension Color {
    init(hex: UInt, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

enum LiquidGlass {
    static let backgroundBase = Color(hex: 0xF2F2F7)
    static let systemBlue = Color(hex: 0x007AFF)
    static let systemGreen = Color(hex: 0x34C759)
    static let systemPurple = Color(hex: 0xAF52DE)
    static let systemRed = Color(hex: 0xFF3B30)
    static let systemOrange = Color(hex: 0xFF9500)

    /// The app's one brand accent — active tabs, "+" buttons, "Guardar".
    /// Deliberately separate from the five system colors above, which are
    /// reserved for category identity (dots, badges, chips).
    static let primary = systemGreen

    // Fixed (non-adaptive) text tokens. The whole design is light-only —
    // adaptive `.secondary`/`.tertiary` resolve to light-on-dark colors
    // under system Dark Mode, which is unreadable against this always-light
    // background. These read the same regardless of the system appearance.
    static let ink = Color(hex: 0x1C1C1E)
    static let inkSecondary = Color(hex: 0x3C3C43, opacity: 0.6)
    static let inkTertiary = Color(hex: 0x3C3C43, opacity: 0.35)
}

/// The four soft, blurred color blobs behind every screen in the design.
struct GlassBackdrop: View {
    struct Blob {
        enum Corner { case topLeading, topTrailing, bottomLeading, bottomTrailing }
        let color: Color
        let size: CGFloat
        let blur: CGFloat
        let opacity: Double
        let corner: Corner
        let inset: CGPoint
    }

    let blobs: [Blob]

    var body: some View {
        ZStack {
            LiquidGlass.backgroundBase
            GeometryReader { geo in
                ForEach(Array(blobs.enumerated()), id: \.offset) { _, blob in
                    Circle()
                        .fill(blob.color)
                        .frame(width: blob.size, height: blob.size)
                        .blur(radius: blob.blur)
                        .opacity(blob.opacity)
                        .position(position(for: blob, in: geo.size))
                }
            }
        }
        .ignoresSafeArea()
    }

    private func position(for blob: Blob, in size: CGSize) -> CGPoint {
        switch blob.corner {
        case .topLeading: CGPoint(x: blob.inset.x, y: blob.inset.y)
        case .topTrailing: CGPoint(x: size.width - blob.inset.x, y: blob.inset.y)
        case .bottomLeading: CGPoint(x: blob.inset.x, y: size.height - blob.inset.y)
        case .bottomTrailing: CGPoint(x: size.width - blob.inset.x, y: size.height - blob.inset.y)
        }
    }
}

private struct GlassSurface: ViewModifier {
    var cornerRadius: CGFloat
    var borderOpacity: Double = 0.6

    func body(content: Content) -> some View {
        content
            // A plain, always-translucent white tint sits between the material
            // and the content. Unlike Material, it isn't affected by the
            // system's Reduce Transparency setting, so the card still reads
            // as a soft glass panel (not flat gray) even when Material itself
            // is forced opaque by that accessibility setting.
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.white.opacity(0.16))
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(.white.opacity(borderOpacity), lineWidth: 1)
            )
            // Flattens the view into one layer before the shadow is applied.
            // Without it, List rows (which do their own extra compositing)
            // render the background, border and content as separate shadowed
            // layers — a smeared, doubled-looking shadow instead of one
            // clean soft edge.
            .compositingGroup()
            .shadow(color: .black.opacity(0.07), radius: 16, x: 0, y: 8)
    }
}

private struct GlassCircle: ViewModifier {
    var diameter: CGFloat = 40

    func body(content: Content) -> some View {
        content
            .frame(width: diameter, height: diameter)
            .background(
                Circle()
                    .fill(.white.opacity(0.16))
                    .background(.ultraThinMaterial, in: Circle())
            )
            .overlay(Circle().strokeBorder(.white.opacity(0.7), lineWidth: 1))
            .compositingGroup()
            .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
    }
}

extension View {
    func glassSurface(cornerRadius: CGFloat = 24, borderOpacity: Double = 0.6) -> some View {
        modifier(GlassSurface(cornerRadius: cornerRadius, borderOpacity: borderOpacity))
    }

    func glassCircle(diameter: CGFloat = 40) -> some View {
        modifier(GlassCircle(diameter: diameter))
    }
}

/// The gradient capsule "Guardar" button used on both Add screens.
struct GradientPillButtonStyle: ButtonStyle {
    let tint: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 8)
            .background(
                LinearGradient(colors: [tint.opacity(0.85), tint], startPoint: .topLeading, endPoint: .bottomTrailing),
                in: Capsule()
            )
            .shadow(color: tint.opacity(0.35), radius: 12, x: 0, y: 6)
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

extension Date {
    /// "Hace 2 horas" / "2 hours ago", "Ayer" / "Yesterday", etc. — follows
    /// the app's current language instead of a fixed one. Dates within a few
    /// seconds of now are handled explicitly — right at that boundary,
    /// RelativeDateTimeFormatter can round to the future side ("in 0 seconds")
    /// instead of past.
    var relativeDescription: String {
        guard abs(timeIntervalSinceNow) >= 5 else {
            return String(localized: "Recién")
        }
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.unitsStyle = .full
        let text = formatter.localizedString(for: self, relativeTo: .now)
        return text.prefix(1).uppercased() + text.dropFirst()
    }
}

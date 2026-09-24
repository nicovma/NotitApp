//
//  AISuggestionBanner.swift
//  NotitApp
//
import SwiftUI

/// Tells the user why they aren't seeing AI suggestions on this device,
/// instead of the feature silently seeming to not exist.
struct SuggestionUnavailableHint: View {
    let reason: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "sparkles")
                .font(.system(size: 12))
            Text(reason)
                .font(.system(size: 12))
        }
        .foregroundStyle(LiquidGlass.inkTertiary)
    }
}

/// Shows the AI-generated title/category suggestion as editable chips —
/// nothing here is applied automatically, the user taps to accept each one.
struct SuggestionBanner: View {
    let isSuggesting: Bool
    let suggestion: NoteSuggestion?
    let isNewCategory: Bool
    let onUseTitle: () -> Void
    let onUseCategory: () -> Void
    let onRequestAnother: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.system(size: 12, weight: .bold))
                Text("SUGERENCIA")
                    .font(.system(size: 12, weight: .bold))
                    .tracking(0.5)

                Spacer()

                if suggestion != nil, !isSuggesting {
                    Button(action: onRequestAnother) {
                        Label("Otra sugerencia", systemImage: "arrow.clockwise")
                            .labelStyle(.iconOnly)
                            .font(.system(size: 12, weight: .bold))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Text("Otra sugerencia"))
                }
            }
            .foregroundStyle(LiquidGlass.systemPurple)

            if isSuggesting {
                HStack(spacing: 8) {
                    ProgressView()
                    Text("Pensando un título y categoría...")
                        .font(.system(size: 13))
                        .foregroundStyle(LiquidGlass.inkSecondary)
                }
            } else if let suggestion {
                VStack(alignment: .leading, spacing: 10) {
                    SuggestionRow(label: "Título") {
                        Button(action: onUseTitle) {
                            Label(suggestion.title, systemImage: "textformat")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .buttonStyle(SuggestionChipStyle())
                    }

                    SuggestionRow(label: "Categoría") {
                        Button(action: onUseCategory) {
                            Label(
                                isNewCategory ? String(format: String(localized: "Crear \"%@\""), suggestion.categoryName) : suggestion.categoryName,
                                systemImage: isNewCategory ? "plus.circle" : "checkmark.circle"
                            )
                            .font(.system(size: 13, weight: .semibold))
                        }
                        .buttonStyle(SuggestionChipStyle())
                    }
                }
            }
        }
        .padding(14)
        .glassSurface(cornerRadius: 16)
    }
}

/// Labels each suggestion chip with what it is ("Título" / "Categoría") so
/// the two don't read as interchangeable options.
private struct SuggestionRow<Content: View>: View {
    let label: String
    @ViewBuilder let content: Content

    var body: some View {
        HStack(spacing: 10) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .bold))
                .tracking(0.3)
                .foregroundStyle(LiquidGlass.inkTertiary)
                .fixedSize()
                .frame(width: 80, alignment: .leading)
            content
        }
    }
}

private struct SuggestionChipStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(LiquidGlass.systemPurple)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(LiquidGlass.systemPurple.opacity(configuration.isPressed ? 0.24 : 0.14), in: Capsule())
    }
}

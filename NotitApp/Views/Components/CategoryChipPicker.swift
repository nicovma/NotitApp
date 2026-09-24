//
//  CategoryChipPicker.swift
//  NotitApp
//
import SwiftUI

/// Blocks the note from being saved without one by replacing the chip
/// picker with a direct path to create the first category, instead of
/// just disabling "Guardar" with no way out.
struct NoCategoriesPrompt: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 16))
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Todavía no tenés categorías")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Creá una para poder guardar la nota")
                        .font(.system(size: 12))
                        .foregroundStyle(LiquidGlass.inkSecondary)
                }
                Spacer()
            }
            .foregroundStyle(LiquidGlass.primary)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .glassSurface(cornerRadius: 16)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
    }
}

struct CategoryChip: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        let color = CategoryColor(rawValue: category.color)?.swiftUIColor ?? .gray

        Button(action: action) {
            HStack(spacing: 6) {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                } else {
                    Circle().fill(color).frame(width: 7, height: 7)
                }
                Text(category.name)
                    .font(.system(size: 13, weight: isSelected ? .bold : .semibold))
            }
            .foregroundStyle(color)
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(color.opacity(0.14), in: Capsule())
            .overlay(
                Capsule().strokeBorder(color, lineWidth: isSelected ? 2 : 0)
            )
        }
        .buttonStyle(.plain)
        // The dot/checkmark is purely decorative (redundant with the
        // selection trait below) — combine collapses it into the chip's
        // single VoiceOver stop instead of announcing an unlabeled shape.
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

/// Always-present alongside the existing category chips, so creating a new
/// category doesn't require emptying the list first.
struct AddCategoryChip: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(LiquidGlass.inkSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(LiquidGlass.inkSecondary.opacity(0.12), in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

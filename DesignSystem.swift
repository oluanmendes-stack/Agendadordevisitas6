// DesignSystem.swift
// Tokens visuais que espelham o protótipo React

import SwiftUI

// MARK: - Cores

extension Color {
    static let appBackground = Color(red: 0.949, green: 0.949, blue: 0.969)
    static let cardBackground = Color.white
    static let cardHoje = Color(red: 1.0, green: 0.969, blue: 0.941)
    static let cardPassado = Color(red: 0.976, green: 0.976, blue: 0.976)

    static let brandBlue = Color(red: 0.0, green: 0.478, blue: 1.0)
    static let brandOrange = Color(red: 1.0, green: 0.420, blue: 0.0)
    static let brandGreen = Color(red: 0.204, green: 0.780, blue: 0.349)
    static let brandRed = Color(red: 1.0, green: 0.231, blue: 0.188)
    static let brandYellow = Color(red: 1.0, green: 0.584, blue: 0.0)

    static let label = Color(red: 0.110, green: 0.110, blue: 0.118)
    static let secondaryLabel = Color(red: 0.557, green: 0.557, blue: 0.576)
    static let tertiaryLabel = Color(red: 0.922, green: 0.922, blue: 0.961)
    static let separator = Color(red: 0.941, green: 0.941, blue: 0.941)
    static let inputBackground = Color(red: 0.980, green: 0.980, blue: 0.980)
    static let pillBackground = Color(red: 0.949, green: 0.949, blue: 0.969)

    static let borderHoje = Color(red: 1.0, green: 0.420, blue: 0.0).opacity(0.35)
    static let borderDefault = Color(red: 0.922, green: 0.922, blue: 0.922)
}

// MARK: - Raios de cantos

enum Radius {
    static let card: CGFloat = 18
    static let action: CGFloat = 10
    static let input: CGFloat = 10
    static let sheet: CGFloat = 22
    static let pill: CGFloat = 20
    static let icon: CGFloat = 12
    static let toggle: CGFloat = 15
}

// MARK: - Sombras

struct CardShadow: ViewModifier {
    var isHoje: Bool
    func body(content: Content) -> some View {
        content.shadow(
            color: isHoje ? Color.brandOrange.opacity(0.10) : Color.black.opacity(0.05),
            radius: isHoje ? 8 : 4,
            x: 0,
            y: 2
        )
    }
}

extension View {
    func cardShadow(isHoje: Bool = false) -> some View {
        modifier(CardShadow(isHoje: isHoje))
    }
}

import SwiftUI
import AppKit

/// テーマ選択（標準・ダーク・コックピット）
final class ThemeStore: ObservableObject {
    static let shared = ThemeStore()

    enum Theme: String, CaseIterable {
        case system
        case dark
        case cockpit

        var displayName: String {
            switch self {
            case .system: return "標準"
            case .dark: return "ダーク"
            case .cockpit: return "コックピット"
            }
        }
    }

    @Published var current: Theme {
        didSet { UserDefaults.standard.set(current.rawValue, forKey: "clippad.theme") }
    }

    private init() {
        let raw = UserDefaults.standard.string(forKey: "clippad.theme") ?? Theme.system.rawValue
        self.current = Theme(rawValue: raw) ?? .system
    }

    var headerBackground: Color {
        switch current {
        case .system: return Color(nsColor: .windowBackgroundColor)
        case .dark: return Color(red: 0.15, green: 0.15, blue: 0.17)
        case .cockpit: return Color(red: 0.06, green: 0.08, blue: 0.06)
        }
    }

    var listBackground: Color {
        switch current {
        case .system: return Color(nsColor: .textBackgroundColor)
        case .dark: return Color(red: 0.11, green: 0.11, blue: 0.13)
        case .cockpit: return Color(red: 0.02, green: 0.04, blue: 0.02)
        }
    }

    var textSecondary: Color {
        switch current {
        case .system: return Color.secondary
        case .dark: return Color.white.opacity(0.9)
        case .cockpit: return Color(red: 0.6, green: 0.9, blue: 0.5)
        }
    }

    var textTertiary: Color {
        switch current {
        case .system: return Color.secondary.opacity(0.8)
        case .dark: return Color.white.opacity(0.6)
        case .cockpit: return Color(red: 0.4, green: 0.7, blue: 0.3)
        }
    }

    var dividerColor: Color {
        switch current {
        case .system: return Color(nsColor: .separatorColor)
        case .dark: return Color.white.opacity(0.2)
        case .cockpit: return Color(red: 0.2, green: 0.5, blue: 0.15)
        }
    }

    var accentColor: Color {
        switch current {
        case .system: return Color.accentColor
        case .dark: return Color(red: 0.4, green: 0.7, blue: 1.0)
        case .cockpit: return Color(red: 0.9, green: 0.85, blue: 0.3)
        }
    }

    var rowTextColor: Color {
        switch current {
        case .system: return Color.primary
        case .dark: return Color.white.opacity(0.95)
        case .cockpit: return Color(red: 0.7, green: 0.95, blue: 0.6)
        }
    }

    var rowFont: Font {
        switch current {
        case .system, .dark: return .system(.body, design: .default)
        case .cockpit: return .system(.body, design: .monospaced)
        }
    }
}

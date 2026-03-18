import SwiftUI
import AppKit

/// テーマ選択（標準・ダーク・コックピット・パステル系）
final class ThemeStore: ObservableObject {
    static let shared = ThemeStore()

    enum Theme: String, CaseIterable {
        case system
        case dark
        case cockpit
        case pastelPink
        case pastelLavender
        case pastelMint
        case pastelPeach

        var displayName: String {
            switch self {
            case .system: return "標準"
            case .dark: return "ダーク"
            case .cockpit: return "コックピット"
            case .pastelPink: return "パステルピンク"
            case .pastelLavender: return "パステルラベンダー"
            case .pastelMint: return "パステルミント"
            case .pastelPeach: return "パステルピーチ"
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
        case .pastelPink: return Color(red: 1.0, green: 0.93, blue: 0.95)
        case .pastelLavender: return Color(red: 0.95, green: 0.93, blue: 1.0)
        case .pastelMint: return Color(red: 0.92, green: 0.98, blue: 0.96)
        case .pastelPeach: return Color(red: 1.0, green: 0.96, blue: 0.93)
        }
    }

    var listBackground: Color {
        switch current {
        case .system: return Color(nsColor: .textBackgroundColor)
        case .dark: return Color(red: 0.11, green: 0.11, blue: 0.13)
        case .cockpit: return Color(red: 0.02, green: 0.04, blue: 0.02)
        case .pastelPink: return Color(red: 1.0, green: 0.97, blue: 0.98)
        case .pastelLavender: return Color(red: 0.98, green: 0.97, blue: 1.0)
        case .pastelMint: return Color(red: 0.96, green: 0.99, blue: 0.98)
        case .pastelPeach: return Color(red: 1.0, green: 0.98, blue: 0.97)
        }
    }

    var textSecondary: Color {
        switch current {
        case .system: return Color.secondary
        case .dark: return Color.white.opacity(0.9)
        case .cockpit: return Color(red: 0.6, green: 0.9, blue: 0.5)
        case .pastelPink: return Color(red: 0.55, green: 0.35, blue: 0.4)
        case .pastelLavender: return Color(red: 0.4, green: 0.35, blue: 0.55)
        case .pastelMint: return Color(red: 0.3, green: 0.5, blue: 0.45)
        case .pastelPeach: return Color(red: 0.55, green: 0.4, blue: 0.35)
        }
    }

    var textTertiary: Color {
        switch current {
        case .system: return Color.secondary.opacity(0.8)
        case .dark: return Color.white.opacity(0.6)
        case .cockpit: return Color(red: 0.4, green: 0.7, blue: 0.3)
        case .pastelPink: return Color(red: 0.65, green: 0.5, blue: 0.55)
        case .pastelLavender: return Color(red: 0.5, green: 0.45, blue: 0.65)
        case .pastelMint: return Color(red: 0.4, green: 0.6, blue: 0.55)
        case .pastelPeach: return Color(red: 0.65, green: 0.5, blue: 0.45)
        }
    }

    var dividerColor: Color {
        switch current {
        case .system: return Color(nsColor: .separatorColor)
        case .dark: return Color.white.opacity(0.2)
        case .cockpit: return Color(red: 0.2, green: 0.5, blue: 0.15)
        case .pastelPink: return Color(red: 0.95, green: 0.85, blue: 0.88)
        case .pastelLavender: return Color(red: 0.88, green: 0.85, blue: 0.95)
        case .pastelMint: return Color(red: 0.85, green: 0.95, blue: 0.92)
        case .pastelPeach: return Color(red: 0.98, green: 0.9, blue: 0.85)
        }
    }

    var accentColor: Color {
        switch current {
        case .system: return Color.accentColor
        case .dark: return Color(red: 0.4, green: 0.7, blue: 1.0)
        case .cockpit: return Color(red: 0.9, green: 0.85, blue: 0.3)
        case .pastelPink: return Color(red: 0.9, green: 0.5, blue: 0.6)
        case .pastelLavender: return Color(red: 0.6, green: 0.5, blue: 0.85)
        case .pastelMint: return Color(red: 0.4, green: 0.75, blue: 0.65)
        case .pastelPeach: return Color(red: 0.95, green: 0.65, blue: 0.5)
        }
    }

    var rowTextColor: Color {
        switch current {
        case .system: return Color.primary
        case .dark: return Color.white.opacity(0.95)
        case .cockpit: return Color(red: 0.7, green: 0.95, blue: 0.6)
        case .pastelPink: return Color(red: 0.45, green: 0.35, blue: 0.4)
        case .pastelLavender: return Color(red: 0.35, green: 0.32, blue: 0.5)
        case .pastelMint: return Color(red: 0.28, green: 0.45, blue: 0.4)
        case .pastelPeach: return Color(red: 0.48, green: 0.38, blue: 0.35)
        }
    }

    var rowFont: Font {
        switch current {
        case .system, .dark, .pastelPink, .pastelLavender, .pastelMint, .pastelPeach:
            return .system(.body, design: .default)
        case .cockpit: return .system(.body, design: .monospaced)
        }
    }
}

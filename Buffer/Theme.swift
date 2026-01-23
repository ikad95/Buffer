import Defaults
import SwiftUI

enum Theme: String, CaseIterable, Identifiable, CustomStringConvertible, Defaults.Serializable {
  case `default`
  case monokai
  case dracula
  case oneDark
  case nord
  case solarized

  var id: String { rawValue }

  var description: String {
    switch self {
    case .default:
      return String(localized: "ThemeDefault", table: "AppearanceSettings")
    case .monokai:
      return String(localized: "ThemeMonokai", table: "AppearanceSettings")
    case .dracula:
      return String(localized: "ThemeDracula", table: "AppearanceSettings")
    case .oneDark:
      return String(localized: "ThemeOneDark", table: "AppearanceSettings")
    case .nord:
      return String(localized: "ThemeNord", table: "AppearanceSettings")
    case .solarized:
      return String(localized: "ThemeSolarized", table: "AppearanceSettings")
    }
  }

  var selectionColor: Color {
    switch self {
    case .default:
      return Color.accentColor
    case .monokai:
      return Color(red: 249/255, green: 38/255, blue: 114/255) // #F92672
    case .dracula:
      return Color(red: 189/255, green: 147/255, blue: 249/255) // #BD93F9
    case .oneDark:
      return Color(red: 97/255, green: 175/255, blue: 239/255) // #61AFEF
    case .nord:
      return Color(red: 136/255, green: 192/255, blue: 208/255) // #88C0D0
    case .solarized:
      return Color(red: 38/255, green: 139/255, blue: 210/255) // #268BD2
    }
  }

  var selectionTextColor: Color {
    .white
  }

  var searchFieldTint: Color {
    switch self {
    case .default:
      return Color.secondary
    case .monokai:
      return Color(red: 249/255, green: 38/255, blue: 114/255)
    case .dracula:
      return Color(red: 189/255, green: 147/255, blue: 249/255)
    case .oneDark:
      return Color(red: 97/255, green: 175/255, blue: 239/255)
    case .nord:
      return Color(red: 136/255, green: 192/255, blue: 208/255)
    case .solarized:
      return Color(red: 38/255, green: 139/255, blue: 210/255)
    }
  }
}

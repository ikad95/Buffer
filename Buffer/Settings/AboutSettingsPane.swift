import SwiftUI
import Settings

struct AboutSettingsPane: View {
  private var appVersion: String {
    Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
  }

  private var buildNumber: String {
    Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
  }

  var body: some View {
    Settings.Container(contentWidth: 450) {
      Settings.Section(title: "") {
        VStack(spacing: 16) {
          if let appIcon = NSApp.applicationIconImage {
            Image(nsImage: appIcon)
              .resizable()
              .frame(width: 96, height: 96)
          }

          Text("Buffer")
            .font(.title)
            .fontWeight(.bold)

          Text("Version \(appVersion) (\(buildNumber))")
            .foregroundStyle(.secondary)

          Divider()
            .padding(.vertical, 8)

          Text("Developed by")
            .foregroundStyle(.secondary)
            .font(.subheadline)

          Text("Moulik Adak")
            .font(.title2)
            .fontWeight(.medium)

          Spacer()
            .frame(height: 16)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
      }
    }
  }
}

#Preview {
  AboutSettingsPane()
}

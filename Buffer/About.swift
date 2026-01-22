import Cocoa

class About {
  private var credits: NSMutableAttributedString {
    let credits = NSMutableAttributedString(
      string: "A lightweight clipboard manager for macOS.\nBased on Buffer (MIT License).",
      attributes: [NSAttributedString.Key.foregroundColor: NSColor.labelColor]
    )
    credits.setAlignment(.center, range: NSRange(location: 0, length: credits.length))
    return credits
  }

  @objc
  func openAbout(_ sender: NSMenuItem?) {
    NSApp.activate(ignoringOtherApps: true)
    NSApp.orderFrontStandardAboutPanel(options: [NSApplication.AboutPanelOptionKey.credits: credits])
  }
}

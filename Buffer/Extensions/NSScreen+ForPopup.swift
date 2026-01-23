import AppKit.NSScreen
import AppKit.NSEvent
import Defaults

extension NSScreen {
  static var forPopup: NSScreen? {
    let desiredScreen = Defaults[.popupScreen]
    if desiredScreen == 0 || desiredScreen > NSScreen.screens.count {
      return NSScreen.main
    } else {
      return NSScreen.screens[desiredScreen - 1]
    }
  }

  /// Returns the screen that contains the current cursor position
  static var screenContainingCursor: NSScreen? {
    let cursorLocation = NSEvent.mouseLocation
    return NSScreen.screens.first { screen in
      screen.frame.contains(cursorLocation)
    }
  }
}

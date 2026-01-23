import AppKit.NSEvent
import Defaults
import Foundation

enum PopupPosition: String, CaseIterable, Identifiable, CustomStringConvertible, Defaults.Serializable {
  case cursor
  case statusItem
  case window
  case center
  case lastPosition

  var id: Self { self }

  var description: String {
    switch self {
    case .cursor:
      return NSLocalizedString("PopupAtCursor", tableName: "AppearanceSettings", comment: "")
    case .statusItem:
      return NSLocalizedString("PopupAtMenuBarIcon", tableName: "AppearanceSettings", comment: "")
    case .window:
      return NSLocalizedString("PopupAtWindowCenter", tableName: "AppearanceSettings", comment: "")
    case .center:
      return NSLocalizedString("PopupAtScreenCenter", tableName: "AppearanceSettings", comment: "")
    case .lastPosition:
      return NSLocalizedString("PopupAtLastPosition", tableName: "AppearanceSettings", comment: "")
    }
  }

  // swiftlint:disable:next cyclomatic_complexity function_body_length
  func origin(size: NSSize, statusBarButton: NSStatusBarButton?) -> NSPoint {
    let cursorPosition = NSEvent.mouseLocation
    let screen = NSScreen.screenContainingCursor ?? NSScreen.main

    switch self {
    case .center:
      if let frame = NSScreen.forPopup?.visibleFrame {
        return constrainToScreen(NSRect.centered(ofSize: size, in: frame).origin, size: size, screen: screen)
      }
    case .window:
      if let frame = NSWorkspace.shared.frontmostApplication?.windowFrame {
        return constrainToScreen(NSRect.centered(ofSize: size, in: frame).origin, size: size, screen: screen)
      }
    case .statusItem:
      if let statusBarButton, let buttonScreen = NSScreen.main {
        let rectInWindow = statusBarButton.convert(statusBarButton.bounds, to: nil)
        if let screenRect = statusBarButton.window?.convertToScreen(rectInWindow) {
          var topLeftPoint = NSPoint(x: screenRect.minX, y: screenRect.minY - size.height)
          // Ensure popup doesn't spill over screen edges
          topLeftPoint = constrainToScreen(topLeftPoint, size: size, screen: buttonScreen)
          return topLeftPoint
        }
      }
    case .lastPosition:
      if let frame = NSScreen.forPopup?.visibleFrame {
        let relativePos = Defaults[.windowPosition]
        let anchorX = frame.minX + frame.width * relativePos.x
        let anchorY = frame.minY + frame.height * relativePos.y
        // Anchor is top middle of frame
        let point = NSPoint(x: anchorX - size.width / 2, y: anchorY - size.height)
        return constrainToScreen(point, size: size, screen: screen)
      }
    case .cursor:
      break
    }

    // Default: position at cursor with intelligent boundary handling
    return positionAtCursor(cursorPosition: cursorPosition, size: size, screen: screen)
  }

  /// Position popup near cursor with top-left corner at cursor position
  private func positionAtCursor(cursorPosition: NSPoint, size: NSSize, screen: NSScreen?) -> NSPoint {
    guard let visibleFrame = screen?.visibleFrame else {
      // Fallback: top-left corner at cursor
      return NSPoint(x: cursorPosition.x, y: cursorPosition.y - size.height)
    }

    var point = cursorPosition

    // Vertical positioning: top of popup at cursor Y (popup extends downward)
    point.y = cursorPosition.y - size.height

    // Horizontal positioning: left edge at cursor X
    point.x = cursorPosition.x

    return constrainToScreen(point, size: size, screen: screen)
  }

  /// Constrain a point so the popup stays within the visible screen bounds
  private func constrainToScreen(_ point: NSPoint, size: NSSize, screen: NSScreen?) -> NSPoint {
    guard let visibleFrame = screen?.visibleFrame else {
      return point
    }

    var constrainedPoint = point

    // Constrain horizontal position
    if constrainedPoint.x + size.width > visibleFrame.maxX {
      constrainedPoint.x = visibleFrame.maxX - size.width
    }
    if constrainedPoint.x < visibleFrame.minX {
      constrainedPoint.x = visibleFrame.minX
    }

    // Constrain vertical position
    if constrainedPoint.y < visibleFrame.minY {
      constrainedPoint.y = visibleFrame.minY
    }
    if constrainedPoint.y + size.height > visibleFrame.maxY {
      constrainedPoint.y = visibleFrame.maxY - size.height
    }

    return constrainedPoint
  }
}

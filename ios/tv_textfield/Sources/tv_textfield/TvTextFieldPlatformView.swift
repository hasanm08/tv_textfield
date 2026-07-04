import Flutter
import UIKit

class TvTextFieldViewFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    return TvTextFieldPlatformView(
      frame: frame,
      viewId: viewId,
      args: args as? [String: Any],
      messenger: messenger
    )
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    return FlutterStandardMessageCodec.sharedInstance()
  }
}

class TvTextFieldPlatformView: NSObject, FlutterPlatformView, UITextFieldDelegate {
  private let textField = UITextField(frame: .zero)
  private let channel: FlutterMethodChannel
  private var params: [String: Any]

  init(
    frame: CGRect,
    viewId: Int64,
    args: [String: Any]?,
    messenger: FlutterBinaryMessenger
  ) {
    channel = FlutterMethodChannel(
      name: "tv_textfield/edit_text_\(viewId)",
      binaryMessenger: messenger
    )
    params = args ?? [:]
    super.init()
    textField.frame = frame
    textField.delegate = self
    textField.borderStyle = .none
    textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    applyParams()
    channel.setMethodCallHandler(handle)
  }

  func view() -> UIView {
    return textField
  }

  private func applyParams() {
    textField.text = params["text"] as? String ?? ""
    textField.placeholder = params["hint"] as? String
    textField.isEnabled = params["enabled"] as? Bool ?? true
    textField.isSecureTextEntry = params["obscureText"] as? Bool ?? false
    textField.textAlignment = mapTextAlign(params["textAlign"] as? String)
    if let colorValue = params["textColor"] as? Int {
      textField.textColor = UIColor(argb: colorValue)
    } else {
      textField.textColor = .label
    }
    textField.returnKeyType = mapReturnKey(params["textInputAction"] as? String)
    textField.keyboardType = mapKeyboardType(params["keyboardType"] as? String)
    if params["autofocus"] as? Bool == true {
      textField.becomeFirstResponder()
    }
  }

  private func mapTextAlign(_ name: String?) -> NSTextAlignment {
    switch name {
    case "center": return .center
    case "right", "end": return .right
    default: return .left
    }
  }

  private func mapReturnKey(_ name: String?) -> UIReturnKeyType {
    switch name {
    case "done": return .done
    case "go": return .go
    case "next": return .next
    case "search": return .search
    case "send": return .send
    default: return .default
    }
  }

  private func mapKeyboardType(_ name: String?) -> UIKeyboardType {
    switch name {
    case "number": return .numberPad
    case "phone": return .phonePad
    case "emailAddress": return .emailAddress
    case "url": return .URL
    case "visiblePassword": return .asciiCapable
    case "multiline": return .default
    default: return .default
    }
  }

  @objc private func textDidChange() {
    channel.invokeMethod("onTextChanged", arguments: textField.text ?? "")
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "setText":
      let text = call.arguments as? String ?? ""
      if textField.text != text {
        textField.text = text
      }
      result(nil)
    case "setFocused":
      let focused = call.arguments as? Bool ?? false
      if focused {
        textField.becomeFirstResponder()
      } else {
        textField.resignFirstResponder()
      }
      result(nil)
    case "update":
      if let updated = call.arguments as? [String: Any] {
        params = updated
        applyParams()
      }
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  func textFieldDidBeginEditing(_ textField: UITextField) {
    channel.invokeMethod("onFocusChanged", arguments: true)
  }

  func textFieldDidEndEditing(_ textField: UITextField) {
    channel.invokeMethod("onFocusChanged", arguments: false)
  }

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    channel.invokeMethod("onSubmitted", arguments: textField.text ?? "")
    textField.resignFirstResponder()
    return true
  }
}

private extension UIColor {
  convenience init(argb: Int) {
    let alpha = CGFloat((argb >> 24) & 0xFF) / 255.0
    let red = CGFloat((argb >> 16) & 0xFF) / 255.0
    let green = CGFloat((argb >> 8) & 0xFF) / 255.0
    let blue = CGFloat(argb & 0xFF) / 255.0
    self.init(red: red, green: green, blue: blue, alpha: alpha)
  }
}

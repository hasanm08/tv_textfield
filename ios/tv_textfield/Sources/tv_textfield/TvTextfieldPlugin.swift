import Flutter
import UIKit

public class TvTextfieldPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let factory = TvTextFieldViewFactory(messenger: registrar.messenger())
    registrar.register(factory, withId: "tv_textfield/edit_text")

    let channel = FlutterMethodChannel(
      name: "tv_textfield/platform",
      binaryMessenger: registrar.messenger()
    )
    let instance = TvTextfieldPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformInfo":
      #if os(tvOS)
      result([
        "isAndroidTv": false,
        "isTvOS": true,
        "isTelevision": true,
      ])
      #else
      result([
        "isAndroidTv": false,
        "isTvOS": false,
        "isTelevision": false,
      ])
      #endif
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

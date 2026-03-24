import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Register Vision OCR platform channel
    let controller = window?.rootViewController as! FlutterViewController
    let ocrChannel = FlutterMethodChannel(
      name: "com.rra94.ayu/vision_ocr",
      binaryMessenger: controller.binaryMessenger
    )
    ocrChannel.setMethodCallHandler { (call, result) in
      if call.method == "recognizeText" {
        guard let args = call.arguments as? [String: Any],
              let imagePath = args["imagePath"] as? String else {
          result(FlutterError(code: "INVALID_ARGS", message: "Missing imagePath", details: nil))
          return
        }
        VisionOCR.recognizeText(from: imagePath) { text in
          DispatchQueue.main.async {
            result(text)
          }
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    try! setExcludeFromiCloudBackup(isExcluded: true)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

private func setExcludeFromiCloudBackup(isExcluded: Bool) throws {
    var fileOrDirectoryURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    var values = URLResourceValues()
    values.isExcludedFromBackup = isExcluded
    try fileOrDirectoryURL.setResourceValues(values)
}

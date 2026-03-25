import UIKit
import Flutter
import Vision
import CoreMotion
import CoreLocation

@main
@objc class AppDelegate: FlutterAppDelegate, CLLocationManagerDelegate {

  private var locationManager: CLLocationManager?
  private var locationChannel: FlutterMethodChannel?
  private var lastKnownLocation: CLLocation?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    let controller = window?.rootViewController as! FlutterViewController

    // ── Vision OCR channel ─────────────────────────────────────────────────
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
        self.recognizeText(from: imagePath) { text in
          DispatchQueue.main.async {
            result(text)
          }
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    // ── CoreMotion channel ─────────────────────────────────────────────────
    let motionChannel = FlutterMethodChannel(
      name: "com.rra94.ayu/core_motion",
      binaryMessenger: controller.binaryMessenger
    )
    motionChannel.setMethodCallHandler { (call, result) in
      if call.method == "getActivityType" {
        self.getActivityType(result: result)
      } else if call.method == "getStationaryDuration" {
        self.getStationaryDuration(result: result)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    // ── CoreLocation channel ───────────────────────────────────────────────
    let locChannel = FlutterMethodChannel(
      name: "com.rra94.ayu/core_location",
      binaryMessenger: controller.binaryMessenger
    )
    self.locationChannel = locChannel
    locChannel.setMethodCallHandler { (call, result) in
      if call.method == "startSignificantLocationMonitoring" {
        self.startSignificantLocationMonitoring(result: result)
      } else if call.method == "getLastKnownLocation" {
        if let loc = self.lastKnownLocation {
          result(["lat": loc.coordinate.latitude, "lon": loc.coordinate.longitude])
        } else {
          result(nil)
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    // ── Barometer channel ──────────────────────────────────────────────────
    let barometerChannel = FlutterMethodChannel(
      name: "com.rra94.ayu/barometer",
      binaryMessenger: controller.binaryMessenger
    )
    barometerChannel.setMethodCallHandler { (call, result) in
      if call.method == "readPressure" {
        self.readPressure(result: result)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    try! setExcludeFromiCloudBackup(isExcluded: true)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // MARK: - Vision OCR

  private func recognizeText(from imagePath: String, completion: @escaping (String?) -> Void) {
    guard let image = UIImage(contentsOfFile: imagePath),
          let cgImage = image.cgImage else {
      completion(nil)
      return
    }

    let request = VNRecognizeTextRequest { (request, error) in
      guard error == nil,
            let observations = request.results as? [VNRecognizedTextObservation] else {
        completion(nil)
        return
      }
      let text = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
      completion(text)
    }
    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = true

    DispatchQueue.global(qos: .userInitiated).async {
      do {
        try VNImageRequestHandler(cgImage: cgImage, options: [:]).perform([request])
      } catch {
        completion(nil)
      }
    }
  }

  // MARK: - CoreMotion helpers

  private func getActivityType(result: @escaping FlutterResult) {
    guard CMMotionActivityManager.isActivityAvailable() else {
      result("unknown")
      return
    }
    let manager = CMMotionActivityManager()
    let now = Date()
    let start = now.addingTimeInterval(-60)
    manager.queryActivityStarting(from: start, to: now, to: .main) { activities, error in
      guard error == nil, let activities = activities, !activities.isEmpty else {
        result("unknown")
        return
      }
      let latest = activities.last!
      let activityType: String
      if latest.stationary {
        activityType = "stationary"
      } else if latest.walking {
        activityType = "walking"
      } else if latest.running {
        activityType = "running"
      } else if latest.cycling {
        activityType = "cycling"
      } else if latest.automotive {
        activityType = "automotive"
      } else {
        activityType = "unknown"
      }
      DispatchQueue.main.async {
        result(activityType)
      }
    }
  }

  private func getStationaryDuration(result: @escaping FlutterResult) {
    guard CMMotionActivityManager.isActivityAvailable() else {
      result(0)
      return
    }
    let manager = CMMotionActivityManager()
    let now = Date()
    let start = now.addingTimeInterval(-12 * 3600)
    manager.queryActivityStarting(from: start, to: now, to: .main) { activities, error in
      guard error == nil, let activities = activities, !activities.isEmpty else {
        result(0)
        return
      }
      // Walk backwards to find the most recent non-stationary activity
      var lastNonStationaryDate: Date? = nil
      for activity in activities.reversed() {
        if !activity.stationary {
          lastNonStationaryDate = activity.startDate
          break
        }
      }
      let minutes: Int
      if let lastActive = lastNonStationaryDate {
        minutes = Int(now.timeIntervalSince(lastActive) / 60)
      } else {
        // All stationary for the whole window — return full 12 hours
        minutes = 12 * 60
      }
      DispatchQueue.main.async {
        result(minutes)
      }
    }
  }

  // MARK: - CoreLocation helpers

  private func startSignificantLocationMonitoring(result: @escaping FlutterResult) {
    let mgr = CLLocationManager()
    mgr.delegate = self
    self.locationManager = mgr
    mgr.requestWhenInUseAuthorization()
    mgr.startMonitoringSignificantLocationChanges()
    result("started")
  }

  // CLLocationManagerDelegate
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let loc = locations.last else { return }
    self.lastKnownLocation = loc
    locationChannel?.invokeMethod("onLocationUpdate", arguments: [
      "lat": loc.coordinate.latitude,
      "lon": loc.coordinate.longitude
    ])
  }

  // MARK: - Barometer helpers

  private func readPressure(result: @escaping FlutterResult) {
    guard CMAltimeter.isRelativeAltitudeAvailable() else {
      result(nil)
      return
    }
    let altimeter = CMAltimeter()
    var didReturn = false
    altimeter.startRelativeAltitudeUpdates(to: .main) { data, error in
      guard !didReturn else { return }
      didReturn = true
      altimeter.stopRelativeAltitudeUpdates()
      if let pressure = data?.pressure {
        result(pressure.doubleValue)
      } else {
        result(nil)
      }
    }
  }
}

private func setExcludeFromiCloudBackup(isExcluded: Bool) throws {
    var fileOrDirectoryURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    var values = URLResourceValues()
    values.isExcludedFromBackup = isExcluded
    try fileOrDirectoryURL.setResourceValues(values)
}

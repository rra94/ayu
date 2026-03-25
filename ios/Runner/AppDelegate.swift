import UIKit
import Flutter
import Vision
import CoreMotion
import CoreLocation
import EventKit
import MapKit
import UserNotifications
import Intents

@main
@objc class AppDelegate: FlutterAppDelegate, CLLocationManagerDelegate {

  private var locationManager: CLLocationManager?
  private var locationChannel: FlutterMethodChannel?
  private var lastKnownLocation: CLLocation?
  private var notificationActionChannel: FlutterMethodChannel?

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
      } else if call.method == "identifyCurrentPlace" {
        guard let loc = self.lastKnownLocation else {
          result(nil)
          return
        }
        self.identifyPlace(lat: loc.coordinate.latitude, lon: loc.coordinate.longitude) { place in
          DispatchQueue.main.async { result(place) }
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    // ── EventKit Calendar channel ────────────────────────────────────────
    let calendarChannel = FlutterMethodChannel(
      name: "com.rra94.ayu/calendar",
      binaryMessenger: controller.binaryMessenger
    )
    calendarChannel.setMethodCallHandler { (call, result) in
      if call.method == "getTodayEvents" {
        self.getTodayEvents(result: result)
      } else if call.method == "createRecurringEvent" {
        guard let args = call.arguments as? [String: Any],
              let title = args["title"] as? String,
              let hourMinute = args["hourMinute"] as? Int,
              let frequency = args["frequency"] as? String else {
          result(FlutterError(code: "INVALID_ARGS", message: "Missing args", details: nil))
          return
        }
        let days = args["days"] as? [Int] // for weekly: [1,3,5] = Mon,Wed,Fri
        self.createRecurringEvent(title: title, hourMinute: hourMinute, frequency: frequency, days: days, result: result)
      } else if call.method == "deleteEvent" {
        guard let args = call.arguments as? [String: Any],
              let eventId = args["eventId"] as? String else {
          result(FlutterError(code: "INVALID_ARGS", message: "Missing eventId", details: nil))
          return
        }
        self.deleteCalendarEvent(eventId: eventId, result: result)
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

    // MARK: - Notification Categories with Actions
    let waterCategory = UNNotificationCategory(
        identifier: "WATER_REMINDER",
        actions: [
            UNNotificationAction(identifier: "WATER_250", title: "+250ml", options: []),
            UNNotificationAction(identifier: "WATER_500", title: "+500ml", options: []),
            UNNotificationAction(identifier: "WATER_SKIP", title: "Skip", options: [.destructive]),
        ],
        intentIdentifiers: [],
        options: []
    )

    let supplementCategory = UNNotificationCategory(
        identifier: "SUPPLEMENT_REMINDER",
        actions: [
            UNNotificationAction(identifier: "SUPPS_ALL_TAKEN", title: "All Taken ✓", options: []),
            UNNotificationAction(identifier: "SUPPS_OPEN", title: "Open App", options: [.foreground]),
        ],
        intentIdentifiers: [],
        options: []
    )

    let fastCategory = UNNotificationCategory(
        identifier: "FAST_REMINDER",
        actions: [
            UNNotificationAction(identifier: "FAST_START_16", title: "Start 16:8", options: []),
            UNNotificationAction(identifier: "FAST_SKIP", title: "Not Tonight", options: [.destructive]),
        ],
        intentIdentifiers: [],
        options: []
    )

    let mealCategory = UNNotificationCategory(
        identifier: "MEAL_REMINDER",
        actions: [
            UNNotificationAction(identifier: "MEAL_PHOTO", title: "Photo Meal", options: [.foreground]),
            UNNotificationAction(identifier: "MEAL_SEARCH", title: "Search", options: [.foreground]),
            UNNotificationAction(identifier: "MEAL_SKIP", title: "Skip", options: [.destructive]),
        ],
        intentIdentifiers: [],
        options: []
    )

    let energyCategory = UNNotificationCategory(
        identifier: "ENERGY_CHECK",
        actions: [
            UNNotificationAction(identifier: "ENERGY_1", title: "1 😴", options: []),
            UNNotificationAction(identifier: "ENERGY_2", title: "2", options: []),
            UNNotificationAction(identifier: "ENERGY_3", title: "3 😐", options: []),
            UNNotificationAction(identifier: "ENERGY_4", title: "4", options: []),
            UNNotificationAction(identifier: "ENERGY_5", title: "5 ⚡", options: []),
        ],
        intentIdentifiers: [],
        options: []
    )

    UNUserNotificationCenter.current().setNotificationCategories([
        waterCategory, supplementCategory, fastCategory, mealCategory, energyCategory
    ])
    UNUserNotificationCenter.current().delegate = self

    // ── Notification Actions channel ─────────────────────────────────────
    let notifChannel = FlutterMethodChannel(
        name: "com.rra94.ayu/notification_actions",
        binaryMessenger: controller.binaryMessenger
    )
    self.notificationActionChannel = notifChannel

    // ── Siri Intent Donations channel ────────────────────────────────────
    let intentChannel = FlutterMethodChannel(
        name: "com.rra94.ayu/intents",
        binaryMessenger: controller.binaryMessenger
    )
    intentChannel.setMethodCallHandler { (call, result) in
        if call.method == "donate" {
            guard let args = call.arguments as? [String: Any],
                  let id = args["id"] as? String,
                  let title = args["title"] as? String,
                  let desc = args["description"] as? String else {
                result(nil)
                return
            }

            let activity = NSUserActivity(activityType: "com.rra94.ayu.\(id)")
            activity.title = title
            activity.userInfo = ["action": id]
            activity.isEligibleForSearch = true
            activity.isEligibleForPrediction = true
            activity.persistentIdentifier = id

            // Donate
            activity.becomeCurrent()

            result(true)
        } else {
            result(FlutterMethodNotImplemented)
        }
    }

    try! setExcludeFromiCloudBackup(isExcluded: true)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // MARK: - EventKit Calendar

  private func getTodayEvents(result: @escaping FlutterResult) {
    let store = EKEventStore()
    store.requestFullAccessToEvents { granted, error in
      guard granted else {
        result([])
        return
      }
      let cal = Calendar.current
      let start = cal.startOfDay(for: Date())
      let end = cal.date(byAdding: .day, value: 1, to: start)!
      let predicate = store.predicateForEvents(withStart: start, end: end, calendars: nil)
      let events = store.events(matching: predicate)

      let mapped = events.map { event -> [String: Any] in
        let startComps = cal.dateComponents([.hour, .minute], from: event.startDate)
        let endComps = cal.dateComponents([.hour, .minute], from: event.endDate)
        return [
          "title": event.title ?? "",
          "startHour": Double(startComps.hour ?? 0) + Double(startComps.minute ?? 0) / 60.0,
          "endHour": Double(endComps.hour ?? 0) + Double(endComps.minute ?? 0) / 60.0,
          "location": event.location ?? "",
        ]
      }
      DispatchQueue.main.async { result(mapped) }
    }
  }

  private func createRecurringEvent(title: String, hourMinute: Int, frequency: String, days: [Int]?, result: @escaping FlutterResult) {
    let store = EKEventStore()
    store.requestFullAccessToEvents { granted, error in
      guard granted else {
        result(nil)
        return
      }

      let event = EKEvent(eventStore: store)
      event.title = "Ayu: \(title)"
      event.calendar = store.defaultCalendarForNewEvents

      // Set start time from hourMinute (minutes from midnight)
      let hour = hourMinute / 60
      let minute = hourMinute % 60
      var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
      comps.hour = hour
      comps.minute = minute
      event.startDate = Calendar.current.date(from: comps)!
      event.endDate = event.startDate.addingTimeInterval(900) // 15 min default

      // Set recurrence
      var rule: EKRecurrenceRule?
      switch frequency {
      case "daily":
        rule = EKRecurrenceRule(recurrenceWith: .daily, interval: 1, end: nil)
      case "weekly":
        if let weekdays = days {
          let ekDays = weekdays.compactMap { day -> EKRecurrenceDayOfWeek? in
            // iOS: 1=Sun, 2=Mon... but our app uses 1=Mon, 7=Sun
            let iosDay = day == 7 ? 1 : day + 1
            return EKRecurrenceDayOfWeek(EKWeekday(rawValue: iosDay)!)
          }
          rule = EKRecurrenceRule(recurrenceWith: .weekly, interval: 1, daysOfTheWeek: ekDays, daysOfTheMonth: nil, monthsOfTheYear: nil, weeksOfTheYear: nil, daysOfTheYear: nil, setPositions: nil, end: nil)
        } else {
          rule = EKRecurrenceRule(recurrenceWith: .weekly, interval: 1, end: nil)
        }
      case "monthly":
        let dayOfMonth = days?.first ?? 1
        rule = EKRecurrenceRule(recurrenceWith: .monthly, interval: 1, daysOfTheWeek: nil, daysOfTheMonth: [NSNumber(value: dayOfMonth)], monthsOfTheYear: nil, weeksOfTheYear: nil, daysOfTheYear: nil, setPositions: nil, end: nil)
      default:
        rule = EKRecurrenceRule(recurrenceWith: .daily, interval: 1, end: nil)
      }

      if let rule = rule {
        event.recurrenceRules = [rule]
      }

      // Add alert 5 min before
      event.addAlarm(EKAlarm(relativeOffset: -300))

      do {
        try store.save(event, span: .futureEvents)
        DispatchQueue.main.async { result(event.eventIdentifier) }
      } catch {
        DispatchQueue.main.async { result(nil) }
      }
    }
  }

  private func deleteCalendarEvent(eventId: String, result: @escaping FlutterResult) {
    let store = EKEventStore()
    store.requestFullAccessToEvents { granted, error in
      guard granted, let event = store.event(withIdentifier: eventId) else {
        result(false)
        return
      }
      do {
        try store.remove(event, span: .futureEvents)
        DispatchQueue.main.async { result(true) }
      } catch {
        DispatchQueue.main.async { result(false) }
      }
    }
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
    // Reuse existing manager if already created
    if self.locationManager == nil {
      let mgr = CLLocationManager()
      mgr.delegate = self
      self.locationManager = mgr
    }
    let mgr = self.locationManager!

    // Only request permission if not yet determined
    let status = mgr.authorizationStatus
    if status == .notDetermined {
      mgr.requestWhenInUseAuthorization()
    }

    if status == .authorizedWhenInUse || status == .authorizedAlways {
      mgr.startMonitoringSignificantLocationChanges()
    }
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

    // Identify nearby place of interest and notify Flutter
    self.identifyPlace(lat: loc.coordinate.latitude, lon: loc.coordinate.longitude) { place in
      if let place = place {
        DispatchQueue.main.async {
          self.locationChannel?.invokeMethod("onPlaceDetected", arguments: place)
        }
      }
    }
  }

  // MARK: - UNUserNotificationCenterDelegate

  override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    let actionId = response.actionIdentifier
    let categoryId = response.notification.request.content.categoryIdentifier

    notificationActionChannel?.invokeMethod("onAction", arguments: [
        "action": actionId,
        "category": categoryId,
    ])

    completionHandler()
  }


  // MARK: - MapKit Place Detection

  private func identifyPlace(lat: Double, lon: Double, completion: @escaping ([String: Any]?) -> Void) {
    let location = CLLocation(latitude: lat, longitude: lon)
    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = "food coffee grocery restaurant"
    request.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 100, longitudinalMeters: 100)

    let search = MKLocalSearch(request: request)
    search.start { response, error in
      guard let response = response, let item = response.mapItems.first else {
        completion(nil)
        return
      }

      let category = self.classifyPlace(item: item)
      completion([
        "name": item.name ?? "",
        "category": category,
        "lat": item.placemark.coordinate.latitude,
        "lon": item.placemark.coordinate.longitude,
      ])
    }
  }

  private func classifyPlace(item: MKMapItem) -> String {
    let name = (item.name ?? "").lowercased()
    let categories = item.pointOfInterestCategory

    // Check MapKit category first
    if let cat = categories {
      if cat == .cafe { return "coffee_shop" }
      if cat == .restaurant || cat == .foodMarket { return "restaurant" }
      if cat == .store { return "grocery" }
      if cat == .fitnessCenter { return "gym" }
      if cat == .pharmacy { return "pharmacy" }
    }

    // Fallback to name-based detection
    if name.contains("starbucks") || name.contains("coffee") || name.contains("cafe") ||
       name.contains("dunkin") || name.contains("peet") || name.contains("tim horton") {
      return "coffee_shop"
    }
    if name.contains("grocery") || name.contains("market") || name.contains("whole foods") ||
       name.contains("trader joe") || name.contains("safeway") || name.contains("kroger") ||
       name.contains("walmart") || name.contains("costco") || name.contains("target") ||
       name.contains("aldi") || name.contains("publix") || name.contains("wegman") {
      return "grocery"
    }
    if name.contains("restaurant") || name.contains("grill") || name.contains("kitchen") ||
       name.contains("bistro") || name.contains("sushi") || name.contains("pizza") ||
       name.contains("burger") || name.contains("taco") || name.contains("chipotle") {
      return "restaurant"
    }
    if name.contains("gym") || name.contains("fitness") || name.contains("crossfit") ||
       name.contains("yoga") || name.contains("equinox") {
      return "gym"
    }
    if name.contains("pharmacy") || name.contains("cvs") || name.contains("walgreens") {
      return "pharmacy"
    }
    return "unknown"
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

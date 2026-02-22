import Cocoa
import UserNotifications

private enum Constants {
    static let defaultThresholdDays: Double = 14
    static let secondsPerDay: Double        = 86400
    static let secondsPerHour: Double       = 3600
    static let renotifyInterval: Double     = 43200  // 12 hours
    static let timerInterval: Double        = 60     // seconds between checks
}

class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    var item: NSStatusItem!
    var timer: Timer?
    var uptimeItem: NSMenuItem!

    var thresholdDays: Double = Constants.defaultThresholdDays
    var lastNotifiedDate: Double = 0  // Unix timestamp (wall-clock), not uptime

    func applicationDidFinishLaunching(_ notification: Notification) {

        NSApp.setActivationPolicy(.accessory)

        loadConfig()
        lastNotifiedDate = UserDefaults.standard.double(forKey: "lastNotifiedDate")

        item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        initializeMenu()

        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound]) { _, _ in }

        timer = Timer.scheduledTimer(withTimeInterval: Constants.timerInterval, repeats: true) { [weak self] _ in
            self?.update()
            self?.checkReminder()
        }

        update()
        checkReminder()
    }

    func initializeMenu() {
        let menu = NSMenu()
        uptimeItem = NSMenuItem(title: "Uptime: calculating...", action: nil, keyEquivalent: "")
        menu.addItem(uptimeItem)
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Set Reminder Threshold...", action: #selector(setThreshold), keyEquivalent: ""))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        item.menu = menu
    }

    func update() {
        let sec = Int(ProcessInfo.processInfo.systemUptime)
        let d = sec / Int(Constants.secondsPerDay)
        let h = (sec % Int(Constants.secondsPerDay)) / Int(Constants.secondsPerHour)
        let m = (sec % Int(Constants.secondsPerHour)) / 60

        let text = "\(d)d \(h)h \(m)m"
        item.button?.title = text
        uptimeItem.title = "Uptime: \(text)"
    }

    func loadConfig() {
        let url: URL = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support/RestartReminder/config.json")

        let folder = url.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)

        guard let data: Data = try? Data(contentsOf: url),
              let json: [String : Any] = try? JSONSerialization.jsonObject(with: data) as? [String:Any],
              let days = (json["days"] as? Double) else {
            return
        }

        thresholdDays = days
    }

    func notify() {
        let days = Int(ProcessInfo.processInfo.systemUptime / Constants.secondsPerDay)
        let content: UNMutableNotificationContent = UNMutableNotificationContent()
        content.title = "Restart Reminder"
        content.body = "Your Mac has been running for \(days) days. Consider restarting for free performance."

        let req: UNNotificationRequest = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(req)
    }

    func checkReminder() {
        let uptime: TimeInterval = ProcessInfo.processInfo.systemUptime
        let days: Double = uptime / Constants.secondsPerDay
        let now = Date().timeIntervalSince1970

        if days >= thresholdDays && now - lastNotifiedDate > Constants.renotifyInterval {
            notify()
            lastNotifiedDate = now
            UserDefaults.standard.set(now, forKey: "lastNotifiedDate")
        }
    }

    @objc func setThreshold() {
        let alert = NSAlert()
        alert.messageText = "Set Reminder Threshold"
        alert.informativeText = "Remind me to restart after this many days of uptime:"
        alert.icon = NSApp.applicationIconImage
        alert.addButton(withTitle: "Save")
        alert.addButton(withTitle: "Cancel")

        let field = NSTextField(frame: NSRect(x: 0, y: 0, width: 120, height: 24))
        field.stringValue = String(format: "%g", thresholdDays)
        alert.accessoryView = field
        alert.window.initialFirstResponder = field

        if alert.runModal() == .alertFirstButtonReturn {
            if let days = Double(field.stringValue), days > 0 {
                thresholdDays = days
                saveConfig(days: days)
            }
        }
    }

    func saveConfig(days: Double) {
        let url = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support/RestartReminder/config.json")
        if let data = try? JSONSerialization.data(withJSONObject: ["days": days], options: .prettyPrinted) {
            try? data.write(to: url)
        }
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()

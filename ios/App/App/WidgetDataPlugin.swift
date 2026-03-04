import Foundation
import Capacitor
import WidgetKit
import UIKit

@objc(WidgetDataPlugin)
public class WidgetDataPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "WidgetDataPlugin"
    public let jsName = "WidgetData"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "saveTasks", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "ping", returnType: CAPPluginReturnPromise)
    ]
    
    @objc func ping(_ call: CAPPluginCall) {
        print("WidgetDataPlugin: PING RECEIVED!")
        call.resolve(["status": "pong"])
    }
    
    @objc func saveTasks(_ call: CAPPluginCall) {
        let tasksJson = call.getString("tasks") ?? "[]"
        let groupName = "group.com.fidelnamisi.superproductivity"
        
        // Write to UserDefaults (primary - fast and reliable for widgets)
        if let userDefaults = UserDefaults(suiteName: groupName) {
            userDefaults.set(tasksJson, forKey: "widgetTasks")
            userDefaults.synchronize()
            print("WidgetDataPlugin: Wrote to UserDefaults successfully.")
        } else {
            print("WidgetDataPlugin WARNING: Could not open UserDefaults for group \(groupName)")
        }
        
        // Also write to file (backup)
        if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupName) {
            let fileURL = containerURL.appendingPathComponent("tasks.json")
            do {
                try tasksJson.write(to: fileURL, atomically: true, encoding: .utf8)
                print("WidgetDataPlugin: Wrote \(tasksJson.count) chars to file.")
            } catch {
                print("WidgetDataPlugin WARNING: File write failed: \(error)")
            }
        }
        
        // Reload all widget timelines
        WidgetCenter.shared.reloadAllTimelines()
        print("WidgetDataPlugin: Triggered timeline reload.")
        
        call.resolve(["status": "success"])
    }
}

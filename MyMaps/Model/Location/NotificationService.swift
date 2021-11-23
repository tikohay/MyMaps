//
//  LocationManager.swift
//  MyMaps
//
//  Created by Karahanyan Levon on 23.11.2021.
//

import Foundation
import UserNotifications

class NotificationService {
    
    static var shared = NotificationService()
    
    private let center = UNUserNotificationCenter.current()
    
    private init() {}
    
    func makeNotificationContent() -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "hello"
        content.subtitle = "it's time to see where you are"
        content.body = "will you take a look ?"
        content.badge = 1
        return content
    }
    
    func makeIntervalNotificationTrigger() -> UNNotificationTrigger {
        return UNTimeIntervalNotificationTrigger(timeInterval: (5),
                                                 repeats: false)
    }
    
    func sendNotificatoinRequest(content: UNNotificationContent,
                                 trigger: UNNotificationTrigger) {
        let request = UNNotificationRequest(identifier: "alarm",
                                            content: content,
                                            trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        center.add(request) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func checkNotificationAuthorization(completionHandler: @escaping () -> (Void)) {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            guard granted else {
                print("not allowed")
                return
            }
            completionHandler()
        }
    }
}

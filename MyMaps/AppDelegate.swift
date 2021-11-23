//
//  AppDelegate.swift
//  MyMaps
//
//  Created by Karahanyan Levon on 03.11.2021.
//

import UIKit
import GoogleMaps
import UserNotifications
import SwiftUI

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        GMSServices.provideAPIKey("AIzaSyCns-fqtBjhyr9U12_NmTlWJPG91qYCkx8")
        
        NotificationService.shared.checkNotificationAuthorization {
            NotificationService.shared.sendNotificatoinRequest(content: NotificationService.shared.makeNotificationContent(),
                                                               trigger: NotificationService.shared.makeIntervalNotificationTrigger())
        }
        
//        let center = UNUserNotificationCenter.current()
//        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
//            guard granted else {
//                print("not allowed")
//                return
//            }
//            sendNotificatoinRequest(content: makeNotificationContent(),
//                                    trigger: makeIntervalNotificationTrigger())
//        }
//
//        center.getNotificationSettings { settings in
//            switch settings.authorizationStatus {
//            case .authorized:
//                print("allowed")
//            case .denied:
//                print("not allowed")
//            case .notDetermined:
//                print("incomprehensibly")
//            default:
//                print("default")
//            }
//        }
//
//        func makeNotificationContent() -> UNNotificationContent {
//            let content = UNMutableNotificationContent()
//            content.title = "hello"
//            content.subtitle = "it's time to see where you are"
//            content.body = "will you take a look ?"
//            content.badge = 1
//            return content
//        }
//
//        func makeIntervalNotificationTrigger() -> UNNotificationTrigger {
//            return UNTimeIntervalNotificationTrigger(timeInterval: (30*60),
//                                                     repeats: false)
//        }
//
//        func sendNotificatoinRequest(content: UNNotificationContent,
//                                     trigger: UNNotificationTrigger) {
//            let request = UNNotificationRequest(identifier: "alarm",
//                                                content: content,
//                                                trigger: trigger)
//
//            let center = UNUserNotificationCenter.current()
//            center.add(request) { error in
//                if let error = error {
//                    print(error.localizedDescription)
//                }
//            }
//        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}


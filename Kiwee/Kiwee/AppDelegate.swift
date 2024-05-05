//
//  AppDelegate.swift
//  Kiwee
//
//  Created by NY on 2024/4/10.
//

import UIKit
import CoreData
import FirebaseCore
import UserNotifications
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .carPlay, .sound]) { (granted, _) in
            if granted {
                print("允許")
                DispatchQueue.main.async {
                    self.scheduleLocalNotifications()
                }
            } else {
                print("不允許")
            }
        }
        UNUserNotificationCenter.current().delegate = self
        
//        IQKeyboardManager.shared.toolbarConfiguration.doneBarButtonConfiguration?.accessibilityLabel = "返回"
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.resignOnTouchOutside = true
        IQKeyboardManager.shared.toolbarConfiguration.tintColor = UIColor.hexStringToUIColor(hex: "1F8A70")
        
        FirebaseApp.configure()
        return true
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        print("在前景收到通知")
        completionHandler([.banner, .list])
    }
    
    func scheduleLocalNotifications() {
        let name = UserDefaults.standard.string(forKey: "name")
        let notificationTimes = ["08:00", "12:30", "19:00"]
        
        let contents = [
            "08:00": ("早安\(name ?? "")", "以營養又健康的早餐來開啟美好的一天！"),
            "12:30": ("午安\(name ?? "")", "午餐時間到了，記得補充點能量！"),
            "19:00": ("晚安\(name ?? "")", "一整天辛苦了，享受晚餐放鬆一下，也別忘記在農場種菜哦！")
        ]
        
        for time in notificationTimes {
            var dateComponents = DateComponents()
            let timeParts = time.split(separator: ":").map { Int($0) }
            dateComponents.hour = timeParts[0]
            dateComponents.minute = timeParts[1]
            
            // Create a new content instance for each time
            let content = UNMutableNotificationContent()
            if let contentDetails = contents[time] {
                content.title = contentDetails.0
                content.body = contentDetails.1
                content.sound = UNNotificationSound.default
            } else {
                return
            }
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: "Notification_\(time)", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error)")
                }
            }
        }
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
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "KiweeCoreData")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

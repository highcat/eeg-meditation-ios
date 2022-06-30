//
//  AppDelegate.swift
//  eeg_meditation
//
//  Created by Alex Lokk on 04/11/2019.
//  Copyright © 2019 Alex Lokk. All rights reserved.
//

import UIKit
import CoreData
import Siren
import Sentry

// HockeyApp
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Sentry
        // Create a Sentry client and start crash handler
        do {
            Client.shared = try Client(dsn: Constants.SENTRY_DSN)
            try Client.shared?.startCrashHandler()
        } catch let error {
            print("\(error)")
            // Wrong DSN or KSCrash not installed
        }

        // Load settings
        do {
            let _ = try SettingsCareTaker.shared.load()
            print(" --- Settings loaded.")
        } catch (let error) {
            // currently skip, and use default settings.
            // FIXME send an error to Sentry
            print(" --- settings loading error: \(error); skip to default")
        }

        // App version update notification
        // see https://github.com/ArtSabintsev/Siren
        Siren.shared.wail()

        // HockeyApp
        MSAppCenter.start(Constants.HOCKEY_APP_ID, withServices:[
          MSAnalytics.self,
          MSCrashes.self
        ])

        return true
    }

    func debug_showAllSavedSessions() {
        // DEBUG: Show all saved sessions
        let fetchRequest = NSFetchRequest<MeditationSession>(entityName: "MeditationSession")
        let objs = try! AppDelegate.viewContext.fetch(fetchRequest)
        for o in objs {
            print("--------------------------------")
            print(o.startTime, o.endTime)
            if let data = o.sessionData {
                print(String(bytes: data, encoding: .utf8))
            } else {
                print("--- no data")
            }
        }
    }

    func applicationWillResignActive(_: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.

        print(" ---- applicationWillResignActive")
        // FIXME: stop bluetooth, if task is not running
    }

    func applicationDidEnterBackground(_: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

        print(" ---- applicationDidEnterBackground")
        // Has 5 seconds;
        // TODO: save the meditation session to CoreData
    }

    func applicationWillEnterForeground(_: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.

        print(" ---- applicationWillEnterForeground")
        // TODO re-enable bluetooth, if not enabled
    }

    func applicationDidBecomeActive(_: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print(" ---- applicationDidBecomeActive")
    }

    func applicationWillTerminate(_: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

        print(" ---- applicationWillTerminate")
        // TODO: save the meditation session to CoreData
        try? MeditationSession.current?.save()
        // Save any pending changes to CoreData
        saveContext()
    }

    
    
    // MARK: - Core Data stack

    static var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "eeg_meditation")
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

    static var viewContext: NSManagedObjectContext { persistentContainer.viewContext }


    // MARK: - Core Data Saving support

    func saveContext () {
        // persistentContainer.newBackgroundContext()
        let context = AppDelegate.persistentContainer.viewContext
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

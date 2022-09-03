//
//  Persistence.swift
//  Target app
//
//  Created by Fadey Notchenko on 10.08.2022.
//

import CoreData
import WidgetKit

struct PersistenceController {
    
    static let shared = PersistenceController()

    
    static func save(target: Target, context: NSManagedObjectContext) {
        do {
            try context.save()
            print("save")
        } catch {
            print("Error save \(error)")
        }
        
        //update widget view
        //updateWidgets(target: target)
        
    }
    
//    static func updateWidgets(target: Target) {
//        let userDefaults = UserDefaults(suiteName: "group.Vitaly-Notchenko.Target-app")
//        if let key = userDefaults?.string(forKey: "widget"), key == target.id?.uuidString {
//            userDefaults?.set(target.name, forKey: "name")
//            userDefaults?.set(target.price, forKey: "price")
//            userDefaults?.set(target.current, forKey: "current")
//            userDefaults?.set(target.valueIndex, forKey: "valueIndex")
//            userDefaults?.set(target.colorIndex, forKey: "colorIndex")
//            userDefaults?.set(target.date, forKey: "date")
//
//            WidgetCenter.shared.reloadAllTimelines()
//        }
//    }
    
    static func deleteTarget(target: Target, context: NSManagedObjectContext) {
        context.delete(target)
        
        save(target: target, context: context)
        
        //delete notification
        //NotificationHandler.deleteNotification(by: target.id?.uuidString ?? UUID().uuidString)
    }

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Target_app")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
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
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

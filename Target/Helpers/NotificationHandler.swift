

//
//  NotificationHandler.swift
//  GoalApp
//
//  Created by Fadey Notchenko on 04.08.2022.
//
import Foundation
import NotificationCenter
import CoreData

class NotificationHandler {
    
    static func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { succes, error in
            if succes {
                print("allow")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    static func sendNotification(_ target: Target, context: NSManagedObjectContext) {
        let dateComponents = calculateDate(selection: Int(target.timeIndex))
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let content = UNMutableNotificationContent()
        content.title = target.name ?? ""
        content.body = bodyString(selection: Int(target.timeIndex), price: target.replenishment, symbol: Constants.valueArray[Int(target.valueIndex)].symbol)
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: target.id?.uuidString ?? UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
        
        target.dateNext = trigger.nextTriggerDate()
        
        PersistenceController.save(target: target, context: context)
    }
    
    static func deleteNotification(by id: String) {
        let center = UNUserNotificationCenter.current()
        center.removeDeliveredNotifications(withIdentifiers: [id])
        center.removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    public static func calculateDate(selection: Int) -> DateComponents {
        var dateComponents = DateComponents()
        dateComponents.hour = 00
        
        switch selection {
        case 1:
            dateComponents = Calendar.current.dateComponents([.weekday], from: Date())
            return dateComponents
        case 2:
            dateComponents = Calendar.current.dateComponents([.day], from: Date())
            return dateComponents
        default:
            return dateComponents
        }
    }
    
    private static func bodyString(selection: Int, price: Int64, symbol: String) -> String {
        var str = ""
        
        switch selection {
        case 0: str += "Новый день!"
        case 1: str += "Неделя прошла!"
        case 2: str += "Месяц позади!"
        default: str += "Это был тяжелый год..."
        }
        
        str += " Не забудь пополнить копилку на сумму \(price) \(symbol)"
        return str
    }
}

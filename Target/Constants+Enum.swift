//
//  Constants.swift
//  GoalApp
//
//  Created by Fadey Notchenko on 04.08.2022.
//

import Foundation
import SwiftUI

class Constants {
    static let timeEnumArray: [Time] = [.day, .week, .month]
    static let timeArray: [LocalizedStringKey] = ["day", "week", "month"]
    static let valueArray: [Value] = [.rub, .usd, .eur]
    
    static var colorArray: [Color] {
        if #available(iOS 15.0, *) {
            return [.red, .pink, .orange, .green, .blue, .cyan, .mint, .teal]
        } else {
            return [.red, .pink, .orange, .green, .blue]
        }
    }
    
    static func formatter(value: Value) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = .current
        formatter.currencySymbol = "USD"
            
        return formatter
    }
    
    
    static var IDIOM : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    
    static let MAX = 9_999_999
    static let MIN = 1
    
    public class globalFunc {
        static func calculateDate(date: Date) -> String {
            let calendar = Calendar.current
            
            // Replace the hour (time) of both dates with 00:00
            let date1 = calendar.startOfDay(for: date)
            let date2 = calendar.startOfDay(for: Date())
            let components = calendar.dateComponents([.day], from: date1, to: date2)
            var str = "\(components.day ?? 0)"
            
            switch (components.day ?? 0) % 100 {
            case 11...19: str += " дней"
            case 1: str += " день"
            case 2...4: str += " дня"
            default: str += " дней"
            }
            
            return str
        }
        
        static func nextRep(selection: Int) -> DateComponents {
            var dateComponents = DateComponents()
            dateComponents.hour = 12
            
            switch selection {
            case 0:
                return dateComponents
            case 1:
                dateComponents.weekday = Calendar.current.component(.weekday, from: Date())
                return dateComponents
            case 2:
                dateComponents = Calendar.current.dateComponents([.weekday, .weekOfMonth, .hour], from: Date())
                return dateComponents
            default:
                dateComponents = Calendar.current.dateComponents([.month, .weekday], from: Date())
                return dateComponents
            }
        }
    }
}

enum Value: String {
    
    case rub = "RUB"
    case usd = "USD"
    case eur = "EUR"
    
    var symbol: String {
        switch self {
        case .rub:
            return "₽"
        case .usd:
            return "$"
        case .eur:
            return "€"
        }
    }
}

enum Time {
    case day
    case week
    case month
    
    var key: LocalizedStringKey {
        switch self {
        case .day:
            return "day"
        case .week:
            return "week"
        case .month:
            return "month"
        }
    }
}

extension Date {
    func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}

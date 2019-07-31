//
//  Date-Extension.swift
//  Chambba
//
//  Created by Rohit Kumar on 25/03/19.
//  Copyright © 2019 Mayur chaudhary. All rights reserved.
//

import Foundation
import UIKit


extension Date {
    
    static func calculateDateTime(day: Int, month: Int, year: Int, hour: Int, minute: Int) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy hh:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        let calculatedDate = formatter.date(from: "\(day)/\(month)/\(year) \(hour):\(minute)")
        return calculatedDate!
    }
    
    func getDayMonthYearHourMinutesSecond() -> (day: Int, month: Int, year: Int, minute: Int, second: Int, hour: Int) {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: self)
        let month = calendar.component(.month, from: self)
        let year = calendar.component(.year, from: self)
        let hour = calendar.component(.hour, from: self)
        let minute = calendar.component(.minute, from: self)
        let second = calendar.component(.second, from: self)
        
        return(day, month, year, minute, second, hour)
    }
    
   
    
}

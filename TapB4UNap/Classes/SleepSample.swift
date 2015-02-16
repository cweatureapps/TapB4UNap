//
//  SleepSample.swift
//  TapB4UNap
//
//  Created by Ken Ko on 15/02/2015.
//  Copyright (c) 2015 Ken Ko. All rights reserved.
//

import Foundation

struct SleepSample {

    var startDate: NSDate?
    var endDate: NSDate?
    
    /* discard the seconds for both startDate and endDate */
    mutating func resetSeconds() {
        startDate = resetSeconds(startDate)
        endDate = resetSeconds(endDate)
    }
    
    private func resetSeconds(date:NSDate?) -> NSDate? {
        if (date != nil) {
            let calendar = NSCalendar.currentCalendar()
            let dateComponents = calendar.components(.YearCalendarUnit | .MonthCalendarUnit | .DayCalendarUnit, fromDate: date!)
            let timeComponents = calendar.components(.HourCalendarUnit | .MinuteCalendarUnit | .SecondCalendarUnit, fromDate: date!)
            dateComponents.hour = timeComponents.hour
            dateComponents.minute = timeComponents.minute
            dateComponents.second = 0
            return calendar.dateFromComponents(dateComponents)!
        } else {
            return nil
        }
    }
    
    /* formatted string showing the time elapsed in this sleep sample */
    func formattedString() -> String? {
        if (!isValid()) {
            return nil
        } else {        
            let calendar = NSCalendar.currentCalendar()
            let components = calendar.components( .CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitSecond, fromDate: startDate!, toDate: endDate!, options: NSCalendarOptions.allZeros)
            return "\(components.hour)hr \(components.minute)min \(components.second)sec"
        }
    }
    
    /* returns true if it can be saved, and startDate is before endDate */
    func isValid() -> Bool {
        return canSave() && startDate!.compare(endDate!).rawValue <= 0
    }
    
    /* returns true when both start date and end date are recorded */
    func canSave() -> Bool {
        return startDate != nil && endDate != nil
    }
    
    /* returns true when a start date is recorded, but no end date is recorded */
    func isSleeping() -> Bool {
        return startDate != nil && endDate == nil
    }
}

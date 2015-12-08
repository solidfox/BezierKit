// Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"

let a = [3,2,6].sorted() {$0 < $1}
a

let early = NSDateComponents()
early.year = 2014
early.month = 02
early.day = 29

let late = NSDateComponents()
late.year = 2014
late.month = 04
late.day = 01

let cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
//cal.locale = NSLocale(localeIdentifier: "en-US")

let earlyDate = cal.dateFromComponents(early)
let lateDate = cal.dateFromComponents(late)
NSDate()

let com = cal.components(.CalendarUnitDay | .CalendarUnitHour, fromDate: earlyDate, toDate: lateDate, options: nil)

com.day

com.hour

// Standard solution still works
//let cal = NSCalendar.currentCalendar().components(.CalendarUnitDay | .CalendarUnitHour, fromDate: earlyDate, toDate: lateDate, options: nil).day

// Flashy swift... maybe...

func -(lhs:NSDate, rhs:NSDate) -> DateRange {
    return DateRange(startDate: rhs, endDate: lhs)
}

class DateRange {
    let startDate:NSDate
    let endDate:NSDate
    var calendar = NSCalendar.currentCalendar()
    var days: Int {
        return calendar.components(.CalendarUnitDay, fromDate: startDate, toDate: endDate, options: nil).day
    }
    var months: Int {
        return calendar.components(.CalendarUnitMonth, fromDate: startDate, toDate: endDate, options: nil).month
    }
    init(startDate:NSDate, endDate:NSDate) {
        self.startDate = startDate
        self.endDate = endDate
    }
}


(lateDate - earlyDate).months


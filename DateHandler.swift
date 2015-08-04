//
//  DateHandler.swift
//  PreSales-Huddle
//
//  Created by Himanshu Phirke on 27/07/15.
//  Copyright (c) 2015 synerzip. All rights reserved.
//

import Foundation

class DateHandler {
  
  class func getPrintDate(date: NSDate) -> String {
    let df = NSDateFormatter()
    df.dateFormat = "dd-MMMM-yy, hh:mm a" // e.g 27-July-15, 05:45 PM
    df.timeZone = NSTimeZone.localTimeZone()
    return df.stringFromDate(date)
  }

  class func getDBDate(date: NSDate) -> String {
    return date.timeIntervalSince1970.description
  }

  class func getNSDate(dbDate: String) -> NSDate {
    return NSDate(timeIntervalSince1970: (dbDate as NSString).doubleValue)
  }

}
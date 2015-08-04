//
//  CalendarNotification.swift
//  PreSales-Huddle
//
//  Created by Himanshu Phirke on 22/07/15.
//  Copyright (c) 2015 synerzip. All rights reserved.
//

import EventKit
import Dispatch

class CalendarNotification {
  var status = EKAuthorizationStatus.NotDetermined
  var allowed: Bool {
    get {
      switch status {
      case EKAuthorizationStatus.Authorized: return true
      default: return false
      }
    }
  }
  
  let store = EKEventStore()
  var calendar: EKCalendar? {
    get {
      if allowed {
        return findCalendarByTitle(EKEventStore(), title: "Calendar")!
      } else {
        return nil
      }
    }
  }
  var prospectID: Int?
  
  private let defaults = NSUserDefaults.standardUserDefaults()
  
  var user : String {
    get {
      return defaults.objectForKey("userID") as! String
    }
  }
  var userCalId: String {
    get {
      return user + "-\(prospectID)"
    }
  }
  
  var userCalendarEvents = [String:String]() {
    didSet {
      defaults.setObject(userCalendarEvents, forKey: user + "--CalNotifications")
    }
  }
  
  var semaphore = dispatch_semaphore_create(0)
  private let concurrentSaveNotification = dispatch_queue_create(
    "com.synerzip.PreSalesHuddle.saveNotification", DISPATCH_QUEUE_CONCURRENT)
  
  // MARK: AUTH
  func requestAuth(){
    if status == EKAuthorizationStatus.NotDetermined {
      let store = EKEventStore()
      store.requestAccessToEntityType(EKEntityTypeEvent, completion: { (granted, error: NSError?) -> Void in
        if granted {
          self.status = EKAuthorizationStatus.Authorized
        } else {
          self.status = EKAuthorizationStatus.Denied
        }
        dispatch_semaphore_signal(self.semaphore)
      })
    }
    else {
      dispatch_semaphore_signal(self.semaphore)
    }
  }
  
  func getAuthStatus() -> EKAuthorizationStatus {
    return EKEventStore.authorizationStatusForEntityType(EKEntityTypeEvent)
  }
  
  
  // MARK: EKCalendar
  func findCalendarByTitle(store: EKEventStore, title: String) -> EKCalendar? {
    let calendars = store.calendarsForEntityType(EKEntityTypeEvent) as! [EKCalendar]
    for calendar in calendars {
      if calendar.title == title {
        return calendar
      }
    }
    return nil
  }
  
  // MARK: Update Entries
  private func updateCalendarEntryStartDate(event: EKEvent, startDate: NSDate) -> Bool {
    event.startDate = startDate
    return (saveEvent(event) != nil)
  }
  
  private func updateCalendarEntryEndDate(event: EKEvent, endDate: NSDate) -> Bool {
    event.endDate = endDate
    return (saveEvent(event) != nil)
  }
  
  private func updateCalendarEntryTitle(event: EKEvent, title: String) -> Bool {
    event.title = title
    return (saveEvent(event) != nil)
  }
  
  private func addNotesToCalendarEntry(eventIdentifier: String, notes: String) -> Bool {
    if let event = store.eventWithIdentifier(eventIdentifier) {
      event.notes = notes
      return true
    }
    return false
    
  }
  
  // MARK: Save Event
  private func saveEvent(event: EKEvent) -> EKEvent? {
    var error: NSError?
    let result = store.saveEvent(event, span: EKSpanThisEvent, error: &error)
    if result == false {
      if let theError = error {
        println("An error occured \(theError)")
        println("\(event)")
      }
      return nil
    }
    userCalendarEvents[userCalId] = event.eventIdentifier
    return event
  }
  
  private func addInCalendar(title: String, startDate: NSDate, endDate: NSDate) -> Bool {
    let event = EKEvent(eventStore: store)
    if let cal = calendar {
      event.calendar = cal
      event.title = title
      event.startDate = startDate
      event.endDate = endDate
      return (saveEvent(event) != nil)
    }
    return false
  }
  
  private func getUserCalendarEvents() -> [String:String] {
    if let userEvents: AnyObject = defaults.objectForKey(user + "--CalNotifications") {
      return userEvents as! [String : String]
    } else {
      return [String:String]()
    }
  }
  
  func addEntry(prospID: Int, title: String, startDate: NSDate, endDate: NSDate) -> Bool {
    requestAuth()
    prospectID = prospID
    userCalendarEvents = getUserCalendarEvents()
    var done:Bool
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER)
    // check if this is aldready in notifications
    if userCalendarEvents[userCalId] == nil {
      // need to add notification

        done = addInCalendar(title, startDate: startDate, endDate: endDate)

    } else {
        let eventID = self.userCalendarEvents[userCalId]!
        //update
        if let event = self.store.eventWithIdentifier(eventID) {
          done = updateCalendarEntryEndDate(event, endDate: endDate)
          done = updateCalendarEntryStartDate(event, startDate: startDate)
          done = updateCalendarEntryTitle(event, title: title)
        } else {
          userCalendarEvents[userCalId] = nil
          done = addInCalendar(title, startDate: startDate, endDate: endDate)
        }
    }
    return done
  }
}


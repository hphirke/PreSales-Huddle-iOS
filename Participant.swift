//
//  Participants.swift
//  PreSales-Huddle
//
//  Created by Himanshu Phirke on 26/07/15.
//  Copyright (c) 2015 synerzip. All rights reserved.
//

import Foundation


class Participant: Comparable {
  var userID_: String
  var isIncluded_: String
  
  init(userID: String, isIncluded: String) {
    self.isIncluded_ = isIncluded
    self.userID_ = userID
  }
  
  func toggleInclusion() {
    if isIncluded_ == "Yes" {
      isIncluded_ = "No"
    } else {
      isIncluded_ = "Yes"
    }
  }
  
  func getDict() -> [String: AnyObject] {
    return ["UserID": userID_, "Included": isIncluded_]
  }
}

// For Comparable
func <(left: Participant, right: Participant) -> Bool {
  return left.userID_ < right.userID_
}

// For Comparable
func ==(left: Participant, right: Participant) -> Bool {
  return left.userID_ == right.userID_
}
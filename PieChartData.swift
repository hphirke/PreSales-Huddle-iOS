//
//  Chart.swift
//  PreSales-Huddle
//
//  Created by Sachin Avhad on 28/07/15.
//  Copyright (c) 2015 synerzip. All rights reserved.
//

import Foundation

class PieChartData {
  var key_:String
  var count_:Int
  var selected_:Bool
  
  init(key: String, count: Int, selected: Bool) {
    self.key_ = key
    self.count_ = count
    self.selected_ = selected
  }
  
  func setSelected(value:Bool) ->Void {
    self.selected_ = value
  }
  
  func isSelected() ->Bool {
    return self.selected_
  }
}
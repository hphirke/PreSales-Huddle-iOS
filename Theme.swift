//
//  Theme.swift
//  PreSales-Huddle
//
//  Created by Himanshu Phirke on 29/07/15.
//  Copyright (c) 2015 synerzip. All rights reserved.
//

import UIKit

class Theme {
  
  
  class Prospects {
    static let navBarBG = UIColor.redColor()
    
    static let tableViewSeparator = UIColor.clearColor()
    static let cellBGEvenCell = UIColor(red: 1.000, green: 0.875, blue: 0.749, alpha: 1.00)
    static let cellBGOddCell = UIColor(red: 1.000, green: 0.749, blue: 0.498, alpha: 1.00)

    
    static let okButtonBG = UIColor(red: 139/255, green: 181/255, blue: 229/255, alpha: 1)

    static let formBG =  cellBGOddCell
    static let textFieldBG = cellBGEvenCell
    static let inputOutline = UIColor(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0)
    static let detailText = UIColor(red: 0/255.0, green: 135/255.0,
      blue: 222/255.0, alpha: 1.0)
    static let detailTextSecond = UIColor(red: 204/255.0, green: 51/255.0,
      blue: 51/255.0, alpha: 1.0)
    static let RefreshControlBackground = cellBGOddCell
    static let RefreshControl = UIColor.brownColor()
    
//    static let
  }

  class Clients {
    static let navBarBG = UIColor.redColor()
    
    static let tableViewSeparator = UIColor.clearColor()
    static let cellBGEvenCell = UIColor(red: 0.267, green: 0.839, blue: 0.992, alpha: 1.00)
    static let cellBGOddCell = UIColor(red: 0.024, green: 0.667, blue: 0.831, alpha: 1.00)
    
    static let formBG =  cellBGOddCell
    static let textFieldBG = cellBGEvenCell
    static let detailText = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.00)
    static let RefreshControlBackground = cellBGOddCell
    static let RefreshControl = UIColor.yellowColor()

  }
  
  class Reports {
    static let navBarBG = UIColor.yellowColor()
    
    static let tableViewSeparator = UIColor.clearColor()
    static let cellBGEvenCell = UIColor(red: 0.259, green: 0.651, blue: 0.478, alpha: 1.00)
    static let cellBGOddCell = UIColor(red: 0.475, green: 0.824, blue: 0.667, alpha: 1.00)
    static let formBG =  cellBGOddCell
    static let textFieldBG = cellBGEvenCell
    static let RefreshControlBackground = cellBGOddCell
    static let RefreshControl = UIColor.yellowColor()

  }
  
  class func applyButtonBorder(button: UIButton) {
    button.layer.borderWidth = 1.0
    button.layer.cornerRadius = 5.0
    button.layer.borderColor = UIColor.clearColor().CGColor
    button.tintColor = UIColor.whiteColor()
  }
  class func applyLabelBorder(label: UILabel) {
    label.layer.borderWidth = 1.0
    label.layer.cornerRadius = 5.0
    label.layer.borderColor = UIColor.clearColor().CGColor
  }

}

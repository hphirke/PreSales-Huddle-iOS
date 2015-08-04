//
//  TabBar.swift
//  PreSales-Huddle
//
//  Created by Himanshu Phirke on 28/07/15.
//  Copyright (c) 2015 synerzip. All rights reserved.
//

import Foundation

class TabBar: UITabBarController {
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    if let userRole = NSUserDefaults.standardUserDefaults().stringForKey("userRole") {
      if userRole == "User" {
        if let items = tabBar.items as? [UITabBarItem] {
          for item in items {
            if item.title != "Prospects" {
              item.enabled = false
            }
          }
        }
      }
    }

  }
}

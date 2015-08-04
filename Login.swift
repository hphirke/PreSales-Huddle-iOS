//
//  Login.swift
//  PreSales-Huddle
//
//  Created by Himanshu Phirke on 28/07/15.
//  Copyright (c) 2015 synerzip. All rights reserved.
//

import UIKit
class Login : UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
  
  let userRoles = ["Sales", "User"]
  var roleRow = 0
  @IBOutlet weak var userName: UITextField!
  @IBOutlet weak var picker: UIPickerView!
  
  @IBOutlet weak var enter: UIButton!
  
  
  @IBAction func enterKeyBoard(sender: AnyObject) {
    performSegueWithIdentifier("enter-segue", sender: self)
  }
  
  override func viewDidLoad() {
    userName.becomeFirstResponder()
    if let id = NSUserDefaults.standardUserDefaults().stringForKey("userID") {
      userName.text = id
      enter.enabled = true
    }
    stylizeControls()
  }
  
  private func stylizeControls() {
    enter.backgroundColor = Theme.Prospects.okButtonBG
    Theme.applyButtonBorder(enter)
  }
    
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return userRoles.count
  }
  
  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
    return userRoles[row]
  }
  
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    roleRow = row
  }
  
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
    return 100.0
  }
  
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange,
    replacementString string: String) -> Bool {
      let oldString: NSString = userName.text
      let newString: NSString = oldString.stringByReplacingCharactersInRange(
        range, withString: string)
      enter.enabled = newString.length > 0
      return true
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    NSUserDefaults.standardUserDefaults().setObject(userName.text, forKey: "userID")
    NSUserDefaults.standardUserDefaults().setObject(userRoles[roleRow], forKey: "userRole")
    NSUserDefaults.standardUserDefaults().synchronize()
  }
}
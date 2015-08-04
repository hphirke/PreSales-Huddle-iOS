//
//  DateSelector.swift
//  PreSales-Huddle
//
//  Created by Himanshu Phirke on 27/07/15.
//  Copyright (c) 2015 synerzip. All rights reserved.
//

import UIKit

protocol DateSelectorDelegate{
  func dateSelectorDidFinish(controller: DateSelector, type: String?)
}
class DateSelector: UIViewController {

  var delegate: DateSelectorDelegate?
  var type: String?
  override func viewDidLoad() {
      super.viewDidLoad()

      // Do any additional setup after loading the view.
  }

  override func viewWillAppear(animated: Bool) {
    self.view.frame = CGRect(x: 0, y: self.view.bounds.height - 260, width: self.view.bounds.width, height: 260)
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }

  @IBOutlet weak var datePicker: UIDatePicker!
// MARK: action functions
  @IBAction func cancel(sender: UIBarButtonItem) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  

  @IBAction func done(sender: UIBarButtonItem) {
    dismissViewControllerAnimated(true, completion: nil)
    delegate?.dateSelectorDidFinish(self, type: type)
  }

}

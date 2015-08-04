//
//  Prospect.swift
//  PreSales-Huddle
//
//  Created by Himanshu Phirke on 22/07/15.
//  Copyright (c) 2015 synerzip. All rights reserved.
//

import UIKit


protocol ProspectDelgate: class {
  func saveProspectFinish(name: String)
}

class Prospect: UIViewController, UITextFieldDelegate {

  var hud:MBProgressHUD?
  var delegate: ProspectDelgate?
  var itemToEdit: [String: AnyObject]?
  var userRole = "Unknown"
  var prospectID: Int?
  var participantEntryPresent = false
  let addProspectURL = "prospect/add/"
  let updateProspectURL = "prospect/update/"
  let viewParticipantsByUserIDURL = "participant/view/userid/"
  let addParticipant = "participant/add/"
  let updateParticipant = "participant/update/"
  
  // MARK: Outlets
  @IBOutlet weak var name: UITextField!
  @IBOutlet weak var notes: UITextView!
  @IBOutlet weak var domain: UITextField!
  @IBOutlet weak var desiredTeamSize: UITextField!
  @IBOutlet weak var techStack: UITextField!
  @IBOutlet weak var participate_switch: UISwitch!

  @IBOutlet weak var discussions: UIBarButtonItem!
  @IBOutlet weak var conf_call_label: UILabel!
  @IBOutlet weak var save_button: UIButton!
  @IBOutlet weak var participate_label: UILabel!
  @IBOutlet weak var ignore_label: UILabel!
  @IBOutlet weak var scheduleCall_button: UIButton!
  
  @IBOutlet weak var convertToClient_button: UIButton!
  // MARK: view Functions


  override func viewWillAppear(animated: Bool) {
    getUserRole()
    accessControl()
    participantEntryPresent = false
    if let prospect = itemToEdit {
      // Edit or view screen
      prospectID = prospect["ProspectID"] as? Int
      if userRole == "Sales" {
        self.title = "Edit Prospect"
        scheduleCall_button.hidden = false
        convertToClient_button.hidden = false
      } else {
        self.title = "View Prospect"
        fetchParticipantDetails()
      }
      displayFormData(prospect)
    } else {
      discussions.enabled = false
      name.becomeFirstResponder()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    stylizeControls()
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
  }

  // MARK: Action functions
  
  @IBAction func cancel(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func save(sender: AnyObject) {
    dispatch_async(dispatch_get_main_queue()) {
      self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
      self.hud?.labelText = "Saving data"
      self.hud?.detailsLabelText = "Please wait..."
    }
    if let prospect = itemToEdit {
      // Edit
      updateProspectToWebService(updateProspectURL)
    } else {
      // Add
      updateProspectToWebService(addProspectURL)
    }
  }

  @IBAction func participateInCall(sender: UISwitch) {
    var participant = [String: AnyObject]()
    var operation = addParticipant

    participant["ProspectID"] = prospectID

    if let userName = NSUserDefaults.standardUserDefaults().stringForKey("userID") {
      participant["UserID"] = userName
    }
    var value = "No"
    if sender.on == true {
      value = "Yes"
    }
    participant["Participation"] = value
    
    if participantEntryPresent == true {
      // Update query
      operation = updateParticipant
    } else {
      // Add Query
      operation = addParticipant
      participant["Included"] = "Yes"
    }
    
    saveParticipantWebService(participant, method:operation)
    
  }
// MARK: Internal functions
  private func accessControl() {
    scheduleCall_button.hidden = true // Visible in Edit propect only
    convertToClient_button.hidden = true // Visible in Edit propect only
    if userRole == "Sales" {
      participate_switch.hidden = true
      participate_label.hidden = true
      ignore_label.hidden = true
      conf_call_label.hidden = true
    } else {
      save_button.hidden = true
    }
  }
  
  private func getUserRole() {
    if let role = NSUserDefaults.standardUserDefaults().stringForKey("userRole") {
      userRole = role
    }
  }
  
  private func stylizeControls() {
    // Applying outline to textview
    notes.layer.borderColor = Theme.Prospects.inputOutline.CGColor
    notes.layer.borderWidth = 1.0
    notes.layer.cornerRadius = 5.0
    
    // Setting tint color
    participate_switch.tintColor = UIColor(red: 204.0/255.0, green: 51/255.0,
      blue: 51/255.0, alpha: 1.0)
    navigationController?.navigationBar.backgroundColor = Theme.Prospects.navBarBG
    view.backgroundColor = Theme.Prospects.formBG
    
    
    // Text Field BG Color    
    name.backgroundColor = Theme.Prospects.textFieldBG
    notes.backgroundColor = Theme.Prospects.textFieldBG
    domain.backgroundColor = Theme.Prospects.textFieldBG
    desiredTeamSize.backgroundColor = Theme.Prospects.textFieldBG
    techStack.backgroundColor = Theme.Prospects.textFieldBG
    
    convertToClient_button.backgroundColor = Theme.Prospects.okButtonBG
    save_button.backgroundColor = Theme.Prospects.okButtonBG
    scheduleCall_button.backgroundColor = Theme.Prospects.okButtonBG
    
    Theme.applyButtonBorder(convertToClient_button)
    Theme.applyButtonBorder(save_button)
    Theme.applyButtonBorder(scheduleCall_button)

  }
  
  private func displayFormData(prospect: [String: AnyObject]) {
    name.text = prospect["Name"] as! String
    techStack.text = prospect["TechStack"] as! String
    domain.text = prospect["Domain"] as! String
    if let teamSize = prospect["DesiredTeamSize"] as? Int {
      desiredTeamSize.text = "\(teamSize)"
    }
    notes.text = prospect["Notes"] as! String
  }
  private func getFormData() -> [String: AnyObject] {
    var prospect = [String: AnyObject]()
    prospect["Name"] = name.text
    prospect["TechStack"] = techStack.text
    prospect["Domain"] = domain.text
    prospect["DesiredTeamSize"] = desiredTeamSize.text.toInt()
    prospect["Notes"] = notes.text
    return prospect
  }
  
  private func getNSData(prospectDict: [String: AnyObject]) -> NSData? {
    var jsonError:NSError?
    var jsonData:NSData? = NSJSONSerialization.dataWithJSONObject(
      prospectDict, options: nil, error: &jsonError)
    return jsonData
  }

  private func updateProspectToWebService(operation: String) {
    var prospect = getFormData()
    if operation == updateProspectURL {
      if let id = prospectID {
        prospect["ProspectID"] = id
      }
    } else if let userName = NSUserDefaults.standardUserDefaults().stringForKey("userID") {
      prospect["SalesID"] = userName
      prospect["CreateDate"] = DateHandler.getDBDate(NSDate())
    }

    saveProspectToWebService(prospect, method:operation)
  }
  
  private func saveProspectToWebService(dict: [String: AnyObject], method: String) {
    println("Prospect save:  \(dict)")
    if let data = getNSData(dict) {
      let nc = NetworkCommunication()
      nc.postData(method, data: data,
          successHandler: saveProspectSuccess,
          serviceErrorHandler: serviceError,
          errorHandler: networkError)
    } else {
      showMessage("Failure", message: "Failed to convert data")
    }
  }
  
  private func saveParticipantWebService(dict: [String: AnyObject], method: String) {
    println("Participant operation:  \(method)")
    println("Participant save:  \(dict)")
    if let data = getNSData(dict) {
      let nc = NetworkCommunication()
      nc.postData(method, data: data,
        successHandler: participantSaveSuccess,
        serviceErrorHandler: participantServiceError,
        errorHandler: participantNetworkError)
    } else {
      showMessage("Failure", message: "Failed to convert data")
    }
  }
  
  private func showMessage(title:String, message: String) {
    let alert = UIAlertController(title: title, message: message,
      preferredStyle: .Alert)
    let action = UIAlertAction(title: "Ok", style: .Default, handler: {
      action in
      self.dismissViewControllerAnimated(false,completion: nil)
    })
    alert.addAction(action)
    presentViewController(alert, animated: true, completion: nil)
  }

  private func commonHandler() {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    dispatch_async(dispatch_get_main_queue()) {
      self.hud?.hide(true)
    }
  }
  
  private func setParticipantSwitch(dict: [String: AnyObject]) -> Bool {
    if let participate = dict["Participation"] as? String {
      participantEntryPresent = true
      if participate == "Yes" {
        dispatch_async(dispatch_get_main_queue()) {
          self.participate_switch.on = true
        }
      return true
      }
    }
    return false
  }
  
  func fetchParticipantSuccess(data: NSData) -> Void {
    commonHandler()
    var error: NSError?
    if let dict_array = NSJSONSerialization.JSONObjectWithData(data,
      options: NSJSONReadingOptions.MutableContainers, error: &error) as? [AnyObject] {
        println(dict_array)
        for item in dict_array  {
          let dict = item as! [String: AnyObject]
          if let fetchID = dict["ProspectID"] as? Int {
            if fetchID == prospectID {
              let retValue = setParticipantSwitch(dict)
              if retValue == true {
                println("Participant Data found")
                break
              }
            }
          }
        }
    } else {
      println("No Data for participant found")
      dispatch_async(dispatch_get_main_queue()) {
        self.participate_switch.on = false
      }
    }
  }
  
  func saveProspectSuccess(data: NSData) -> Void {
    commonHandler()
    delegate?.saveProspectFinish(name.text)
  }
  
  func networkError( error: NSError) -> Void {
    commonHandler()
    dispatch_async(dispatch_get_main_queue()) {
      self.showMessage("Network error",
        message: "Code: \(error.code)\n\(error.localizedDescription)")
    }
  }
  
  func serviceError(response: NSHTTPURLResponse) -> Void {
    commonHandler()
    dispatch_async(dispatch_get_main_queue()) {
      self.showMessage("Webservice Error",
        message: "Error received from webservice: \(response.statusCode)")
    }
  }
  
  func participantSaveSuccess(data: NSData) -> Void {
    commonHandler()
    participantEntryPresent = true
    dispatch_async(dispatch_get_main_queue()) {
      let hudMessage = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
      hudMessage.mode = MBProgressHUDMode.Text
      hudMessage.labelText = "Preference saved"
      hudMessage.hide(true, afterDelay: 1.5)
      hudMessage.opacity = 0.4
      hudMessage.yOffset = Float(self.view.frame.size.height/2 - 100)
    }

  }

  
  func participantNetworkError( error: NSError) -> Void {
    commonHandler()
    dispatch_async(dispatch_get_main_queue()) {
      self.showMessage("Network error",
        message: "Code: \(error.code)\n\(error.localizedDescription)")
      self.participate_switch.on = !self.participate_switch.on
    }
  }
  
  func participantServiceError(response: NSHTTPURLResponse) -> Void {
    commonHandler()
    dispatch_async(dispatch_get_main_queue()) {
      self.showMessage("Webservice Error",
        message: "Error received from webservice: \(response.statusCode)")
      self.participate_switch.on = !self.participate_switch.on
    }
  }
  

  private func fetchParticipantDetails() {
    if let userName = NSUserDefaults.standardUserDefaults().stringForKey("userID") {
      let url = viewParticipantsByUserIDURL + userName
      let nc = NetworkCommunication()
      let retValue = nc.fetchData(url,
        successHandler: fetchParticipantSuccess, serviceErrorHandler: serviceError,
        errorHandler: networkError)
    }
  }

  // MARK: Segue Functions
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "Discussions" {
      let targetController = segue.destinationViewController as! UINavigationController
      let targetView = targetController.topViewController as! Discussions
      if let id = prospectID {
        targetView.prospectID = id
      }
    } else if segue.identifier == "ScheduleCall" {
      let targetController = segue.destinationViewController as! UINavigationController
      let targetView = targetController.topViewController as! ScheduleCall
      if let id = prospectID {
        targetView.prospectID = id
      }
    } else if segue.identifier == "ConvertToClient" {
      let targetController = segue.destinationViewController as! UINavigationController
      let targetView = targetController.topViewController as! ConvertClient
      if let id = prospectID {
        targetView.prospectID = id
      }
      targetView.prospectName = name.text
    }
  }
}

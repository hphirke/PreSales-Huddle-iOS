//
//  ScheduleCall.swift
//  PreSales-Huddle
//
//  Created by Himanshu Phirke on 26/07/15.
//  Copyright (c) 2015 synerzip. All rights reserved.
//

import UIKit

class ScheduleCall: UIViewController, UITableViewDataSource, UITableViewDelegate, DateSelectorDelegate {

  var hud:MBProgressHUD?
  var allParticipants = [Participant]()
  var prospectID: Int?
  let viewParticipantsURL = "participant/view/prospectid/"
  let updateParticipantURL = "participant/update/"
  let updateProspectURL = "prospect/update/"
  var toDate: NSDate = NSDate()
  var fromDate: NSDate = NSDate()

  // MARK: Outlets
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var participants_selected_count: UILabel!
  @IBOutlet weak var selection_note: UILabel!
  @IBOutlet weak var done: UIBarButtonItem!
  @IBOutlet weak var from_date_label: UILabel!
  @IBOutlet weak var to_date_label: UILabel!
  @IBOutlet weak var duration_label: UILabel!
  @IBOutlet weak var currentTableView: UITableView!
  @IBOutlet weak var noParticipantsLabel: UILabel!
  
// MARK: view functions
  override func viewDidLoad() {
    super.viewDidLoad()
    stylizeControls()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    fetchData()
  }

// MARK: action functions

  @IBAction func done(sender: AnyObject) {
    let from = (DateHandler.getDBDate(fromDate) as NSString).doubleValue
    let to = (DateHandler.getDBDate(toDate) as NSString).doubleValue
    if to > from {
      updateProspectToWebService(updateProspectURL)
    } else {
      showMessage("Date Error",
        message: "Select valid From and To date")

    }
  }

  @IBAction func from_date(sender: UITapGestureRecognizer) {
    loadDateSelectorNIB("From")
  }
  
  @IBAction func to_date(sender: UITapGestureRecognizer) {
    loadDateSelectorNIB("To")
  }
// MARK: tableView functions
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return allParticipants.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("participant") as! UITableViewCell
    let participant = allParticipants[indexPath.row]
    populateCellData(cell, withParticipant: participant)
    configureSelectionLabel()
    stylizeCell(cell,index: indexPath.row)
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if let cell = tableView.cellForRowAtIndexPath(indexPath) {
      let participant = allParticipants[indexPath.row]
      participant.toggleInclusion()
      configureCheckmarkForCell(cell, included: participant.isIncluded_)
      saveParticipantData(participant)
    }
    // Deselects the row
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    configureSelectionLabel()
    tableView.reloadData()
  }
  
// MARK: Internal functions

  private func loadDateSelectorNIB(type: String) {
    let dateVC = DateSelector(nibName: "DateSelector", bundle: nil)
    dateVC.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
    dateVC.delegate = self
    dateVC.type = type
    presentViewController(dateVC, animated: true, completion: nil)
  }
  private func configureSelectionLabel() {
    var count = 0
    for entry in allParticipants {
      count = entry.isIncluded_ == "Yes" ? count + 1 : count
    }
    if count == 0 {
      done.enabled = false
    } else {
      done.enabled = true
    }
    participants_selected_count.text = "Selected Participants: \(count)"
  }
  
  private func getNSData(prospectDict: [String: AnyObject]) -> NSData? {
    var jsonError:NSError?
    var jsonData:NSData? = NSJSONSerialization.dataWithJSONObject(
      prospectDict, options: nil, error: &jsonError)
    return jsonData
  }

  private func saveParticipantData(participant: Participant) {
    var dict = participant.getDict()
    if let id = prospectID {
      dict["ProspectID"] = id
    }
    println(dict)
    if let data = getNSData(dict) {
      saveToWebService(data, operation: updateParticipantURL)
    } else {
      showMessage("Failure", message: "Failed to convert data")
    }
  }
  private func configureCheckmarkForCell(cell: UITableViewCell, included: String) {
    let label = cell.viewWithTag(301) as! UILabel
    if included == "Yes" {
      label.text = "√"
      label.textColor = view.tintColor
    } else {
      label.text = "X"
      label.textColor = UIColor(red: 204.0/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1.0)
    }

  }
  
  private func setTextInTableCell(cell: UITableViewCell, name: String) {
      let label = cell.viewWithTag(302) as! UILabel
      label.text = name
  }

  
  private func populateCellData(cell: UITableViewCell,
    withParticipant participant: Participant) {
    configureCheckmarkForCell(cell, included: participant.isIncluded_)
    setTextInTableCell(cell, name: participant.userID_)
  }
  
  private func stylizeControls() {
    navigationController?.navigationBar.backgroundColor = Theme.Prospects.navBarBG
    tableView.separatorColor = Theme.Prospects.tableViewSeparator
    tableView.backgroundColor = Theme.Prospects.cellBGOddCell
    view.backgroundColor = Theme.Prospects.cellBGOddCell

//    Theme.applyLabelBorder(from_date_label) Edge are rounded and background color is not edged
//    Theme.applyLabelBorder(to_date_label)
//    Theme.applyLabelBorder(duration_label)
    
    to_date_label.backgroundColor = Theme.Prospects.textFieldBG
    from_date_label.backgroundColor = Theme.Prospects.textFieldBG
    duration_label.backgroundColor = Theme.Prospects.textFieldBG

  }
  
  private func fetchData() {
    dispatch_async(dispatch_get_main_queue()) {
      self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
      self.hud?.labelText = "Loading.."
    }

    if let id = prospectID {
      let url = viewParticipantsURL + "\(id)"
      println("Participant fetch: \(url)")
      let nc = NetworkCommunication()
      let retValue = nc.fetchData(url,
        successHandler: fetch_success, serviceErrorHandler: service_error,
        errorHandler: network_error)
    }
  }

  private func commonHandler() {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    dispatch_async(dispatch_get_main_queue()) {
      self.hud?.hide(true)
    }
  }
  
  func fetch_success(data: NSData) -> Void {
    commonHandler()
    var error: NSError?
    if let dict_array = NSJSONSerialization.JSONObjectWithData(data,
      options: NSJSONReadingOptions.MutableContainers, error: &error) as? [AnyObject] {
        allParticipants = []
        for item in dict_array  {
          let dict = item as! [String: AnyObject]
          let isIncluded = dict["Included"] as! String
          let userID = dict["UserID"] as! String
          let partipant = Participant(userID: userID, isIncluded: isIncluded)
          allParticipants.append(partipant)
        }

        allParticipants = sorted(allParticipants)
        dispatch_async(dispatch_get_main_queue()) {
          self.currentTableView.reloadData()
        }
    } else {
      if (allParticipants.count == 0) {
        dispatch_async(dispatch_get_main_queue()) {
          self.noParticipantsLabel.hidden = false
          self.currentTableView.hidden = true
          self.done.enabled = false
          self.selection_note.hidden = true
        }
      }
    }
  }
  
  func network_error( error: NSError) -> Void {
    commonHandler()
    dispatch_async(dispatch_get_main_queue()) {
      self.showMessage("Network error",
        message: "Code: \(error.code)\n\(error.localizedDescription)")
    }
  }
  
  func service_error(response: NSHTTPURLResponse) -> Void {
    commonHandler()
    dispatch_async(dispatch_get_main_queue()) {
      self.showMessage("Webservice Error",
        message: "Error received from webservice: \(response.statusCode)")
    }
  }
  private func showMessage(title:String, message: String) {
    let alert = UIAlertController(title: title, message: message,
      preferredStyle: .Alert)
    let action = UIAlertAction(title: "Ok", style: .Default, handler: {
      action in
//     self.navigationController?.popViewControllerAnimated(true)
      self.dismissViewControllerAnimated(false,completion: nil)
    })
    alert.addAction(action)
    presentViewController(alert, animated: true, completion: nil)
  }
  
  func selectionSaveSuccess(data: NSData) -> Void {
    commonHandler()
    dispatch_async(dispatch_get_main_queue()) {
      let hudMessage = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
      hudMessage.mode = MBProgressHUDMode.Text
      hudMessage.labelText = "Saved..."
      hudMessage.hide(true, afterDelay: 0.7)
      hudMessage.opacity = 0.25
      hudMessage.yOffset = Float(self.view.frame.size.height/2 - 100)
    }
  }
  
  func selectionNetworkError( error: NSError) -> Void {
    commonHandler()
    dispatch_async(dispatch_get_main_queue()) {
      self.showMessage("Network error",
        message: "Code: \(error.code)\n\(error.localizedDescription)")
    }
  }
  
  func selectionServiceError(response: NSHTTPURLResponse) -> Void {
    commonHandler()
    dispatch_async(dispatch_get_main_queue()) {
      self.showMessage("Webservice Error",
        message: "Error received from webservice: \(response.statusCode)")
    }
  }
  
  private func saveToWebService(data: NSData, operation: String) {
    println("Operation:  \(operation)")
    let nc = NetworkCommunication()
    nc.postData(operation, data: data,
      successHandler: selectionSaveSuccess,
      serviceErrorHandler: selectionServiceError,
      errorHandler: selectionNetworkError)
  }
  
  private func getFormData() -> [String: AnyObject] {
    var prospect = [String: AnyObject]()
    prospect["ConfDateStart"] = DateHandler.getDBDate(fromDate)
    prospect["ConfDateEnd"] = DateHandler.getDBDate(toDate)
    if let id = prospectID {
      prospect["ProspectID"] = id
    }
    return prospect
  }

  func saveProspectSuccess(data: NSData) -> Void {
    commonHandler()
    dispatch_async(dispatch_get_main_queue()) {
      self.showMessage("Data saved",
        message: "Data saved succesfully.")
    }
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
  
  private func updateProspectToWebService(operation: String) {
    var prospect = getFormData()
    saveProspectToWebService(prospect, method:operation)
  }
  
  private func stylizeCell(cell: UITableViewCell, index: Int) {
    if index % 2 != 0 {
      cell.backgroundColor = Theme.Prospects.cellBGOddCell
      tableView.backgroundColor = Theme.Prospects.cellBGEvenCell
    } else {
      cell.backgroundColor = Theme.Prospects.cellBGEvenCell
      tableView.backgroundColor = Theme.Prospects.cellBGOddCell
    }
    cell.textLabel?.backgroundColor = UIColor.clearColor()
    cell.detailTextLabel?.backgroundColor = UIColor.clearColor()
  }


  // MARK: Delegate Functions
  func dateSelectorDidFinish(controller: DateSelector, type: String?) {
    if let type = type {
      if type == "From" {
        fromDate = controller.datePicker.date
        from_date_label.text = DateHandler.getPrintDate(fromDate)
      } else if type == "To" {
        toDate = controller.datePicker.date
        to_date_label.text = DateHandler.getPrintDate(toDate)
        duration_label.text = Int(((toDate.timeIntervalSince1970 - fromDate.timeIntervalSince1970) / 60)).description + " minutes"
      }
    }
  }

  func convertClientFinish() {
    dispatch_async(dispatch_get_main_queue()) {
      let hudMessage = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
      hudMessage.mode = MBProgressHUDMode.Text
      hudMessage.labelText = "Save successful"
      hudMessage.hide(true, afterDelay: 1.5)
      hudMessage.opacity = 0.4
      hudMessage.yOffset = Float(self.view.frame.size.height/2 - 100)
    }
    dismissViewControllerAnimated(true, completion: nil)
  }

}

//
//  AllClients.swift
//  PreSales-Huddle
//
//  Created by Himanshu Phirke on 28/07/15.
//  Copyright (c) 2015 synerzip. All rights reserved.
//

import UIKit

class AllClients: UITableViewController {
  var hud:MBProgressHUD?
  var allClients = [[String: AnyObject]]()
  let viewAllURL = "prospect/view/"
  let prospectName = "Name"

  // MARK: View Functions
  
  override func viewDidLoad() {
    stylizeControls()
    self.refreshControl = UIRefreshControl()
    self.refreshControl?.backgroundColor = Theme.Clients.RefreshControlBackground
    self.refreshControl?.tintColor = Theme.Clients.RefreshControl
    self.refreshControl?.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    fetchData()
  }
  // MARK: action functions
  @IBAction func logout(sender: UIBarButtonItem) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  // MARK: tableView Functions
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return allClients.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCellWithIdentifier("client-id") as! UITableViewCell
    let client = allClients[indexPath.row] as [String: AnyObject]
    populateCellData(cell, withProspectDictionary: client)
    stylizeCell(cell, index: indexPath.row)
    return cell
  }
  
  func refresh(sender:AnyObject) {
    fetchData()
  }

  
  // MARK: Internal Functions
  private func stylizeCell(cell: UITableViewCell, index: Int) {
    if index % 2 != 0 {
      cell.backgroundColor = Theme.Clients.cellBGOddCell
      tableView.backgroundColor = Theme.Clients.cellBGEvenCell
    } else {
      cell.backgroundColor = Theme.Clients.cellBGEvenCell
      tableView.backgroundColor = Theme.Clients.cellBGOddCell
    }
    cell.textLabel?.backgroundColor = UIColor.clearColor()
    cell.detailTextLabel?.backgroundColor = UIColor.clearColor()
  }

  private func stylizeControls() {
    navigationController?.navigationBar.backgroundColor = Theme.Clients.navBarBG
    tableView.separatorColor = Theme.Clients.tableViewSeparator
    tableView.backgroundColor = Theme.Clients.cellBGOddCell
  }

  private func populateCellData(cell: UITableViewCell,
    withProspectDictionary client: [String: AnyObject]) {
      if let name = client[prospectName] as? String {
        cell.textLabel?.text = name
        if let buHead = client["BUHead"] as? String {
          if let size = client["TeamSize"] as? Int {
            cell.detailTextLabel!.text = "Team Size: \(size) BU Head: \(buHead)"
            cell.detailTextLabel!.textColor = Theme.Clients.detailText
          } else {
            cell.detailTextLabel!.text = ""
          }
        }
      }
  }
  
  private func commonHandler() {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    dispatch_async(dispatch_get_main_queue()) {
      self.hud?.hide(true)
      self.refreshControl?.endRefreshing()
    }

  }
  func fetch_success(data: NSData) -> Void {
    commonHandler()
    var error: NSError?
    if let dict_array = NSJSONSerialization.JSONObjectWithData(data,
      options: NSJSONReadingOptions.MutableContainers, error: &error) as? [AnyObject] {
        allClients = []
        for item in dict_array  {
          let dict = item as! [String: AnyObject]
          if let teamSize = dict["TeamSize"] as? Int {
            if teamSize > 0 {
              allClients.append(dict)
            }
          }
        }
    }
    
    dispatch_async(dispatch_get_main_queue()) {
      self.tableView.reloadData()
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
    let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
    alert.addAction(action)
    presentViewController(alert, animated: true, completion: nil)
  }


  private func fetchData() {
    dispatch_async(dispatch_get_main_queue()) {
      self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
      self.hud?.labelText = "Loading.."
    }
    let nc = NetworkCommunication()
    let retValue = nc.fetchData(viewAllURL,
      successHandler: fetch_success, serviceErrorHandler: service_error,
      errorHandler: network_error)
  }

  // MARK: Segue Functions
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let targetController = segue.destinationViewController as! UINavigationController
    let targetView = targetController.topViewController as! Client
    if segue.identifier == "viewClient" {
      if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
        targetView.itemToView = allClients[indexPath.row]
      }
    }
  }
  
}

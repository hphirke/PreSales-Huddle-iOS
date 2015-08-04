//
//  Reports.swift
//  PreSales-Huddle
//
//  Created by Sachin Avhad on 25/07/15.
//  Copyright (c) 2015 synerzip. All rights reserved.
//

import Foundation

class Reports: UITableViewController {
  let viewAllURL = "prospect/view/"
  var data = [ "Domains", "TechStacks"]
  private var techStackData_ = Dictionary<String, PieChartData>()
  private var domainData_ = Dictionary<String, PieChartData>()

  override func viewDidLoad() {
    super.viewDidLoad()
    stylizeControls()
    self.refreshControl = UIRefreshControl()
    self.refreshControl?.backgroundColor = Theme.Reports.RefreshControlBackground
    self.refreshControl?.tintColor = Theme.Reports.RefreshControl
    self.refreshControl?.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    clear()
    fetchData()
  }
  
  func clear() {
    techStackData_.removeAll(keepCapacity: true)
    domainData_.removeAll(keepCapacity: true)
  }
  
  // MARK: Outlets
  
  // MARK: action functions
  @IBAction func logout(sender: UIBarButtonItem) {
    dismissViewControllerAnimated(true, completion: nil)
  }

  // MARK: - UITableViewDataSource
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return data.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("ReportCell", forIndexPath: indexPath) as! UITableViewCell
    cell.textLabel?.text = data[indexPath.row]
    stylizeCell(cell, index: indexPath.row)
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
  
  // MARK: Segue Functions
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let targetController = segue.destinationViewController as! UINavigationController
    let chartTableViewController = targetController.topViewController as! Charts
    
    var type = "Unknown"
    if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
      type = data[indexPath.row]
    }
    if (type == "TechStacks") {
      chartTableViewController.title = type
      chartTableViewController.pieChartData = techStackData_
    } else if (type == "Domains") {
      chartTableViewController.title = type
      chartTableViewController.pieChartData = domainData_
    }
  }
  
  // MARK: Internal Functions
  func refresh(sender:AnyObject) {
    fetchData()
  }

  private func stylizeCell(cell: UITableViewCell, index: Int) {
    if index % 2 != 0 {
      cell.backgroundColor = Theme.Reports.cellBGOddCell
      tableView.backgroundColor = Theme.Reports.cellBGEvenCell
    } else {
      cell.backgroundColor = Theme.Reports.cellBGEvenCell
      tableView.backgroundColor = Theme.Reports.cellBGOddCell
    }
    cell.textLabel?.backgroundColor = UIColor.clearColor()
  }

  private func stylizeControls() {
    navigationController?.navigationBar.backgroundColor = Theme.Reports.navBarBG
    tableView.separatorColor = Theme.Reports.tableViewSeparator
    tableView.backgroundColor = Theme.Reports.cellBGOddCell
  }

  
  private func camelCaseString(source:String) ->String {
    if (source.isEmpty) {
      return ""
    }
    var result:String = ""
    var value = source.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    let separated = split(value, allowEmptySlices: false, isSeparator: {$0==" "})
    for key in separated {
      var first = key.substringToIndex(advance(value.startIndex, 1)).uppercaseString
      let rest = dropFirst(key).lowercaseString
      if (result.isEmpty == false) {
        result += " "
      }
      result += first + rest
    }
    return result
  }
  
  private func populateTeckStack(techValue:String) {
    if (techValue.isEmpty) {
      return;
    }
    let separated = split(techValue, allowEmptySlices: false, isSeparator: {$0==","})
    for source in separated {
      var key  = camelCaseString(source)
      if let value = techStackData_[key] {
        techStackData_[key]!.count_++
      } else {
        techStackData_[key] = PieChartData(key: key, count: 1, selected: false)
      }
      // println("Key \(key) : \(techStackData_[key]?.count_)")
    }
  }
  
  private func populateDomain(domainValue:String) {
    if (domainValue.isEmpty) {
      return;
    }
    let separated = split(domainValue, allowEmptySlices: false, isSeparator: {$0==","})
    for source in separated {
      var key  = camelCaseString(source)
      if let value = domainData_[key] {
        domainData_[key]!.count_++
      } else {
        domainData_[key] = PieChartData(key: key, count: 1, selected: false)
      }
      // println("Key \(key) : \(domainData_[key]?.count_)")
    }
  }
  
  private func doSorting() {
    
  }
  // Network APIs
  
  private func commonHandler() {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    dispatch_async(dispatch_get_main_queue()) {
      self.refreshControl?.endRefreshing()
    }
  }
  
  func fetch_success(data: NSData) -> Void {
    commonHandler()
    var error: NSError?
    if let dict_array = NSJSONSerialization.JSONObjectWithData(data,
      options: NSJSONReadingOptions.MutableContainers, error: &error) as? [AnyObject] {
        for item in dict_array  {
          let dict = item as! [String: AnyObject]
          let teamSize = dict["TeamSize"] as! Int
          // if (teamSize > 0) {
          let teckStack = dict["TechStack"] as! String
          populateTeckStack(teckStack)
          let domain = dict["Domain"] as! String
          populateDomain(domain)
          // }
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
  
  func showMessage(title:String, message: String) {
    let alert = UIAlertController(title: title, message: message,
      preferredStyle: .Alert)
    let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
    alert.addAction(action)
    presentViewController(alert, animated: true, completion: nil)
  }
  
  func fetchData() {
    let nc = NetworkCommunication()
    let retValue = nc.fetchData(viewAllURL,
      successHandler: fetch_success, serviceErrorHandler: service_error,
      errorHandler: network_error)
  }
  
}
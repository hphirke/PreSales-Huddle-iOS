//
//  Discussions.swift
//  PreSales-Huddle
//
//  Created by Vinaya Mandke on 22/07/15.
//  Copyright (c) 2015 synerzip. All rights reserved.
//

import UIKit

class Discussions: UITableViewController {
  
  
  // MARK: Class variables
  var prospectID = -1 {
    didSet {
      fetchData()
    }
  }
  
  let viewAllQA = "discussion/view/prospectid/"
  let updateQA = "discussion/update/"
  let addQURL = "discussion/add/"
  var tableData = [String]();
  var allQAs = [[String: AnyObject]]()
  var cachedAnswers = [Int: String]()
  var arrayForBool = [Bool]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.scrollEnabled = true
    tableView.bounces = false
    fetchData()
    stylize()
    stylizeControls()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  @IBAction func addAQuestion(sender: UIBarButtonItem) {
    cacheAnswers()
    let alert = UIAlertController(title: "Ask a Question", message: "", preferredStyle: UIAlertControllerStyle.Alert)
    alert.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
      textField.placeholder = "Enter a Question"
    }
    let defaultAction = UIAlertAction(title: "Submit", style: .Default, handler: { (action:UIAlertAction!) -> Void in
      if let questionField = alert.textFields?.first as? UITextField {
        let question = questionField.text
        
        // Take user id from NSDefaults; currently defaulting to "USER1"
        var userID = "Unknown"
        if let id = NSUserDefaults.standardUserDefaults().stringForKey("userID") {
          userID = id
        }
        var dataStore : [String:AnyObject] = ["UserID": userID, "ProspectID": self.prospectID,"Query":"\(question)"]
        var err: NSError?
        let dataEncoded = NSJSONSerialization.dataWithJSONObject(dataStore, options: nil, error: &err)
        self.postUpdate(dataEncoded!, url: self.addQURL)
      }
    })
    let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
    
    alert.addAction(cancelAction)
    alert.addAction(defaultAction)
    presentViewController(alert, animated: true, completion: nil)
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    // #warning Potentially incomplete method implementation.
    // Return the number of sections.
    return allQAs.count
  }
  
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
    
    if(arrayForBool.count > section && arrayForBool[section])
    {
      //TODO: (vinaya.mandke) as of now only one answer per question
      return 1
    }
    return 0;
  }
  
  override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    // Height for table cell is predetermined
    // try and calculate it here:-
    if allQAs.count > section {
      let qa = allQAs[section] as [String: AnyObject]
      if let query = qa["Query"] as? String {
        let attrs = [NSFontAttributeName:UIFont.systemFontOfSize(UIFont.systemFontSize())]
        let size = (query as NSString).sizeWithAttributes(attrs)
        return size.height + 40
      }
    }
    return UITableViewAutomaticDimension
    //        return 50
  }
  
  override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 1
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if(arrayForBool[indexPath.section]){
      // Height for table cell is predetermined
      // try and calculate it here:-
      if allQAs.count > indexPath.section {
        let qa = allQAs[indexPath.section] as [String: AnyObject]
        if let answer = qa["Answer"] as? String {
          if answer.isEmpty {
            return 90
          } else {
            let attrs = [NSFontAttributeName:UIFont.systemFontOfSize(UIFont.systemFontSize())]
            let size = (answer as NSString).sizeWithAttributes(attrs)
            return max(size.height,70)
          }
        }
      }
      
      
      return UITableViewAutomaticDimension
    }
    
    return 1;
  }
  
  
  override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    
    let hVWidth = tableView.frame.size.width
    let hvHeight =  CGFloat(40)
    
    let headerView = UIView(frame: CGRectMake(0, 0, hVWidth, hvHeight))
    headerView.backgroundColor = Theme.Prospects.cellBGEvenCell
    headerView.tag = section
    
    if let image = UIImage(named: "question_tag") {
      let imageView = UIImageView(frame: CGRect(x: 10, y: 11, width: 25, height: hvHeight - 15))
      imageView.image = image
      headerView.addSubview(imageView)
    }
    
    let headerString = UILabel(frame: CGRect(x: 40, y: 10, width: hVWidth-50, height: hvHeight - 10)) as UILabel
    if allQAs.count > section {
      let qa = allQAs[section] as [String: AnyObject]
      if let query = qa["Query"] as? String {
        headerString.text = query
        headerString.textColor = UIColor.brownColor()
      }
      if let answer = qa["Answer"] as? String {
        if answer.isEmpty {
          let unansweredLabel = UILabel(frame: CGRectMake(40, 0, 75, 15))
          unansweredLabel.text = "Unanswered"
          unansweredLabel.textColor = UIColor.redColor()
          unansweredLabel.font = UIFont.systemFontOfSize(10)
          headerView.addSubview(unansweredLabel)
        }
      }
    }
    headerView.addSubview(headerString)
    
    let headerTapped = UITapGestureRecognizer (target: self, action:"sectionHeaderTapped:")
    headerView .addGestureRecognizer(headerTapped)
    styleTheView(headerView)
    return headerView
  }
  
  func sectionHeaderTapped(recognizer: UITapGestureRecognizer) {
    cacheAnswers()
    
    var indexPath : NSIndexPath = NSIndexPath(forRow: 0, inSection:(recognizer.view?.tag as Int!)!)
    if (indexPath.row == 0) {
      var collapsed = arrayForBool[indexPath.section]
      collapsed       = !collapsed;
      arrayForBool[indexPath.section] = collapsed
      
      //reload specific section animated
      var range = NSMakeRange(indexPath.section, 1)
      var sectionToReload = NSIndexSet(indexesInRange: range)
      self.tableView.reloadSections(sectionToReload, withRowAnimation:UITableViewRowAnimation.Fade)
    }
    
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = UITableViewCell()
    let qa = allQAs[indexPath.section] as [String: AnyObject]
    
    //TODO (vinaya.mandke) currently if no ans provided answer is provided as empty string
    if let query = qa["Answer"] as? String {
      if query != "" {
        
        cell.textLabel?.text = query
        cell.textLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.preferredMaxLayoutWidth = tableView.frame.size.width
        cell.textLabel?.sizeToFit()
        if let labelFrame = cell.textLabel?.frame {
          cell.frame = labelFrame
        }
        cell.sizeToFit()
        print(cell.textLabel?.frame.size.height)
        print(cell.frame.size.height)
        
      } else {
        let answerblock = UITextView(frame: CGRect(x: 10, y: 10, width: tableView.frame.size.width-20, height: cell.bounds.height)) as UITextView
        answerblock.layer.borderWidth = 2
        answerblock.layer.borderColor = UIColor.grayColor().CGColor
        answerblock.layer.cornerRadius = 5.0
        let postButton = UIButton(frame: CGRect(x: 10, y: 60, width: 50, height: 20))
        // tag button with section id
        postButton.tag = indexPath.section + 1
        answerblock.tag = indexPath.section + 1
        postButton.setTitle("POST", forState: UIControlState.Normal)
        postButton.backgroundColor = Theme.Prospects.cellBGEvenCell
        postButton.setTitleColor(UIColor.brownColor(), forState: UIControlState.Normal)
        postButton.titleLabel?.font = UIFont.systemFontOfSize(CGFloat(10))
        postButton.layer.cornerRadius = 1.0
        postButton.addTarget(self, action: "postAnswer:", forControlEvents: UIControlEvents.TouchUpInside)
        
        styleTheView(answerblock)
        styleTheView(postButton)
        
        cell.addSubview(answerblock)
        cell.addSubview(postButton)
        cell.sizeToFit()
        
        // try to get cached answer value
        if let discussionID = qa["DiscussionID"] as? Int {
          if let cachedValue = cachedAnswers[discussionID] {
            answerblock.text = cachedValue
            // remove the cached value
            cachedAnswers[discussionID] = nil
          }
        }
      }
      
    }
    styleTheView(cell)
    return cell
  }
  
  func postAnswer(sender: UIButton) {
    // POST the answer to API use sender.tag as identifier in allQAs
    NSLog("hello \(sender.tag)")
    let sectionID = sender.tag - 1
    let answerView = tableView.viewWithTag(sender.tag) as? UITextView
    let answer = answerView?.text
    if (answer != nil && !answer!.isEmpty) {
      let alert = UIAlertController(title: "Preview Answer", message: answer!, preferredStyle: UIAlertControllerStyle.Alert)
      
      let submitActionHandler = { (action:UIAlertAction!) -> Void in
        //POST the discussion
        let qa = self.allQAs[sectionID] as [String: AnyObject]
        
        if let discussionID = qa["DiscussionID"] as? Int {
          var dataStore : [String:AnyObject] = ["DiscussionID":discussionID,"Answer":"\(answer!)"]
          var err: NSError?
          let dataEncoded = NSJSONSerialization.dataWithJSONObject(dataStore, options: nil, error: &err)
          self.postUpdate(dataEncoded!, url: self.updateQA)
        }
        var range = NSMakeRange(sectionID, 1)
        var sectionToReload = NSIndexSet(indexesInRange: range)
        dispatch_async(dispatch_get_main_queue()) {
          var collapsed = self.arrayForBool[sectionID]
          collapsed       = !collapsed;
          self.arrayForBool[sectionID] = collapsed
          self.tableView.reloadSections(sectionToReload, withRowAnimation:UITableViewRowAnimation.Fade)
        }
      }
      
      let defaultAction = UIAlertAction(title: "Submit", style: .Default, handler: submitActionHandler)
      let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: {(action:UIAlertAction!) -> Void in
        self.cacheAnswers()
        var range = NSMakeRange(sectionID, 1)
        var sectionToReload = NSIndexSet(indexesInRange: range)
        dispatch_async(dispatch_get_main_queue()) {
          var collapsed = self.arrayForBool[sectionID]
          collapsed       = !collapsed;
          self.arrayForBool[sectionID] = collapsed
          self.tableView.reloadSections(sectionToReload, withRowAnimation:UITableViewRowAnimation.Fade)
        }
      })
      alert.addAction(cancelAction)
      alert.addAction(defaultAction)
      presentViewController(alert, animated: true, completion: nil)
      
    }
  }
  
  private func commonHandler() {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
  }
  func service_success(data: NSData) -> Void {
    commonHandler()
    var error: NSError?
    if let dict_array = NSJSONSerialization.JSONObjectWithData(data,
      options: NSJSONReadingOptions.MutableContainers, error: &error) as? [AnyObject] {
        allQAs.removeAll(keepCapacity: true)
        for item in dict_array  {
          let dict = item as! [String: AnyObject]
          allQAs.append(dict)
        }
        for _ in (0...allQAs.count-1) {
          arrayForBool.append(false)
        }
    }
    dispatch_async(dispatch_get_main_queue()) {
      self.tableView.reloadData()
    }
  }
  
  
  func service_success_post(data: NSData) -> Void {
    commonHandler()
    fetchData()
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
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    let nc = NetworkCommunication()
    let retValue = nc.fetchData(viewAllQA + "\(prospectID)",
      successHandler: service_success, serviceErrorHandler: service_error,
      errorHandler: network_error)
  }
  
  func postUpdate(dataEncoded: NSData, url: String) {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    let nc = NetworkCommunication()
    let retValue = nc.postData(url,
      data: dataEncoded,
      successHandler: service_success_post, serviceErrorHandler: service_error,
      errorHandler: network_error)
  }
  
  func cacheAnswers() {
    let count = allQAs.count
    if count > 0 {
      for i in (1...count) {
        let answerView = tableView.viewWithTag(i) as? UITextView
        let answer = answerView?.text
        if (answer != nil && !answer!.isEmpty) {
          let qa = self.allQAs[i-1] as [String: AnyObject]
          if let discussionID = qa["DiscussionID"] as? Int {
            cachedAnswers[discussionID] = answer!
          }
        }
      }
    }
  }
  
  // MARK: styles
  
  
  struct Appearance {
    static var includeBlur = true
    static var tintColor = UIColor(red: 0.0, green: 120 / 255.0, blue: 255 / 255.0, alpha: 1.0)
    static var backgroundColor = UIColor.whiteColor()
    static var textViewFont = UIFont.systemFontOfSize(17.0)
    static var textViewTextColor = UIColor.darkTextColor()
    static var textViewBackgroundColor = UIColor.whiteColor()
  }
  
  func styleTheView(textView: UIView) {
    textView.layer.rasterizationScale = UIScreen.mainScreen().scale
    textView.layer.shouldRasterize = true
    textView.layer.cornerRadius = 5.0
    textView.layer.borderWidth = 1.0
    textView.layer.borderColor = UIColor(white: 0.0, alpha: 0.2).CGColor
  }
  func stylize() {
    tableView.backgroundColor = Appearance.textViewBackgroundColor
    tableView.tintColor = Appearance.tintColor
    tableView.backgroundColor = Appearance.backgroundColor
  }
  func applyGradient(cellView: UIView) {
    var mGradient : CAGradientLayer = CAGradientLayer()
    mGradient.frame = cellView.bounds
    mGradient.frame.origin = CGPointMake(0.0,0.0)
    
    var colors = [CGColor]()
    colors.append(UIColor(red: 255, green: 255, blue: 204, alpha: 1).CGColor)
    colors.append(UIColor(red: 255 , green: 255, blue: 255, alpha: 0).CGColor)
    mGradient.colors = colors
    mGradient.locations = [0.0 , 1.0]
    mGradient.startPoint = CGPointMake(0.1, 0.5)
    mGradient.endPoint = CGPointMake(0.9, 0.5)
    mGradient.frame = CGRect(x: 0.0, y: 0.0, width: cellView.frame.size.width, height: cellView.frame.size.height)
    cellView.layer.insertSublayer(mGradient, atIndex: 0)
  }
    private func stylizeControls() {
        navigationController?.navigationBar.backgroundColor = Theme.Prospects.navBarBG
        tableView.separatorColor = Theme.Prospects.tableViewSeparator
        tableView.backgroundColor = Theme.Prospects.cellBGOddCell
    }
}

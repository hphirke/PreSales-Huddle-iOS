//
//  ViewController.swift
//  CorePlotTest
//
//  Created by Sachin Avhad on 20/07/15.
//  Copyright (c) 2015 Sachin Avhad. All rights reserved.
//

import UIKit

class Charts: UITableViewController, CPTPlotDataSource, CPTPieChartDataSource, CPTBarPlotDelegate {
  
  @IBOutlet weak var graphView:CPTGraphHostingView!
  var pieChartData = Dictionary<String, PieChartData>()
  var keys = [String]()
  var selectedKeys = [String]()
  var selectedValueCount:Int = 0
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.keys = sorted(Array(pieChartData.keys))
  }
  
  override func viewDidLoad() {
    stylizeControls()
  }
  // MARK: Internal Functions
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
  
  @IBAction func BackToReports(sender: UIBarButtonItem) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return pieChartData.count
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
    if let cell = tableView.cellForRowAtIndexPath(indexPath) {
      if (cell.accessoryType == UITableViewCellAccessoryType.None) {
        cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        let key = keys[indexPath.row]
        pieChartData[key]?.selected_ = true
      } else {
        cell.accessoryType = UITableViewCellAccessoryType.None
        let key = keys[indexPath.row]
        pieChartData[key]?.selected_ = false
      }
    }
    tableView.deselectRowAtIndexPath(indexPath, animated:false)
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("ChartCell", forIndexPath: indexPath) as! UITableViewCell
    if (indexPath.row < keys.count) {
      cell.textLabel?.text = self.keys[indexPath.row]
    }
    stylizeCell(cell, index: indexPath.row)
    cell.accessoryType = UITableViewCellAccessoryType.Checkmark
    let key = keys[indexPath.row]
    pieChartData[key]?.selected_ = true
    return cell
  }
  
  
  func numberOfRecordsForPlot(plot: CPTPlot!) -> UInt {
    return UInt(selectedKeys.count);
  }
  
  func numberForPlot(plot: CPTPlot!, field fieldEnum: UInt, recordIndex idx: UInt) -> AnyObject! {
    var index = Int(idx)
    
    if (index < selectedKeys.count) {
      return pieChartData[selectedKeys[index]]?.count_
    }
    return ""
  }
  
  func dataLabelForPlot(plot: CPTPlot!, recordIndex idx: UInt) ->CPTLayer! {
    let index = Int(idx)
    if (index >= selectedKeys.count) {
      return nil
    }
    let key = selectedKeys[index]
    let count:Double = Double(pieChartData[key]!.count_)
    let percent:Double = count * 100.0 / Double(selectedValueCount)
    let label = String(format: "%.1f", percent) + "%"
    var textStyle = CPTMutableTextStyle()
    textStyle.color = CPTColor.blackColor()
    textStyle.fontSize = 15.0
    var textLayer = CPTTextLayer(text: label, style: textStyle)
    return textLayer
  }
  func legendTitleForPieChart(pieChart:CPTPieChart!, recordIndex idx:UInt) ->String! {
    let index = Int(idx)
    if (index >= selectedKeys.count) {
      return nil
    }
    
    return selectedKeys[index]
  }
  
  // MARK: CPTBarPlotDelegate Functions
  func barPlot(plot:CPTBarPlot!, barWasSelectedAtRecordIndex index:UInt) -> Void {
  }
  
  // MARK: Segue Functions
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    self.selectedKeys.removeAll()
    self.selectedValueCount = 0
    for key in pieChartData.keys {
      if (pieChartData[key]?.selected_ == true) {
        self.selectedKeys.append(key)
        self.selectedValueCount += pieChartData[key]!.count_
      }
    }
    let targetController = segue.destinationViewController as! UINavigationController
    let pieChartViewController = targetController.topViewController as! PieChart
    pieChartViewController.delegate = self
    pieChartViewController.title = "Historical Propects"
  }
  
  
}


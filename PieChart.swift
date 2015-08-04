//
//  PieChart.swift
//  PreSales-Huddle
//
//  Created by Sachin Avhad on 27/07/15.
//  Copyright (c) 2015 synerzip. All rights reserved.
//

import UIKit

class PieChart: UIViewController {
  @IBOutlet weak var graphView:CPTGraphHostingView!
  weak var delegate: Charts?
  override func viewDidLoad() {
    super.viewDidLoad()
    CreatePieChart()
  }
  
  @IBAction func Close(sender: UIBarButtonItem) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  func CreatePieChart() {
    var graph = CPTXYGraph(frame: self.graphView.bounds)
    graph.title = "Pie Chart"
    graph.paddingLeft = 0
    graph.paddingTop = 0
    graph.paddingRight = 0
    graph.paddingBottom = 0
    
    // hide the axes
    var axes = graph.axisSet as! CPTXYAxisSet
    var lineStyle = CPTMutableLineStyle()
    lineStyle.lineWidth = 0
    axes.xAxis.axisLineStyle = lineStyle
    axes.yAxis.axisLineStyle = lineStyle
    
    // add a pie plot
    var pie = CPTPieChart(frame: CGRectZero)
    pie.dataSource = delegate
    pie.pieRadius = (min(self.graphView.bounds.size.height, self.graphView.bounds.size.width) * 0.7)/2
    pie.labelOffset = 2
    graph.addPlot(pie)
    
    self.graphView.backgroundColor = UIColor.lightGrayColor()
    self.graphView.hostedGraph = graph
    
    // configure legend
    var theLegend = CPTLegend(graph: self.graphView.hostedGraph)
    theLegend.numberOfColumns = 1
    theLegend.fill = CPTFill(color:CPTColor.whiteColor())
    theLegend.borderLineStyle = CPTLineStyle()
    theLegend.cornerRadius = 5.0
    let anchor:CPTRectAnchor = .BottomRight
    self.graphView.hostedGraph.legendAnchor = anchor
    self.graphView.hostedGraph.legend = theLegend
    var legendPadding = -(self.view.bounds.size.width / 16)
    
    self.graphView.hostedGraph.legendDisplacement = CGPointMake(legendPadding, 0.0);
  }
  
}

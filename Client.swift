//
//  Client.swift
//  PreSales-Huddle
//
//  Created by Himanshu Phirke on 28/07/15.
//  Copyright (c) 2015 synerzip. All rights reserved.
//

import UIKit

class Client: UIViewController {
  var itemToView: [String: AnyObject]?
  
  
  @IBOutlet weak var name: UILabel!
  @IBOutlet weak var techStack: UILabel!
  @IBOutlet weak var domain: UILabel!
  @IBOutlet weak var buHead: UILabel!
  @IBOutlet weak var teamSize: UILabel!
  @IBOutlet weak var salesManager: UILabel!
  @IBOutlet weak var notes: UILabel!
  
  override func viewDidLoad() {
    stylizeControls()
    if let item = itemToView {
      showData(item)
    }
  }
  private func stylizeControls() {
    navigationController?.navigationBar.backgroundColor = Theme.Clients.navBarBG
    view.backgroundColor = Theme.Clients.formBG

    Theme.applyLabelBorder(name)
    name.backgroundColor = Theme.Clients.textFieldBG
    
    Theme.applyLabelBorder(techStack)
    techStack.backgroundColor = Theme.Clients.textFieldBG
    
    Theme.applyLabelBorder(domain)
    domain.backgroundColor = Theme.Clients.textFieldBG
    
    Theme.applyLabelBorder(buHead)
    buHead.backgroundColor = Theme.Clients.textFieldBG
    
    Theme.applyLabelBorder(teamSize)
    teamSize.backgroundColor = Theme.Clients.textFieldBG
    
    Theme.applyLabelBorder(salesManager)
    salesManager.backgroundColor = Theme.Clients.textFieldBG
    
    Theme.applyLabelBorder(notes)
    notes.backgroundColor = Theme.Clients.textFieldBG
  }
  private func showData(dict: [String: AnyObject]) {
    
    name.text = dict["Name"] as? String
    techStack.text = dict["TechStack"] as? String
    domain.text = dict["Domain"] as? String
    buHead.text = dict["BUHead"] as? String
    if let size = dict["TeamSize"] as? Int {
      teamSize.text = "\(size)"
    }
    salesManager.text = dict["SalesID"] as? String
    notes.text = dict["Notes"] as? String
  }
}

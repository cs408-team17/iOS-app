//
//  SettingTable.swift
//  WeGroup
//
//  Created by Hanqi Du on 2/12/16.
//  Copyright © 2016 WeGroup Inc. All rights reserved.
//

import UIKit

class SettingTableViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        self.navigationController?.navigationBarHidden = false
        self.title = "Setting"
        //self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView.tableFooterView = UIView()
        }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            onLogout()
        }
    }
    
    private func onLogout() {
        User.currentUser?.logOut()
        performSegueWithIdentifier("ToLogin", sender: nil)
    }
}


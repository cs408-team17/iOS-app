//
//  ContactsView.swift
//  WeGroup
//
//  Created by Darrell Shi on 2/26/16.
//  Copyright © 2016 WeGroup Inc. All rights reserved.
//

import UIKit
import Parse

class ContactsView: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onAddFriend(sender: AnyObject) {
        let alert = UIAlertController(title: "Add Friend", message: "Enter username", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler(nil)
        
        alert.addAction(UIAlertAction(title: "Send Request", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            if let username = textField.text {
                // check empty
                if username.isEmpty {
                    let emptyAlert = UIAlertController(title: "Please enter a username", message: nil, preferredStyle: .Alert)
                    emptyAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
                        self.onAddFriend("")
                    }))
                    self.presentViewController(emptyAlert, animated: true, completion: nil)
                }
                
                // check whether user exists
                let query = PFQuery(className: "_User")
                query.whereKey("username", equalTo: username)
                query.findObjectsInBackgroundWithBlock({ (result, error) -> Void in
                    if let friend = result?.first as? PFUser {
                        // check whether it is the current user
                        if friend.username == PFUser.currentUser()?.username {
                            self.popupMessage("Cannot add yourself")
                            return
                        }
                        // check if they are already freinds
                        if Data.contacts.contains(friend) {
                            self.popupMessage("You are already friends")
                            return
                        }
                        // send friend request
                        let relationship = PFObject(className: "Friendship")
                        relationship["user"] = PFUser.currentUser()!
                        relationship["friend"] = friend
                        
                        relationship.saveInBackgroundWithBlock({ (success, error) -> Void in
                            if success {
                                self.popupMessage("friend added")
                                Data.contacts.append(friend)
                                self.tableView.reloadData()
                            } else {
                                self.popupMessage("Failed to add friend")
                            }
                        })
                    } else {
                        self.popupMessage("Did not find any matching")
                    }
                })
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func popupMessage(message: String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

extension ContactsView: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Data.contacts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ContactCell") as! ContactCell
        cell.user = Data.contacts[indexPath.row]
        return cell
    }
}
//
//  ChatsView.swift
//  WeGroup
//
//  Created by Darrell Shi on 2/4/16.
//  Copyright © 2016 WeGroup Inc. All rights reserved.
//

import UIKit
import Parse

var timer = NSTimer()
let didReceiveNewMessage = "didReceiveNewMessage"

class ConversationsView: UIViewController {
    @IBOutlet var tableView: UITableView!
    var deleting = false
    
    @IBOutlet weak var searchBar: UISearchBar!
    var filteredConversations: [Conversation]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
                
        timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "onTimer", userInfo: nil, repeats: true)
        
        Data.loadConversationsFromLocalStorage { () -> Void in
            self.filteredConversations = Data.conversations
            self.tableView.reloadData()
        }
        Data.loadContactsFromLocalStorage(nil)
        Data.checkNewContacts(nil)
        onTimer()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        filteredConversations = Data.conversations
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func onTimer() {
        Data.checkNewMessages { () -> Void in
            self.filteredConversations = Data.conversations
            self.tableView.reloadData()
        }
    }
    
    @IBAction func onAddConversation(sender: AnyObject) {
        self.performSegueWithIdentifier("ToContactPicker", sender: nil)
    }
    
    @IBAction func onEdit(sender: AnyObject) {
        if deleting {
            self.navigationItem.leftBarButtonItem?.title = "Delete"
            deleting = false
        } else {
//            let numberOfRows = tableView.numberOfRowsInSection(0)
//            for row in 0...numberOfRows-1 {
//                let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: 0))!
//                let origin = cell.contentView.frame.origin
//                let deleteView = UIImageView(frame: CGRect(x: -20, y: 25, width: 20, height: 20))
//                deleteView.image = UIImage(named: "delete_button")
//                cell.contentView.addSubview(deleteView)
//                
//                UIView.animateWithDuration(0.3) { () -> Void in
//                    cell.contentView.frame.origin = CGPoint(x: origin.x+30, y: origin.y)
//                }
            self.navigationItem.leftBarButtonItem?.title = "Cancel"
            deleting = true
//            }
        }
    }
    
    func onDeleteConversation(gesture: UITapGestureRecognizer) {
        gesture.view?.backgroundColor = UIColor.blackColor()
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ToChat" {
            searchBarCancelButtonClicked(searchBar)
            let indexPath = sender as! NSIndexPath
            let vc = segue.destinationViewController as! MessageView
            vc.conversation = filteredConversations![indexPath.row]
        }
    }
}

extension ConversationsView: UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let conversations = filteredConversations {
            return conversations.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ChatCell") as! ConversationCell
        cell.conversation = filteredConversations![indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if deleting {
            _managedObjectContext.deleteObject(Data.conversations[indexPath.row])
            Data.conversations.removeAtIndex(indexPath.row)
            filteredConversations?.removeAtIndex(indexPath.row)
            tableView.reloadData()
        } else {
            self.performSegueWithIdentifier("ToChat", sender: indexPath)
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if let searchText = searchBar.text {
            if searchText == "" {
                filteredConversations = Data.conversations
            } else {
                filteredConversations = Data.conversations.filter({ (conversation) -> Bool in
                    for user in conversation.toUsers {
                        let contact = user as! Contact
                        let username = contact.username
                        if username.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) == nil {
                            continue
                        } else {
                            return true
                        }
                    }
                    return false
                })
            }
        }
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filteredConversations = Data.conversations
        tableView.reloadData()
    }
}

//
//  UserSearchViewController.swift
//  MakeChat
//
//  Created by Brian Hans on 7/6/16.
//  Copyright © 2016 Brian Hans. All rights reserved.
//

import UIKit


class UserSearchViewController: UIViewController{
    var users: [User]?
    
    var usersInChat: [User]!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        users = []
        FirebaseHelper.getUsers { (user: User, status: FirebaseHelper.snapshotStatus) in
            switch status{
            case .Added:
                if(user != FirebaseHelper.currentUser){
                    FirebaseHelper.getOnline(user, completionHandler: { (online: Bool) in
                        if(online){
                            user.online = true
                        }
                        
                        if(!self.usersInChat.contains(user)){
                            self.users?.append(user)
                            self.tableView.reloadData()
                        }
                    })
                }
            case .Removed:
                print("other case")
            case .Updated:
                print("nope")
            }
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "searchToChat"){
            let destination = segue.destinationViewController as! ChatViewController
            FirebaseHelper.getChat(users![tableView.indexPathForSelectedRow!.row], completionHandler: { (chat: Chat) in
                destination.setUp(chat)
            })
        }
    }
}

extension UserSearchViewController: UITableViewDataSource{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserCell") as! UserCell
        cell.usernameLabel.text = users![indexPath.row].username
        if(users![indexPath.row].online){
            cell.backgroundColor = UIColor.greenColor()
        }
        return cell
    }
}


extension UserSearchViewController: UISearchBarDelegate{
    func searchBarTextDidBeginEditing(searchBar: UISearchBar){
        search(searchBar.text!)
    }
    
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = ""
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        search(searchBar.text!)
        
    }
    
    func search(term: String){
        FirebaseHelper.searchUser(term){ (results: [User]) in 
            self.users = results.filter{!self.usersInChat.contains($0) && $0 != FirebaseHelper.currentUser}
            self.tableView.reloadData()
        }
    }
}
//
//  ChatsListViewController.swift
//  MakeChat
//
//  Created by Brian Hans on 7/5/16.
//  Copyright © 2016 Brian Hans. All rights reserved.
//

import UIKit

class ChatsListViewController: UITableViewController{
    
    var chats: [Chat] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        FirebaseHelper.watchChats { (chat: Chat, status) in
            switch status{
            case .Added:
                print("Adding: " + chat.otherUser.username)
                chat.otherUser.statusUpdate = self.updateTableView
                self.chats.insert(chat, atIndex: 0)
                self.tableView.reloadData()
            case .Removed:
                print("Removing: " + chat.otherUser.username)
                self.chats = self.chats.filter{$0 != chat}
                self.tableView.reloadData()
            case .Updated:
                
                //Keep the reference to the users and chatId, but update the values
                for (index, oldChat) in self.chats.enumerate(){
                    if (oldChat == chat){
                        oldChat.timestamp = chat.timestamp
                        oldChat.myMessage = chat.myMessage
                        oldChat.otherUserMessage = chat.otherUserMessage
                        
                        let newChat = oldChat
                        self.chats.removeAtIndex(index)
                        self.chats.insert(newChat, atIndex: 0)
                        break
                    }
                }
                
                self.tableView.reloadData()
                
            }
        }
        
        
    }
    
    func updateTableView(){
        tableView.reloadData()
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Chat")! as! ChatsListItem
        cell.nameLabel.text = self.chats[indexPath.row].otherUser.username
        cell.previewText.text = self.chats[indexPath.row].otherUserMessage
        
        var color: CGColor
        if(self.chats[indexPath.row].otherUser.online){
            color = UIColor.greenColor().CGColor
        }else{
            color = UIColor.redColor().CGColor
        }
        
        cell.profilePicture.layer.borderWidth = 1
        cell.profilePicture.layer.borderColor = color
        cell.profilePicture.layer.cornerRadius = cell.profilePicture.frame.width/2
        cell.profilePicture.layer.masksToBounds = true
        
        cell.profilePicture.image = UIImage(named: "profile-placeholder")!
        cell.downloadImage(chats[indexPath.row].otherUser)
        
        return cell;
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == .Delete){
            print("delete")
            let chat = chats[indexPath.row]
            FirebaseHelper.deleteChat(chat)
            chats.removeAtIndex(indexPath.row)
            tableView.reloadData()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "toChat"){
            let destination = segue.destinationViewController as! ChatViewController
            FirebaseHelper.getChat(chats[tableView.indexPathForSelectedRow!.row].otherUser, completionHandler: { (chat: Chat) in
                destination.setUp(self.chats[self.tableView.indexPathForSelectedRow!.row])
            })
        }
        
        if(segue.identifier == "toSearch"){
            let destination = segue.destinationViewController as! UserSearchViewController
            destination.usersInChat = chats.map{$0.otherUser}
        }
    }
}

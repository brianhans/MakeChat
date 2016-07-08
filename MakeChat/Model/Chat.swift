//
//  Chat.swift
//  MakeChat
//
//  Created by Brian Hans on 7/6/16.
//  Copyright © 2016 Brian Hans. All rights reserved.
//

import Foundation
import Firebase

class Chat: NSObject{
    
    var timestamp: Double
    var otherUser: User
    var myMessage: String
    var otherUserMessage: String
    var chatId: String
    
    
    init(snapshot: FIRDataSnapshot, chatId: String){
        let user1key = snapshot.value!["User1"] as! String
        let user2key = snapshot.value!["User2"] as! String
        let user1name = snapshot.value!["user1name"] as! String
        let user2name = snapshot.value!["user2name"] as! String
        
        if(user1key != FirebaseHelper.currentUser.key){
            otherUser = User(username: user1name, key: user1key)
            otherUserMessage = snapshot.value![user1key] as! String
            myMessage = snapshot.value![user2key] as! String
        }else{
            otherUser = User(username: user2name, key: user2key)
            otherUserMessage = snapshot.value![user2key] as! String
            myMessage = snapshot.value![user1key] as! String
        }
        
        timestamp = snapshot.value!["timestamp"] as! Double
        self.chatId = chatId
    }
    
    init(timestamp: Double, otherUser: User, chatId: String){
        self.timestamp = timestamp
        self.otherUser = otherUser
        self.chatId = chatId
        self.myMessage = ""
        self.otherUserMessage = ""
    }
    
    //Used to get rid of chat when deleted
    init(chatId: String){
        self.timestamp = 0
        self.otherUser = User(username: "Fake User", key: "for comparison only")
        self.chatId = chatId
        self.myMessage = ""
        self.otherUserMessage = ""

    }
    
}

extension Chat{
    override func isEqual(object: AnyObject?) -> Bool {
        if let otherChat = object as? Chat{
            if(otherChat.chatId == chatId){
                return true
            }
        }
        return false
    }
}
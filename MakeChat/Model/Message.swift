//
//  Message.swift
//  MakeChat
//
//  Created by Brian Hans on 7/5/16.
//  Copyright © 2016 Brian Hans. All rights reserved.
//

import Foundation
import Firebase

class Message{
    
    var text: String
    var timeStamp: Double
    var sender: String
    var chatId: String
    
    init(text: String, chatId: String){
        self.text = text
        self.sender = FirebaseHelper.currentUser.username
        self.timeStamp = NSDate().timeIntervalSinceReferenceDate
        self.chatId = chatId
    }
    
    init(snapshot: FIRDataSnapshot, chatId: String){
        self.sender = snapshot.value!["sender"] as! String
        self.timeStamp = snapshot.value!["timestamp"] as! Double
        self.text = snapshot.value!["message"] as! String
        self.chatId = chatId
    }
}
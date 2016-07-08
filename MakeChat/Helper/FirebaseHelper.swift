//
//  FirebaseHelper.swift
//  MakeChat
//
//  Created by Brian Hans on 7/5/16.
//  Copyright © 2016 Brian Hans. All rights reserved.
//

import Foundation
import Firebase

class FirebaseHelper{

    static var currentUser: User!
    
    enum snapshotStatus {
        case Added, Removed, Updated
    }
    
    //MARK : User methods
    
    static func setOnline(){
        let ref = FIRDatabase.database().referenceWithPath(".info/connected")
        let userRef = FIRDatabase.database().referenceWithPath("presence/" + currentUser.key)
        userRef.setValue(true)
        ref.observeEventType(.Value) { (snapshot: FIRDataSnapshot) in
            if(snapshot.value as! Int == 1){
                userRef.onDisconnectRemoveValue()
                userRef.setValue(true)
            }
        }
    }
    
    static func getOnline(user: User, completionHandler : (Bool) -> Void){
        let userRef = FIRDatabase.database().referenceWithPath("presence/" + user.key)
        userRef.observeEventType(.Value) { (snapshot: FIRDataSnapshot) in
            if(snapshot.exists()){
                completionHandler(true)
            }else{
                completionHandler(false)
            }
        }
    }
    
    static func getUsers(completionBlock: (User, snapshotStatus) -> Void){
        let ref = FIRDatabase.database().reference()
        
        ref.child("users").observeEventType(.ChildAdded) { (snapshot: FIRDataSnapshot) in
            let newUser = User(username: snapshot.value!["username"] as! String, key: snapshot.key)
            completionBlock(newUser, .Added)
        }
        
        ref.child("users").observeEventType(.ChildRemoved) { (snapshot: FIRDataSnapshot) in
            let newUser = User(username: snapshot.value as! String, key: snapshot.key)
            completionBlock(newUser, .Removed)
        }
    }
    
    static func getUser(key: String, completionBlock: (User) -> Void){
        let ref = FIRDatabase.database().reference()
        ref.child("users").child(key).observeSingleEventOfType(.Value) { (snapshot: FIRDataSnapshot) in
           completionBlock(User(username: snapshot.value!["username"] as! String, key: key))
        }
    }
    
    static func searchUser(searchTerm: String, completionBlock: ([User]) -> Void){
        let ref = FIRDatabase.database().reference()
        ref.child("users").queryStartingAtValue(searchTerm).queryOrderedByValue().observeSingleEventOfType(.Value){(snapshot: FIRDataSnapshot) in
            print(searchTerm)
            var users: [User] = []
            for child in snapshot.children{
                let data = child as! FIRDataSnapshot                    
                users.append(User(username: data.value!["username"] as! String, key: data.key))
            }
            completionBlock(users)
        }
    }
    
    
    
    //MARK: Chat methods
    
    static func getAllChats(completionBlock: ([Chat]) -> Void){
        let ref = FIRDatabase.database().reference()
        
        var chats: [Chat] = []
        
        ref.child("chats").queryOrderedByChild("timestamp").observeSingleEventOfType(.Value) { (snapshot: FIRDataSnapshot) in
            for chat in snapshot.children{
                let data = chat as! FIRDataSnapshot
                chats.append(Chat(snapshot: data, chatId: snapshot.key))
            }
            completionBlock(chats)
        }
        
    }
    
    static func getCurrentUsersChats(completionBlock: ([Chat]) -> Void){
        let ref = FIRDatabase.database().reference()

        var chats: [Chat] = []
        
        ref.child("users").child(currentUser.key).child("chats").observeEventType(.Value) { (snapshot: FIRDataSnapshot) in
            for chat in snapshot.children{
                let chatCount: Int = Int(snapshot.childrenCount)
                let data = chat as! FIRDataSnapshot
                let chatId = data.key
                
                ref.child("chats").child(chatId).observeSingleEventOfType(.Value, withBlock: { (snapshot: FIRDataSnapshot) in
                    chats.append(Chat(snapshot: snapshot, chatId: snapshot.key))
                    if(chats.count == chatCount){
                        completionBlock(chats)
                    }
                })
                
            }
        }
    }
    
    static func watchChats(completionBlock: (Chat, snapshotStatus) -> Void){
        let ref = FIRDatabase.database().reference()
        ref.child("users").child(currentUser.key).child("chats").observeEventType(.ChildChanged) { (snapshot: FIRDataSnapshot) in
            ref.child("chats").child(snapshot.key).observeSingleEventOfType(.Value, withBlock: { (snapshot: FIRDataSnapshot) in
                completionBlock(Chat(snapshot: snapshot, chatId: snapshot.key), .Updated)
            })
            
        }
        
        ref.child("users").child(currentUser.key).child("chats").observeEventType(.ChildRemoved) { (snapshot: FIRDataSnapshot) in
            print("removed from users")
            completionBlock(Chat(chatId: snapshot.key), .Removed)
        }
        
        ref.child("users").child(currentUser.key).child("chats").observeEventType(.ChildAdded) { (snapshot: FIRDataSnapshot) in
            print("added chat to view")
            ref.child("chats").child(snapshot.key).observeSingleEventOfType(.Value, withBlock: { (snapshot: FIRDataSnapshot) in
                completionBlock(Chat(snapshot: snapshot, chatId: snapshot.key), .Added)
            })
        }
    }
    
    static func updateText(text: String, chat: Chat){
        let ref = FIRDatabase.database().reference()
        ref.child("chats").child(chat.chatId).updateChildValues([currentUser.key: text])
        ref.child("users").child(currentUser.key).child("chats").child(chat.chatId).updateChildValues(["timestamp" : NSDate().timeIntervalSinceReferenceDate])
        ref.child("users").child(chat.otherUser.key).child("chats").child(chat.chatId).updateChildValues(["timestamp" : NSDate().timeIntervalSinceReferenceDate])
    }
    
    
    static func onDeleteChat(chat: Chat, completionBlock: () -> Void){
        let ref = FIRDatabase.database().reference()
        ref.child("chats").observeEventType(.ChildRemoved) { (snapshot: FIRDataSnapshot) in
            if(snapshot.key == chat.chatId){
                print("Child removed")
                completionBlock()
            }
        }
    }
    
    static func getChat(otherUser: User, completionHandler: (Chat) -> Void){
        let ref = FIRDatabase.database().reference()
        ref.child("chats").observeSingleEventOfType(.Value) { (snapshot: FIRDataSnapshot) in
    
            //Attempt to find a chat with both users
            for child in snapshot.children{
                let data = child as! FIRDataSnapshot
                if let user1 = data.value!["User1"]{
                    if (user1 as! String == currentUser.key || user1 as! String == otherUser.key){
                        if let user2 = data.value!["User2"]{
                            if (user2 as! String == currentUser.key || user2 as! String == otherUser.key){
                                completionHandler(Chat(snapshot: data, chatId: data.key))
                                return
                            }
                        }
                    }
                }
            }
            //If can't find a chat create a new one
            let newChat = ref.child("chats").childByAutoId()
            
            let timestamp = NSDate().timeIntervalSinceReferenceDate
            
            newChat.updateChildValues(["User1" : currentUser.key, "User2" : otherUser.key, "user1name" : currentUser.username, "user2name": otherUser.username, currentUser.key : "", otherUser.key : "", "timestamp" : timestamp])
            
            //Update users with chats they are in
            ref.child("users").child(currentUser.key).child("chats").child(newChat.key).updateChildValues(["user" : otherUser.key, "username": otherUser.username])
            ref.child("users").child(otherUser.key).child("chats").child(newChat.key).updateChildValues(["user" : currentUser.key, "username": currentUser.username])
            
            completionHandler(Chat(timestamp: timestamp, otherUser: otherUser, chatId: newChat.key))
        }
    }
    
    static func getOtherUserText(chatId: String, otherUser: User, completionHandler: (String) -> Void){
        let ref = FIRDatabase.database().reference()
        ref.child("chats").child(chatId).child(otherUser.key).observeEventType(.Value) { (snapshot: FIRDataSnapshot) in
            if(snapshot.exists()){
                completionHandler(snapshot.value as! String)
            }
        }
    }
    
    static func deleteChat(chat: Chat){
        let ref = FIRDatabase.database().reference()
        ref.child("users").child(currentUser.key).child("chats").child(chat.chatId).removeValue()
        ref.child("users").child(chat.otherUser.key).child("chats").child(chat.chatId).removeValue()
        ref.child("messages").child(chat.chatId).removeValue()
        ref.child("chats").child(chat.chatId).removeValue()
    }
    
    
    //MARK: Messages methods
    
    static func saveMessage(message: Message){
        let ref = FIRDatabase.database().reference()
        ref.child("messages").child(message.chatId).childByAutoId().updateChildValues(["sender": message.sender, "message" : message.text, "timestamp": message.timeStamp])
        ref.child("chats").child(message.chatId).updateChildValues(["timestamp" : message.timeStamp])
    }
    
    static func getMessages(chatId: String, completionHandler: (Message) -> Void){
        let ref = FIRDatabase.database().reference()
        ref.child("messages").child(chatId).observeEventType(.ChildAdded) { (snapshot: FIRDataSnapshot) in
            completionHandler(Message(snapshot: snapshot, chatId: chatId))
        }
    }
    
    static func getCurrentAmountOfMessages(chat: Chat, completionHandler: (Int) -> Void){
        let ref = FIRDatabase.database().reference()
        ref.child("messages").child(chat.chatId).observeSingleEventOfType(.Value) { (snapshot: FIRDataSnapshot) in
            completionHandler(Int(snapshot.childrenCount))
        }
    }
    
    //MARK: Profile Picture methods
    
    static func uploadProfileImage(image: UIImage){
        let ref = FIRDatabase.database().reference()
        let storageRef = FIRStorage.storage().reference()
        
        let photoRef = storageRef.child(currentUser.key).child("\(NSDate().timeIntervalSinceReferenceDate * 1000)")
        
        let imageData = UIImageJPEGRepresentation(image, 0.8)!
        photoRef.putData(imageData, metadata: nil){(metadata, error) in
            if let error = error{
                print(error.localizedDescription)
                ErrorHandling.defaultErrorHandler(error)
            }
        }
        
        ref.child("users").child(currentUser.key).updateChildValues(["profilePicture": photoRef.fullPath])
    }
    
    static func getProfileImage(user: User, completionBlock: (UIImage) -> Void){
        let storageRef = FIRStorage.storage().reference()
        let ref = FIRDatabase.database().reference()
        
        ref.child("users").child(user.key).child("profilePicture").observeSingleEventOfType(.Value) { (snapshot: FIRDataSnapshot) in

            if(snapshot.exists()){
                storageRef.child(snapshot.value as! String).dataWithMaxSize(INT64_MAX) { (data: NSData?, error: NSError?) in
                    if let error = error{
                        print(error.localizedDescription)
                        return
                    }
                    
                    if let data = data{
                        completionBlock(UIImage(data: data, scale: 1.0)!)
                    }
                    
                }
            }else{
                print("doesn't exist")
            }
        }
        
    }
    

}
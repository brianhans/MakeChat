 //
//  ChatViewController.swift
//  MakeChat
//
//  Created by Brian Hans on 7/5/16.
//  Copyright © 2016 Brian Hans. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var otherUserTextLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var otherUserNameLabel: UILabel!
    @IBOutlet weak var bubble: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    var chat: Chat!
    
    var messages: [Message] = []
    
    var defaultFrame: CGPoint!
    
    override func viewDidLoad() {
        
        //Calls keyboardwillshow/hide methods when the keyboard shows/hides
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
        
        //Adds keyboard to dismiss on tap
        hideKeyBoardWhenTapped()
        
        //Allows class to handle return key pressed
        self.textField.delegate = self
        
        defaultFrame = CGPoint(x: bubble.frame.origin.x, y: bubble.frame.origin.y + bubble.frame.height/2)
    }
    
    func setUp(chat: Chat){
        self.chat = chat
        FirebaseHelper.getOtherUserText(chat.chatId, otherUser: chat.otherUser) { (text: String) in
            if(self.bubble.frame.origin.y != self.defaultFrame.y){
                self.bubble.frame.origin.y = self.defaultFrame.y
                self.otherUserNameLabel.frame.origin.y = self.defaultFrame.y
            }
            self.otherUserTextLabel.text = text
        }
        
        FirebaseHelper.getCurrentAmountOfMessages(chat){(messages: Int) in
            let initalMessages = messages
            
            FirebaseHelper.getMessages(chat.chatId) { (message: Message) in
                self.messages.append(message)
                if(self.messages.count > initalMessages && message.sender == chat.otherUser.username){
                    let finalDestination = self.tableView.frame
                    UIView.animateWithDuration(0.5, animations: {
                        self.bubble.frame.origin = CGPoint (x: self.bubble.frame.origin.x, y: finalDestination.origin.y - self.bubble.frame.size.height * 2)
                        self.otherUserNameLabel.frame.origin.y = finalDestination.origin.y - self.bubble.frame.size.height * 2
                        }, completion: { (bool: Bool) in
                            self.tableView.reloadData()
                            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messages.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: true)
                    })
                    
                }else{
                    self.tableView.reloadData()
                    self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messages.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: true)
                }

                
            }

        }
        

        
        FirebaseHelper.onDeleteChat(chat) {
            self.performSegueWithIdentifier("chatToHome", sender: nil)
        }
        
        otherUserNameLabel.text = chat.otherUser.username
        bubble.layer.cornerRadius = 5

    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    //Moves the view up by the height of the keyboard so that users can see the input field
    func keyboardWillShow(sender: NSNotification){
        let userInfo: NSDictionary = sender.userInfo!
        let rect: CGRect = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue()
        var frame = view.frame
        frame.origin.y = frame.origin.y - rect.height
        view.frame = frame
        
    }
    
    //Moves the view down by the height of the keyboard to reset the view after the keyboard goes away
    func keyboardWillHide(sender: NSNotification){
        
        let userInfo: NSDictionary = sender.userInfo!
        let rect: CGRect = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue()
        var frame = view.frame
        frame.origin.y = frame.origin.y + rect.height
        view.frame = frame
    }
    
    //Sends changes to the text field to Firebase
    @IBAction func textChanged(sender: AnyObject) {
        let textField = sender as! UITextField
        FirebaseHelper.updateText(textField.text ?? "", chat: chat)
    }
    
    //Moves the message up to the sent messages
    @IBAction func sendButtonPressed(sender: AnyObject) {
        let message = Message(text: textField.text!, chatId: chat.chatId)
        textField.text = ""
        textChanged(textField)
        FirebaseHelper.saveMessage(message)
    }
}
 
 //MARK: Table View Data Source

extension ChatViewController: UITableViewDataSource{
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    //Initializes the cells
    func  tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(messages[indexPath.row].sender == chat.otherUser.username){
            let cell = tableView.dequeueReusableCellWithIdentifier("messageCell") as! MessageCell
            cell.messageLabel.text = messages[indexPath.row].text
            cell.nameLabel.text = messages[indexPath.row].sender
            cell.bubbleView.layer.cornerRadius = 5
            cell.bubbleView.layer.masksToBounds = true
            return cell

        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("otherUserMessageCell") as! MessageCell
            cell.otherUserMessageLabel.text = messages[indexPath.row].text
            cell.otherUserNameLabel.text = messages[indexPath.row].sender
            cell.otherUserBubbleView.layer.cornerRadius = 5
            cell.otherUserBubbleView.layer.masksToBounds = true
            return cell

        }

    }
}

 //MARK: Text Field Delegate
 
 extension ChatViewController: UITextFieldDelegate{
 
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        let message = Message(text: textField.text!, chatId: chat.chatId)
        textField.text = ""
        textChanged(textField)
        FirebaseHelper.saveMessage(message)
        return true
    }
 }
 
 
 //MARK: Keyboard Dismiss on tap
extension UIViewController{
    func hideKeyBoardWhenTapped(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard(){
        view.endEditing(true)
    }
}

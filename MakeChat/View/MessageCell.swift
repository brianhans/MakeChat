//
//  MessageCell.swift
//  MakeChat
//
//  Created by Brian Hans on 7/5/16.
//  Copyright © 2016 Brian Hans. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell{
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var otherUserNameLabel: UILabel!
    @IBOutlet weak var otherUserMessageLabel: UILabel!
    
    @IBOutlet weak var otherUserBubbleView: UIView!
    @IBOutlet weak var bubbleView: UIView!
}

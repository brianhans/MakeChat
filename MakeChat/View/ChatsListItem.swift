//
//  ChatsListItem.swift
//  MakeChat
//
//  Created by Brian Hans on 7/5/16.
//  Copyright © 2016 Brian Hans. All rights reserved.
//

import UIKit

class ChatsListItem: UITableViewCell {
    
    static var profilePictures : [String: UIImage] = [:]
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var previewText: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    
    func downloadImage(user: User){
        if(ChatsListItem.profilePictures[user.key] == nil){
            profilePicture.image = UIImage(named: "profile-placeholder")!
            FirebaseHelper.getProfileImage(user) { (image: UIImage) in
                self.profilePicture.image = image
                ChatsListItem.profilePictures[user.key] = image
            }
        }else{
            profilePicture.image = ChatsListItem.profilePictures[user.key]
        }
    }
}

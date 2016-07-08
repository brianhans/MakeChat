//
//  User.swift
//  firegram
//
//  Created by Brian Hans on 6/27/16.
//  Copyright © 2016 Brian Hans. All rights reserved.
//

import Foundation

class User: NSObject{
    
    var username: String
    var key: String
    var online: Bool
    
    var statusUpdate: (() -> Void)?
    
    init(username: String, key: String){
        self.username = username
        self.key = key
        self.online = false
        
        super.init()
        
        FirebaseHelper.getOnline(self, completionHandler: { (status: Bool) in
            
            if(status != self.online){
                self.online = status
                self.statusUpdate?()
            }
        })
    }

    override func isEqual(object: AnyObject?) -> Bool {
        if(object as? User)!.username == self.username{
            return true
        }
        return false
    }
}


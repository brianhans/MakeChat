//
//  ProfileViewController.swift
//  MakeChat
//
//  Created by Brian Hans on 7/7/16.
//  Copyright © 2016 Brian Hans. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController{

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    
    override func viewDidLoad() {
        profileImageView.layer.cornerRadius = profileImageView.frame.width/2
        profileImageView.layer.masksToBounds = true
        usernameLabel.text = FirebaseHelper.currentUser.username
        
        FirebaseHelper.getProfileImage(FirebaseHelper.currentUser) { (image: UIImage) in
            self.profileImageView.image = image
        }
    }
    
    @IBAction func profileImagePressed(sender: AnyObject) {
        let alert = UIAlertController(title: nil, message: "Set Profile Image", preferredStyle: .ActionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let pickImage = UIAlertAction(title: "Camera Roll", style: .Default) { (action: UIAlertAction) in
            print("Pick image")
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .PhotoLibrary
            imagePicker.delegate = self
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
        let camera = UIAlertAction(title: "Camera", style: .Default) { (action: UIAlertAction) in
            print("Camera")
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .Camera
            imagePicker.delegate = self
            
        }
        
        alert.addAction(cancel)
        alert.addAction(pickImage)
        alert.addAction(camera)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?){
        print("picture selected")
        FirebaseHelper.uploadProfileImage(image)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
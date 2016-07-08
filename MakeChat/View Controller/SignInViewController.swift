//
//  SignInViewController.swift
//  firegram
//
//  Created by Brian Hans on 6/26/16.
//  Copyright © 2016 Brian Hans. All rights reserved.
//

import UIKit
import Firebase

class SignInViewController: UIViewController{
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    @IBAction func signInPressed(sender: AnyObject) {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
    
        
        FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { (user: FIRUser?, error) in
            if let error = error{
                print(error.code)
                
                if(error.code == 17011){
                    
                    FIRAuth.auth()?.createUserWithEmail(email, password: password) { (user: FIRUser?, error: NSError?) in
                        if let error = error{
                            ErrorHandling.defaultErrorHandler(error)
                            print(error)
                            return
                        }
                        
                        let alert = UIAlertController(title: nil, message: "Enter a username", preferredStyle: .Alert)
                        
                        alert.addTextFieldWithConfigurationHandler({ (textField) in
                            textField.text = ""
                        })
                        
                        alert.addAction(UIAlertAction(title: "OK", style: .Default){ (action) in
                            let username = alert.textFields![0].text!
                            FirebaseHelper.currentUser = User(username: username, key: FIRAuth.auth()!.currentUser!.uid)
                            FirebaseHelper.setOnline()
                            let ref = FIRDatabase.database().reference()
                            ref.child(Constants.FirebaseCatagories.users).child(FirebaseHelper.currentUser.key).updateChildValues(["username" : username])
                            self.performSegueWithIdentifier(Constants.Segues.signInToHome, sender: nil)
                            
                            })
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    
                    return
                    
                }else{
                    ErrorHandling.defaultErrorHandler(error)
                    print(error)
                    return
                }
                
                
            }
            FIRDatabase.database().reference().child(Constants.FirebaseCatagories.users).child(FIRAuth.auth()!.currentUser!.uid).observeSingleEventOfType(.Value, withBlock: { (snapshot: FIRDataSnapshot) in
                
                if let username = snapshot.value!["username"] as? String{
                    FirebaseHelper.currentUser = User(username: username, key: FIRAuth.auth()!.currentUser!.uid)
                    FirebaseHelper.setOnline()
                }
                self.performSegueWithIdentifier(Constants.Segues.signInToHome, sender: nil)
            })
        })
    }
}

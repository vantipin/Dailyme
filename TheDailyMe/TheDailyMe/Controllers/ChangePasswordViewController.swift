//
//  ChangePasswordViewController.swift
//  TheDailyMe
//
//  Created by Vlad Antipin on 2/27/16.
//  Copyright © 2016 TheDailyMe. All rights reserved.
//

import UIKit
import Foundation

public class ChangePasswordViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var textFieldOldPass : UITextField!
    @IBOutlet weak var textFieldNewPass1 : UITextField!
    @IBOutlet weak var textFieldNewPass2 : UITextField!
    
    var changePass: Bool = false
    
    public override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if changePass {
            NetworkManager.sharedInstance.userUpdate(DataManager.sharedInstance.user!)
        }
    }
    
    public func showAlert(text: String) {
        let alertController = UIAlertController(title: text, message:
            nil, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func resetPass(sender: UIButton) {
        if let newPass = textFieldNewPass1.text {
            let passwordMatch = textFieldNewPass2.text == textFieldNewPass1.text
            let correctPassword = DataManager.sharedInstance.user?.password == textFieldOldPass.text || DataManager.sharedInstance.user?.password == nil
            
            if !correctPassword {
                showAlert("Incorrect old password!")
                return
            }
            
            if !passwordMatch {
                showAlert("New passwords must match!")
                return
            }
            
            let user: User = DataManager.sharedInstance.user!
            DataManager.sharedInstance.setUser(user.id,
                email: user.email!,
                birthDate:  user.birthDate,
                firstName: user.firstName,
                lastName: user.lastName,
                password: newPass,
                avatarImage: user.avatarImage)
            
            changePass = true
            showAlert("New password is set!")
        }
        else {
            showAlert("Fields are empty!")
        }
        
    }
    
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    public func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        if textField.text!.characters.count == 0 {
            textField.endEditing(true)
            return true
        }
        switch (textField) {
        case textFieldOldPass:
            break
        case textFieldNewPass1:
            break
        case textFieldNewPass2:
            break
        default:
            break
        }
        textField.endEditing(true)
        return true
    }

}

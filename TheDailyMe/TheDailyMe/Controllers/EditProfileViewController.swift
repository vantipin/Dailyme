//
//  EditProfileViewController.swift
//  TheDailyMe
//
//  Created by Vlad Antipin on 2/27/16.
//  Copyright © 2016 TheDailyMe. All rights reserved.
//

import UIKit
import Foundation
import MessageUI

public class EditProfileViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate {
    
    var imagePicker = UIImagePickerController()
    
    @IBOutlet weak var imageAvatar : UIImageView!
    @IBOutlet weak var textFieldName : UITextField!
    @IBOutlet weak var textFieldSurname : UITextField!
    @IBOutlet weak var textFieldAge : UITextField!
    @IBOutlet weak var textFieldEmail : UITextField!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let user = DataManager.sharedInstance.user {

            if user.email != "empty" {
                textFieldEmail.text = user.email
            }
            
            if user.firstName != nil {
                textFieldName.text = user.firstName
            }
            if user.lastName != nil {
                textFieldSurname.text = user.lastName
            }
            
            if user.birthDate != nil {
                let date = user.birthDate
                textFieldAge.text = dateToString(date!)
            }
            
            if let data = DataManager.sharedInstance.user?.avatarImage,
               image = UIImage(data: data) {
                imageAvatar.image = image
            }
        }
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if DataManager.sharedInstance.isAuthorised() {
            NetworkManager.sharedInstance.userUpdate(DataManager.sharedInstance.user!)
        }
        else {
            NetworkManager.sharedInstance.userCreate(DataManager.sharedInstance.user!)
        }
    }
    
    func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage? {
        
        let contextImage: UIImage = UIImage(CGImage: image.CGImage!)
        
        let contextSize: CGSize = contextImage.size
        
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)
        
        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }
        
        let rect: CGRect = CGRectMake(posX, posY, cgwidth, cgheight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(CGImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        return image
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients([])
        mailComposerVC.setSubject("Feedback")
        mailComposerVC.setMessageBody("", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertController(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: UIAlertControllerStyle.Alert)
        sendMailErrorAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    @IBAction func setImage(sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){

            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum;
            imagePicker.allowsEditing = false
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func sendFeedback(sender: UIButton) {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    //MARK: UITextField delegate
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
        case textFieldName:
            DataManager.sharedInstance.user?.firstName = textField.text
            break
        case textFieldSurname:
            DataManager.sharedInstance.user?.lastName = textField.text
            break
        case textFieldAge:
            if let date: NSDate = dateFromString(textField.text!) {
                DataManager.sharedInstance.user?.birthDate = date
                textField.text = dateToString(date)
            }
            else {
                return false
            }
            break
        case textFieldEmail:
            DataManager.sharedInstance.user?.email = textField.text
            DataManager.sharedInstance.setUserEmail(textField.text!)
            break
        default:
            break
        }
        
        let user: User = DataManager.sharedInstance.user!
        DataManager.sharedInstance.setUser(user.id,
            email: user.email!,
            birthDate:  user.birthDate,
            firstName: user.firstName,
            lastName: user.lastName,
            password: user.password,
            avatarImage: user.avatarImage)
        textField.endEditing(true)
        return true
    }
    
    //MARK: UIImagePicker delegate
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
        
        if let cropedImage = self.cropToBounds(image, width: 300, height: 300) {
            imageAvatar.image = cropedImage
            
            if let imageData = UIImageJPEGRepresentation(cropedImage, 6.0) {
                let user: User = DataManager.sharedInstance.user!
                DataManager.sharedInstance.setUser(user.id,
                    email: user.email!,
                    birthDate:  user.birthDate,
                    firstName: user.firstName,
                    lastName: user.lastName,
                    password: user.password,
                    avatarImage: imageData)
            }
        }

    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    public func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        
    }
}

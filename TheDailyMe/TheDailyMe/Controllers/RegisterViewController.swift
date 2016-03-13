//
//  RegisterViewController.swift
//  TheDailyMe
//
//  Created by Vlad Antipin on 3/14/16.
//  Copyright © 2016 TheDailyMe. All rights reserved.
//

import Foundation
import UIKit

public class RegisterViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NetworkDelegate {
    
    var imagePicker = UIImagePickerController()
    
    @IBOutlet weak var imageAvatar : UIImageView!
    @IBOutlet weak var textFieldName : UITextField!
    @IBOutlet weak var textFieldSurname : UITextField!
    @IBOutlet weak var textFieldAge : UITextField!
    @IBOutlet weak var textFieldEmail : UITextField!
    @IBOutlet weak var textFieldPassword : UITextField!
    
    var imageData : NSData? = nil
    var requestIds : NSMutableArray = []
    var overlayView : UIView? = nil
    public var identifier: String = "RegisterViewController"
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NetworkManager.sharedInstance.subscribe(self)
        checkIfAuthorised()
    }
    
    override public func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NetworkManager.sharedInstance.unsubscribe(self)
    }
    
    public func checkIfAuthorised() {
        if DataManager.sharedInstance.isAuthorised() {
            //user already login
            if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(Constant.String.Storyboard.defaultNavigation) as? UINavigationController,
                let window: UIWindow = self.view.window {
                    window.rootViewController = controller
            }
        }
    }
    
    public func setOverlayView() {
        if overlayView == nil {
            overlayView = UIView(frame: self.view.bounds)
            overlayView?.backgroundColor = UIColor(white: 1, alpha: 0.5)
            
            let activity = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            overlayView?.addSubview(activity)
            activity.center = (overlayView?.center)!
            activity.startAnimating()
            
            self.view.addSubview(overlayView!)
        }
    }
    
    public func removeOverLayView() {
        if overlayView != nil {
            overlayView?.removeFromSuperview()
            overlayView = nil
        }
    }
    
    @IBAction func setImage(sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){
            
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum;
            imagePicker.allowsEditing = false
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func signup(sender: UIButton) {
        if let login = textFieldEmail.text,
            password = textFieldPassword.text {
                
                self.setOverlayView()
                
                let requestId = NetworkManager.sharedInstance.userCreate(nil,
                    email: login,
                    birthDate: textFieldAge.text,
                    firstName: textFieldName.text,
                    lastName: textFieldSurname.text,
                    password: password,
                    avatarImage: imageData)
                //let requestId = NetworkManager.sharedInstance.userLogin(login, password: password)
                self.requestIds.addObject(requestId)
        }
        else {
            showAlert("Login and password required", inController: self)
        }
    }
    
    //MARK: UITextField delegate
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    public func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        
        textField.endEditing(true)
        return true
    }
    
    //MARK: UIImagePicker delegate
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
        if let cropedImage = cropToBounds(image, width: 300, height: 300) {
            imageAvatar.image = cropedImage
            
            if let data = UIImageJPEGRepresentation(cropedImage, 6.0) {
                imageData = data
            }
        }
        
    }
    
    //MARK: - NetworkDelegate
    public func requestFailed(type:RequestType, identifier: String, httpCode: Int?, customCode:ErrorCode?) {
        if requestIds.containsObject(identifier) {
            requestIds.removeObject(identifier)
            removeOverLayView()
        }
    }
    
    public func requestProcessed(type:RequestType, identifier: String) {
        if requestIds.containsObject(identifier) {
            requestIds.removeObject(identifier)
            checkIfAuthorised()
            removeOverLayView()
        }
    }
    
    public func requestProgress(type:RequestType, identifier: String, value: Float) {
        
    }


}
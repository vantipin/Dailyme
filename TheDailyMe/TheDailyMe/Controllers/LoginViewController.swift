//
//  LoginViewController.swift
//  TheDailyMe
//
//  Created by Vlad Antipin on 3/12/16.
//  Copyright © 2016 TheDailyMe. All rights reserved.
//

import Foundation
import UIKit

public class LoginViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NetworkDelegate {

    
    @IBOutlet weak var textFieldLogin : UITextField!
    @IBOutlet weak var textFieldPassword : UITextField!
    
    var requestIds : NSMutableArray = []
    var overlayView: UIView? = nil
    public var identifier: String = "LoginViewController"
    
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
            self.requestIds.addObject(NetworkManager.sharedInstance.recordsGet(DataManager.sharedInstance.user!.id!))
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
    
    @IBAction func login(sender: UIButton) {
        if let login = textFieldLogin.text,
            password = textFieldPassword.text {
                
            self.setOverlayView()
            let requestId = NetworkManager.sharedInstance.userLogin(login, password: password)
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
            
            if type == RequestType.RecordGet {
                if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(Constant.String.Storyboard.defaultNavigation) as? UINavigationController,
                    let window: UIWindow = self.view.window {
                    window.rootViewController = controller
                    removeOverLayView()
                }
            }
            else {
                checkIfAuthorised()
            }
        }
    }
    
    public func requestProgress(type:RequestType, identifier: String, value: Float) {
        
    }
}
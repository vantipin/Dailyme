//
//  NoteTodayViewController.swift
//  TheDailyMe
//
//  Created by Vlad Antipin on 2/13/16.
//  Copyright © 2016 TheDailyMe. All rights reserved.
//

import UIKit
import Foundation

public class NoteTodayViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    public var record: Record!
    
    @IBOutlet weak var textViewNote: UITextView!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        if let text = record.note {
            textViewNote.text = text
        }
    }
    
    override public func viewDidAppear(animated: Bool) {
        textViewNote.becomeFirstResponder()
    }
    
    public func textViewShouldEndEditing(textView: UITextView) -> Bool {
        textView.endEditing(true)
        record.note = textView.text
        DataManager.sharedInstance.saveContext()
        return true
    }
    
    public func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

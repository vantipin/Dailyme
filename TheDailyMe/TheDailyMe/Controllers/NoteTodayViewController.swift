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
    
    weak public var syncController: DailyMeViewController?
    
    @IBOutlet weak var textViewNote: UITextView!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        if let text = record.note {
            textViewNote.text = text
            textViewNote.textContainerInset = UIEdgeInsetsZero
        }
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
        textViewNote.becomeFirstResponder()
    }
    
    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        //mark sync case
        if textViewNote.text != record.note && syncController != nil {
            syncController?.didChange = true
        }
        record.note = textViewNote.text
        DataManager.sharedInstance.saveContext()
    }
    
    public func textViewShouldEndEditing(textView: UITextView) -> Bool {
        textView.endEditing(true)
        

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

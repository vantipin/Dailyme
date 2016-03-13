 //
//  TheDailyMe.swift
//  TheDailyMe
//
//  Created by Vlad Antipin on 2/9/16.
//  Copyright © 2016 TheDailyMe. All rights reserved.
//
import UIKit
import Foundation

class DailyMeViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, NetworkDelegate {
    
    @IBOutlet weak var recordView : RecordView!
    @IBOutlet weak var buttonAddNote : UIButton!
    @IBOutlet weak var buttonMenu : UIButton!
    @IBOutlet weak var buttonAnswer : UIButton!
    
    var dataSource : NSMutableArray = NSMutableArray()
    var question : Question?
    var record : Record?
    var date : NSDate = NSDate()
    var requestIds : NSMutableArray = []
    var identifier: String = "DailyMeViewController"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NetworkManager.sharedInstance.questionsGet()
        
        recordView.textViewAnswer.text = ""
        recordView.textViewNote.text = ""
        recordView.textViewQuestion.text = ""
        
        buttonAnswer.titleLabel?.numberOfLines = 2
        buttonAnswer.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        buttonAnswer.titleLabel?.layoutMargins = UIEdgeInsets(top: 10, left: 100, bottom: 10, right: 100)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NetworkManager.sharedInstance.subscribe(self)
        setupContent()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NetworkManager.sharedInstance.unsubscribe(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
    }
    
    func setupContent() {
        if let questionCheck = DataManager.sharedInstance.fetchQuestionForDate(date) {
            question = questionCheck
            recordView.setQuestion(questionCheck)
        }
        else {
            let requestId = NetworkManager.sharedInstance.questionsGet()
            self.requestIds.addObject(requestId)
        }
        
        if let recordCheck = DataManager.sharedInstance.fetchRecordForDate(date) {
            record = recordCheck
            recordView.setRecord(recordCheck)
            buttonAnswer.hidden = record?.answer?.characters.count > 0
        }
        else {
            buttonAnswer.hidden = false
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constant.String.Segue.addNoteSegueId {
            let controller : NoteTodayViewController = segue.destinationViewController as! NoteTodayViewController
            if record == nil {
                let id: NSNumber = NSNumber.init(longLong: (Int64(NSDate().timeIntervalSinceNow)))
                record = DataManager.sharedInstance.setRecord(id, answer: "", note: "", date: NSDate(), question: question!)
            }
            controller.record = record
        }
    }
    
    @IBAction func menu(sender: UIButton) {
        if recordView.textViewAnswer.isFirstResponder() {
            recordView.textViewAnswer.endEditing(true)
        }
        else {
            self.performSegueWithIdentifier(Constant.String.Segue.menuSegueId, sender: nil)
        }
        
    }
    
    @IBAction func answer(sender: UIButton) {
        recordView.textViewAnswer.userInteractionEnabled = true
        recordView.textViewAnswer.editable = true
        recordView.textViewAnswer.becomeFirstResponder()
        sender.hidden = true
        
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        buttonMenu.setTitle("Done", forState: UIControlState.Normal)
        
        return true
    }
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        textView.endEditing(true)
        if textView.text.characters.count > 0 {
            if record == nil {
                let id: NSNumber = NSNumber.init(longLong: (Int64(NSDate().timeIntervalSinceNow)))
                record = DataManager.sharedInstance.setRecord(id, answer: textView.text, note: "", date: NSDate(), question: question!)
            }
            else {
                record?.answer = textView.text
            }
            DataManager.sharedInstance.saveContext()
        }
        else {
            buttonAnswer.hidden = false
        }
        buttonMenu.setTitle("Menu", forState: UIControlState.Normal)
        
        return true
    }
    
    //MARK: - NetworkDelegate
    func requestFailed(type:RequestType, identifier: String, httpCode: Int?, customCode:ErrorCode?) {
        if requestIds.containsObject(identifier) {
            requestIds.removeObject(identifier)
            
        }
    }
    
    func requestProcessed(type:RequestType, identifier: String) {
        if requestIds.containsObject(identifier) {
            requestIds.removeObject(identifier)
            setupContent()
        }
    }
    
    func requestProgress(type:RequestType, identifier: String, value: Float) {
        
    }
    
}
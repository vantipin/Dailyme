//
//  DiaryViewController.swift
//  TheDailyMe
//
//  Created by Vlad Antipin on 2/13/16.
//  Copyright © 2016 TheDailyMe. All rights reserved.
//

import Foundation
import UIKit
import CVCalendar

public class DiaryViewController : UITableViewController {
    
    @IBOutlet weak var buttonCalendar : UIButton!
    
    public var calendarHidden : Bool = false
    public var date: NSDate!
    public var questionSource: NSMutableArray = NSMutableArray()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        buttonCalendar.hidden = calendarHidden
        if let questions = DataManager.sharedInstance.fetchQuestionsInMonthForDate(date) {
                //get all question within selected month
                questionSource.removeAllObjects()
                questionSource.addObjectsFromArray(questions)
        }
    }
    
    public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questionSource.count
    }
    
    public override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return 1
    }
    
    public override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : RecordTableViewCell = tableView.dequeueReusableCellWithIdentifier("RecordViewCellId", forIndexPath: indexPath) as! RecordTableViewCell
        
        cell.recordView.textViewAnswer.text = ""
        cell.recordView.textViewNote.text = ""
        
        if let question: Question = questionSource[indexPath.row] as? Question {
            cell.recordView.setQuestion(question)
            
            if let record: Record = question.record?.anyObject() as? Record {
                cell.recordView.setRecord(record)
            }
        }
        
        return cell
    }
    
    
    public override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let questionHeight : CGFloat = 100.0
        let bodyHeight : CGFloat = 100.0
        
        if let question: Question = questionSource[indexPath.row] as? Question {
            if let _: Record = question.record?.anyObject() as? Record {
                return questionHeight + bodyHeight
            }
            return questionHeight
        }
        
        return 0;
    }
}
//
//  RecordView.swift
//  TheDailyMe
//
//  Created by Vlad Antipin on 2/13/16.
//  Copyright © 2016 TheDailyMe. All rights reserved.
//

import Foundation
import UIKit

public class RecordView: UIView {

    @IBOutlet weak var labelDate : UILabel!
    @IBOutlet weak var textViewQuestion : UITextView!
    @IBOutlet weak var textViewNote : UITextView!
    @IBOutlet weak var textViewAnswer : UITextView!

    public func setQuestion(question: Question) {
        textViewQuestion.text = question.text!
        labelDate.text = dateToString(question.assignedDate!, format: "dd MMMM yyyy", escapeSymbols: false)
        textViewQuestion.font = UIFont(name: Constant.String.FontBold, size: 14)
        //textViewQuestion.textContainerInset = UIEdgeInsetsZero
        //textViewQuestion.sizeToFit()
    }
    
    public func setRecord(record: Record) {
        textViewAnswer.text = record.answer?.characters.count > 0 ? record.answer : ""
        textViewAnswer.font = UIFont(name: Constant.String.Font, size: 14)
        textViewNote.text = record.note?.characters.count > 0 ? "Note! \(record.note!)" : ""
        textViewNote.font = UIFont(name: Constant.String.Font, size: 14)
    }

}
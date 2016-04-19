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
    }
    
    public func setRecord(record: Record) {
        textViewAnswer.text = record.answer?.characters.count > 0 ? record.answer : ""
        textViewAnswer.font = UIFont(name: Constant.String.Font, size: 14)
        textViewNote.text = record.note?.characters.count > 0 ? "Note! \(record.note!)" : ""
        textViewNote.font = UIFont(name: Constant.String.Font, size: 14)
        //layoutViews()
    }
    
    public func viewSize() -> CGFloat {
        return textViewNote.frame.origin.y + textViewNote.frame.size.height
    }
    
    public func layoutViews() {
        
        
        
        let offset : CGFloat = 15.0
        var offsetNextView : CGFloat = textViewQuestion.frame.origin.y
        
        let sizeQ = textViewQuestion.sizeThatFits(textViewQuestion.bounds.size)
        textViewQuestion.frame = CGRectMake(textViewQuestion.frame.origin.x,
                                            offsetNextView,
                                            textViewQuestion.frame.size.width,
                                            sizeQ.height + offset)
        offsetNextView += textViewQuestion.bounds.size.height
        
        let sizeA = textViewAnswer.sizeThatFits(textViewAnswer.bounds.size)
        textViewAnswer.frame = CGRectMake(textViewAnswer.frame.origin.x,
                                          offsetNextView,
                                          textViewAnswer.frame.size.width,
                                          sizeA.height + offset)
        offsetNextView += textViewAnswer.bounds.size.height
        
        let sizeN = textViewNote.sizeThatFits(textViewNote.bounds.size)
        textViewNote.frame = CGRectMake(textViewNote.frame.origin.x,
                                        offsetNextView,
                                        textViewNote.frame.size.width,
                                        sizeN.height + offset)
        offsetNextView += textViewNote.bounds.size.height
    }

}
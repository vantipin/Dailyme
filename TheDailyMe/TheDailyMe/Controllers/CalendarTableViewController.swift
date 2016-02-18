//
//  CalendarTableViewController.swift
//  TheDailyMe
//
//  Created by Vlad Antipin on 2/17/16.
//  Copyright © 2016 TheDailyMe. All rights reserved.
//

import Foundation
import UIKit

public class CalendarTableViewController : UITableViewController {
    
    let monthsDataSource : NSArray = ["January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December"]
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return monthsDataSource.count
    }
    
    public override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return 1
    }
    
    public override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier("MonthViewCellId", forIndexPath: indexPath)
        
        cell.textLabel?.text = monthsDataSource[indexPath.row] as? String
        
        return cell
    }
    
    public override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let components = calendar!.components([.Year, .Month, .Day, .Hour, .Minute, .Second], fromDate: NSDate())
        //        components.hour = 00
        //        components.minute = 00
        //        components.second = 00
        //        components.day = 1
        components.month = indexPath.row + 1
        //components.year =
        let date : NSDate = calendar!.dateFromComponents(components)!
        performSegueWithIdentifier(Constant.String.Segue.diarySegueId, sender: date)
        
        return indexPath
    }
    
    public override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        

    }
    
    override public func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constant.String.Segue.diarySegueId {
            let controller : DiaryViewController = segue.destinationViewController as! DiaryViewController
            controller.date = sender as! NSDate
        }
    }
}



//
//  MeetingsVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 4/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import RealmSwift

class MeetingsVC: UITableViewController {

    @IBOutlet var noMeetingsLabel:UILabel!
    
    var model:Model?
    
    @IBOutlet var meetingReviewContainer:UINavigationController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNoRentRequestsLabel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func configureNoRentRequestsLabel() {
        noMeetingsLabel = UILabel(frame: CGRectMake(12.0, 0, view.bounds.width-24.0, view.bounds.height))
        noMeetingsLabel.font = UIFont.systemFontOfSize(18.0)
        noMeetingsLabel.textColor = .darkGrayColor()
        noMeetingsLabel.textAlignment = .Center
        noMeetingsLabel.numberOfLines = 0
        noMeetingsLabel.text = "You have no upcoming meetings."
        noMeetingsLabel.hidden = true
        view.addSubview(noMeetingsLabel)
        view.sendSubviewToBack(noMeetingsLabel)
    }

    // MARK: UITableViewDataSource
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }


    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let realm = try! Realm()
        let count = realm.objects(MeetingEvent).filter("status == \"Scheduled\" OR status == \"Delayed\"").count

        if count == 0 {
            noMeetingsLabel.hidden = false
            view.bringSubviewToFront(noMeetingsLabel)
        } else {
            noMeetingsLabel.hidden = true
            view.sendSubviewToBack(noMeetingsLabel)
        }
        
        return count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("MeetingCell", forIndexPath: indexPath) as? MeetingTableViewCell else { return UITableViewCell() }
        
        let realm       = try! Realm()
        let meetings    = realm.objects(MeetingEvent).filter("status == \"Scheduled\" OR status == \"Delayed\"").sorted("time")

        
        let calendar = NSCalendar.currentCalendar()
        guard let time = meetings[indexPath.row].time else { return cell }
        let components = calendar.components([.Hour, .Minute], fromDate: time)
        let hour = components.hour
        let minutes = components.minute
        cell.timeLabel.text     = String(format: "%d:%02d", hour, minutes)
        guard let locationID    = meetings[indexPath.row].locationID    else { return cell }
        guard let listingID     = meetings[indexPath.row].listingID     else { return cell }
        
        dispatch_async(GlobalBackgroundQueue, {
            let realm = try! Realm()
            guard let location  = realm.objects(FavoriteMeetingLocation).filter("locationID == \"\(locationID)\"").first    else { return }
            guard let listing   = realm.objects(Listing).filter("listingID == \"\(listingID)\"").first                      else { return }
            
            guard let locationName    = location.name else { return }
            guard let listingName     = listing.name  else { return }
            
            dispatch_async(GlobalMainQueue, {
                cell.locationLabel.text =   locationName
                cell.listingLabel.text  =   listingName
            })
        })
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        showMeetingReview(indexPath)
    }
    
    
    private func showMeetingReview(indexPath:NSIndexPath) {
        let meetingSB            = UIStoryboard(name: "Meetings", bundle: NSBundle.mainBundle())
        meetingReviewContainer   = meetingSB.instantiateViewControllerWithIdentifier("MeetingReview") as? UINavigationController
        let realm   = try! Realm()
        let meeting = realm.objects(MeetingEvent).filter("status == \"Scheduled\" OR status == \"Delayed\"").sorted("time")[indexPath.row]
        (meetingReviewContainer?.topViewController as? MeetingReviewVC)?.meetingID = meeting.meetingID
        if (meetingReviewContainer?.topViewController as? MeetingReviewVC)?.model == nil {
            (meetingReviewContainer?.topViewController as? MeetingReviewVC)?.model = model
        }
        presentViewController(meetingReviewContainer, animated: true, completion: nil)
    }
}

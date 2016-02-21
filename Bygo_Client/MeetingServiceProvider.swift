//
//  MeetingServiceProvider.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 8/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import RealmSwift

class MeetingServiceProvider: NSObject {
    let serverURL:String
    
    init(serverURL:String) {
        self.serverURL = serverURL
    }
    
    func fetchUsersMeetingEvents(userID:String, completionHandler:(success:Bool)->Void) {
        // Delete all current Meetings
        let realm               = try! Realm()
        let cachedRentEvents    = realm.objects(MeetingEvent)
        try! realm.write { realm.delete(cachedRentEvents) }
        
        // Cancel all local notifications from going off
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        // Create the request
        let urlString                   = "\(serverURL)/request/users_meeting_events"
        let params:[String:AnyObject]   = ["user_id":userID]
        guard let request = URLServiceProvider().getNewJsonPostRequest(withURL: urlString, params: params) else { return }
        
        // Execute the request
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {
            
            // Handle the response
            (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            
            if error != nil {
                dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
                return
            }
            
            let statusCode = (response as? NSHTTPURLResponse)!.statusCode
            switch statusCode {
            case 200: // Catching status code 200, success
                do {
                    let realm = try! Realm()
                    
                    // Parse the JSON response
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    guard let eventsData = json["events"] as? [[String:AnyObject]] else { return }
                    for eventData in eventsData {
                        guard let meetingID     = eventData["meeting_id"]  as? String else { return }
                        guard let ownerID       = eventData["owner_id"]      as? String else { return }
                        guard let renterID      = eventData["renter_id"]     as? String else { return }
                        guard let listingID     = eventData["listing_id"]    as? String else { return }
                        guard let deliverer     = eventData["deliverer"]     as? String else { return }
                        guard let status        = eventData["status"]        as? String else { return }
                        guard let proposedMeetingTimesData      = eventData["proposed_meeting_times_data"] as? [[String:AnyObject]] else { return }
                        guard let proposedMeetingLocationIDs    = eventData["proposed_meeting_location_ids"] as? [String] else { return }
                        let locationID          = eventData["location_id"] as? String
                        
                        // Create the MeetingEvent
                        let meetingEvent        = MeetingEvent()
                        meetingEvent.meetingID  = meetingID
                        meetingEvent.ownerID    = ownerID
                        meetingEvent.renterID   = renterID
                        meetingEvent.listingID  = listingID
                        meetingEvent.deliverer  = deliverer
                        meetingEvent.status     = status
                        meetingEvent.locationID = locationID
                        
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "yyyy MM dd HH:mm:SS"
                        
                        if let timeStr = eventData["time"] as? String {
                            meetingEvent.time = dateFormatter.dateFromString(timeStr)
                        }
                        
                        if let ownerConfirmationTimeStr = eventData["owner_confirmation_time"] as? String {
                            meetingEvent.ownerConfirmationTime = dateFormatter.dateFromString(ownerConfirmationTimeStr)
                        }
                        
                        if let renterConfirmationTimeStr = eventData["renter_confirmation_time"] as? String {
                            meetingEvent.renterConfirmationTime = dateFormatter.dateFromString(renterConfirmationTimeStr)
                        }
                        
                        for pmtData in proposedMeetingTimesData {
                            let pmt                 = ProposedMeetingTime()
                            guard let isAvailable   = pmtData["is_available"]   as? Bool                        else { return }
                            guard let duration      = pmtData["duration"]       as? Double                      else { return }
                            guard let time          = dateFormatter.dateFromString(pmtData["time"] as! String)  else { return }
                            pmt.isAvailable         = isAvailable
                            pmt.duration            = duration
                            pmt.time                = time
                            meetingEvent.proposedMeetingTimes.append(pmt)
                        }
                        
                        for locationID in proposedMeetingLocationIDs {
                            let locID   = RealmString()
                            locID.value = locationID
                            meetingEvent.proposedMeetingLocations.append(locID)
                        }
                        
                        try! realm.write { realm.add(meetingEvent) }
                        
                        
                        // Schedule the local notifications for the MeetingEvents
                        if meetingEvent.status == "Scheduled" { self.scheduleLocalNotificationForMeetingEvent(meetingEvent, userID: userID) }
                    }
                    
                    completionHandler(success: true)
                } catch {
                    dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
                }
            default:
                print("/request/users_meeting_events: \(statusCode)")
                dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
            }
        })
        task.resume()
    }
    
    
    func fetchMeetingEvent(meetingID:String, userID:String, completionHandler:(success:Bool)->Void) {
        
        // Check if the MeetingEvent is already cached
        let realm = try! Realm()
        let results = realm.objects(MeetingEvent).filter("meetingID == \"\(meetingID)\"")
        if results.count > 0 {
            completionHandler(success: true)
            return
        }
        
        // Create the request
        let urlString       = "\(serverURL)/request/meeting_event"
        let params          = ["meeting_id":meetingID]
        guard let request   = URLServiceProvider().getNewJsonPostRequest(withURL: urlString, params: params) else { return }
        
        // Execute the request
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {
            
            // Handle the response
            (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            
            if error != nil {
                completionHandler(success: false)
                return
            }
            
            let statusCode = (response as? NSHTTPURLResponse)!.statusCode
            switch statusCode {
            case 200: // Catching status code 200, success
                do {
                    let realm = try! Realm()
                    
                    // Parse the JSON response
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    guard let meetingID     = json["meeting_id"]  as? String else { return }
                    guard let ownerID       = json["owner_id"]      as? String else { return }
                    guard let renterID      = json["renter_id"]     as? String else { return }
                    guard let listingID     = json["listing_id"]    as? String else { return }
                    guard let deliverer     = json["deliverer"]     as? String else { return }
                    guard let status        = json["status"]        as? String else { return }
                    guard let proposedMeetingTimesData      = json["proposed_meeting_times_data"] as? [[String:AnyObject]] else { return }
                    guard let proposedMeetingLocationIDs    = json["proposed_meeting_location_ids"] as? [String] else { return }
                    let locationID          = json["location_id"] as? String
                    
                    // Create the MeetingEvent
                    let meetingEvent        = MeetingEvent()
                    meetingEvent.meetingID  = meetingID
                    meetingEvent.ownerID    = ownerID
                    meetingEvent.renterID   = renterID
                    meetingEvent.listingID  = listingID
                    meetingEvent.deliverer  = deliverer
                    meetingEvent.status     = status
                    meetingEvent.locationID = locationID
                    
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy MM dd HH:mm:SS"
                    
                    if let timeStr = json["time"] as? String {
                        meetingEvent.time = dateFormatter.dateFromString(timeStr)
                    }
                    
                    if let ownerConfirmationTimeStr = json["owner_confirmation_time"] as? String {
                        meetingEvent.ownerConfirmationTime = dateFormatter.dateFromString(ownerConfirmationTimeStr)
                    }
                    
                    if let renterConfirmationTimeStr = json["renter_confirmation_time"] as? String {
                        meetingEvent.renterConfirmationTime = dateFormatter.dateFromString(renterConfirmationTimeStr)
                    }
                    
                    for pmtData in proposedMeetingTimesData {
                        let pmt                 = ProposedMeetingTime()
                        guard let isAvailable   = pmtData["is_available"]   as? Bool                        else { return }
                        guard let duration      = pmtData["duration"]       as? Double                      else { return }
                        guard let time          = dateFormatter.dateFromString(pmtData["time"] as! String)  else { return }
                        pmt.isAvailable         = isAvailable
                        pmt.duration            = duration
                        pmt.time                = time
                        meetingEvent.proposedMeetingTimes.append(pmt)
                    }
                    
                    for locationID in proposedMeetingLocationIDs {
                        let locID   = RealmString()
                        locID.value = locationID
                        meetingEvent.proposedMeetingLocations.append(locID)
                    }
                    
                    try! realm.write { realm.add(meetingEvent) }
                    
                    
                    // Schedule the local notifications for the MeetingEvents
                    if meetingEvent.status == "Scheduled" { self.scheduleLocalNotificationForMeetingEvent(meetingEvent, userID: userID) }
                    
                    completionHandler(success: true)
                } catch {
                    completionHandler(success: false)
                }
            default:
                print("/request/meeting_event: \(statusCode)")
                dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
            }
        })
        task.resume()
    }
    
    
    func refreshMeetingEvent(meetingID:String, userID:String, completionHandler:(success:Bool)->Void) {
        print("refresh meeting event")
        // Create the request
        let urlString       = "\(serverURL)/request/meeting_event"
        let params          = ["meeting_id":meetingID]
        guard let request   = URLServiceProvider().getNewJsonPostRequest(withURL: urlString, params: params) else { return }
        
        // Execute the request
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {
            
            // Handle the response
            (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            
            if error != nil {
                completionHandler(success: false)
                return
            }
            
            let statusCode = (response as? NSHTTPURLResponse)!.statusCode
            switch statusCode {
            case 200: // Catching status code 200, success
                do {
                    let realm = try! Realm()
                    
                    print("refresh meeting event server handler")
                    
                    // Parse the JSON response
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    guard let meetingID     = json["meeting_id"]  as? String else { return }
                    guard let ownerID       = json["owner_id"]      as? String else { return }
                    guard let renterID      = json["renter_id"]     as? String else { return }
                    guard let listingID     = json["listing_id"]    as? String else { return }
                    guard let deliverer     = json["deliverer"]     as? String else { return }
                    guard let status        = json["status"]        as? String else { return }
                    guard let proposedMeetingTimesData      = json["proposed_meeting_times_data"] as? [[String:AnyObject]] else { return }
                    guard let proposedMeetingLocationIDs    = json["proposed_meeting_location_ids"] as? [String] else { return }
                    let locationID          = json["location_id"] as? String
                    
                    // Create the MeetingEvent
                    guard let meetingEvent  = realm.objects(MeetingEvent).filter("meetingID == \"\(meetingID)\"").first else { completionHandler(success: false); return }
                    
                    try! realm.write {
                        meetingEvent.meetingID  = meetingID
                        meetingEvent.ownerID    = ownerID
                        meetingEvent.renterID   = renterID
                        meetingEvent.listingID  = listingID
                        meetingEvent.deliverer  = deliverer
                        meetingEvent.status     = status
                        meetingEvent.locationID = locationID
                    }
                    
                    
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy MM dd HH:mm:SS"
                    
                    if let timeStr = json["time"] as? String {
                        try! realm.write {
                            meetingEvent.time = dateFormatter.dateFromString(timeStr)
                        }
                    }
                    
                    if let ownerConfirmationTimeStr = json["owner_confirmation_time"] as? String {
                        try! realm.write {
                            meetingEvent.ownerConfirmationTime = dateFormatter.dateFromString(ownerConfirmationTimeStr)
                        }
                    }
                    
                    if let renterConfirmationTimeStr = json["renter_confirmation_time"] as? String {
                        try! realm.write {
                            meetingEvent.renterConfirmationTime = dateFormatter.dateFromString(renterConfirmationTimeStr)
                        }
                    }
                    
                    for pmtData in proposedMeetingTimesData {
                        let pmt                 = ProposedMeetingTime()
                        guard let isAvailable   = pmtData["is_available"]   as? Bool                        else { return }
                        guard let duration      = pmtData["duration"]       as? Double                      else { return }
                        guard let time          = dateFormatter.dateFromString(pmtData["time"] as! String)  else { return }
                        pmt.isAvailable         = isAvailable
                        pmt.duration            = duration
                        pmt.time                = time
                        try! realm.write {
                            meetingEvent.proposedMeetingTimes.append(pmt)
                        }
                    }
                    
                    for locationID in proposedMeetingLocationIDs {
                        let locID   = RealmString()
                        locID.value = locationID
                        try! realm.write {
                            meetingEvent.proposedMeetingLocations.append(locID)
                        }
                    }
                    
                    // Schedule the local notifications for the MeetingEvents
                    if meetingEvent.status == "Scheduled" { self.scheduleLocalNotificationForMeetingEvent(meetingEvent, userID: userID) }
                    
                    print("refresh meeting event scheduled event")
                    
                    completionHandler(success: true)
                } catch {
                    completionHandler(success: false)
                }
            default:
                print("/request/meeting_event: \(statusCode)")
                dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
            }
        })
        task.resume()
    }

    
    func scheduleLocalNotificationForMeetingEvent(meeting:MeetingEvent, userID:String) {
        print("Scheduling a local notification")
        
        if meeting.status != "Scheduled" { return }
        let note = UILocalNotification()
        // FIXME: Set proper date
        note.fireDate   = NSDate(timeIntervalSinceNow: 10.0)  // meetingEvent.time
        note.alertBody  = "You have a meeting in 10 minutes"
        note.soundName  = UILocalNotificationDefaultSoundName

        if meeting.ownerID == userID {
            if meeting.deliverer == "Owner" {
                note.alertTitle = "Time to drop off your stuff!"
            } else if meeting.deliverer == "Renter" {
                note.alertTitle = "Time to get your stuff back!"
            }
        } else if meeting.renterID == userID {
            if meeting.deliverer == "Owner" {
                note.alertTitle = "Time to pick up your rental!"
            } else {
                note.alertTitle = "Time to return your rental!"
            }
        }

        UIApplication.sharedApplication().scheduleLocalNotification(note)
    }
}

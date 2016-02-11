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
    
//    func fetchMeetingEvent(meetingID:String, completionHandler:(success:Bool)->Void) {
//        
//        // Check local cache to see if the MeetingEvent already exists in the local cache
//        let realm   = try! Realm()
//        let results = realm.objects(MeetingEvent).filter("meetingID == \"\(meetingID)\"")
//        if results.count > 0 {
//            completionHandler(success: true)
//            return
//        }
//        
//        // Create the request
//        let urlString       = "\(serverURL)/request/meeting_event"
//        let params          = ["meeting_id":meetingID]
//        guard let request   = URLServiceProvider().getNewJsonPostRequest(withURL: urlString, params: params) else { return }
//        
//        // Execute the request
//        let session = NSURLSession.sharedSession()
//        let task    = session.dataTaskWithRequest(request, completionHandler: {
//            
//            // Handle the response
//            (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
//            
//            if error != nil {
//                completionHandler(success: false)
//                return
//            }
//            
//            let statusCode = (response as? NSHTTPURLResponse)!.statusCode
//            switch statusCode {
//            case 200: // Catching status code 200, success
//                do {
//                    let realm = try! Realm()
//                    
//                    // Parse the JSON response
//                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
//                    guard let meetingID     = json["meeting_id"]  as? String else { return }
//                    guard let ownerID       = json["owner_id"]      as? String else { return }
//                    guard let renterID      = json["renter_id"]     as? String else { return }
//                    guard let listingID     = json["listing_id"]    as? String else { return }
//                    guard let deliverer     = json["deliverer"]     as? String else { return }
//                    guard let status        = json["status"]        as? String else { return }
//                    guard let proposedMeetingTimesData      = json["proposed_meeting_times_data"] as? [[String:AnyObject]] else { return }
//                    guard let proposedMeetingLocationIDs    = json["proposed_meeting_location_ids"] as? [String] else { return }
//                    let locationID          = json["location_id"] as? String
//                    
//                    
//                    // Create the MeetingEvent
//                    let meetingEvent        = MeetingEvent()
//                    meetingEvent.meetingID  = meetingID
//                    meetingEvent.ownerID    = ownerID
//                    meetingEvent.renterID   = renterID
//                    meetingEvent.listingID  = listingID
//                    meetingEvent.deliverer  = deliverer
//                    meetingEvent.status     = status
//                    meetingEvent.locationID = locationID
//                    
//                    let dateFormatter = NSDateFormatter()
//                    dateFormatter.dateFormat = "yyyy MM dd HH:mm:SS"
//                    
//                    if let timeStr = json["time"] as? String {
//                        meetingEvent.time = dateFormatter.dateFromString(timeStr)
//                    }
//                    
//                    if let ownerConfirmationTimeStr = json["owner_confirmation_time"] as? String {
//                        meetingEvent.ownerConfirmationTime = dateFormatter.dateFromString(ownerConfirmationTimeStr)
//                    }
//                    
//                    if let renterConfirmationTimeStr = json["renter_confirmation_time"] as? String {
//                        meetingEvent.renterConfirmationTime = dateFormatter.dateFromString(renterConfirmationTimeStr)
//                    }
//                    
//                    for pmtData in proposedMeetingTimesData {
//                        let pmt                 = ProposedMeetingTime()
//                        guard let isAvailable   = pmtData["is_available"]   as? Bool                        else { return }
//                        guard let duration      = pmtData["duration"]       as? Double                      else { return }
//                        guard let time          = dateFormatter.dateFromString(pmtData["time"] as! String)  else { return }
//                        pmt.isAvailable         = isAvailable
//                        pmt.duration            = duration
//                        pmt.time                = time
//                        meetingEvent.proposedMeetingTimes.append(pmt)
//                    }
//                    
//                    for locationID in proposedMeetingLocationIDs {
//                        let locID   = RealmString()
//                        locID.value = locationID
//                        meetingEvent.proposedMeetingLocations.append(locID)
//                    }
//                    
//                    try! realm.write { realm.add(meetingEvent) }
//                    
//                    completionHandler(success: true)
//                } catch {
//                    completionHandler(success: false)
//                }
//            default:
//                print("/request/users_rent_events: \(statusCode)")
//                completionHandler(success: false)
//            }
//        })
//        task.resume()
//    }
    
    func fetchUsersMeetingEvents(userID:String, completionHandler:(success:Bool)->Void) {
        // Delete all current Meetings
        let realm               = try! Realm()
        let cachedRentEvents    = realm.objects(MeetingEvent)
        try! realm.write { realm.delete(cachedRentEvents) }
        
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
}

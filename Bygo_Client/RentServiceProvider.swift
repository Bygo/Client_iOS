//
//  RentServiceProvider.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 4/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import RealmSwift

class RentServiceProvider: NSObject {
    let serverURL: String
    
    init(serverURL:String) {
        self.serverURL = serverURL
    }
    
    
    func createRentRequest(ownerID:String, renterID:String, listingID:String, status:String, proposedBy:String, message:String?, rentalRate:Double?, timeFrame:String?, proposedMeetingTimes:[ProposedMeetingTime]?, proposedMeetingLocationIDs:[String]?, completionHandler:(success:Bool)->Void) {
        
        // Create the request
        let urlString                   = "\(serverURL)/rent/propose_rent_request"
        var params:[String:AnyObject]   = ["owner_id":ownerID, "renter_id":renterID, "listing_id":listingID, "status":status, "proposed_by":proposedBy]
        if let message                  = message       { params["message"]     = message }
        if let rentalRate               = rentalRate    { params["rental_rate"] = rentalRate }
        if let timeFrame                = timeFrame     { params["time_frame"]  = timeFrame }
        
        // JSONify the ProposedMeetingTimes data
        if let proposedMeetingTimes = proposedMeetingTimes {
            var proposedMeetingTimesData:[[String:AnyObject]] = []
            for proposedMeetingTime in proposedMeetingTimes {
                guard let time  = proposedMeetingTime.time else { completionHandler(success: false); return }
                let calendar    = NSCalendar.currentCalendar()
                let components  = calendar.components([.Year, .Month, .Day, .Hour, .Minute, .Second], fromDate: time)
                let year        = components.year
                let month       = components.month
                let day         = components.day
                let hour        = components.hour
                let minute      = components.minute
                let second      = components.second
                let timeStr     = "\(year) \(month) \(day) \(hour):\(minute):\(second)"
                let duration    = proposedMeetingTime.duration
                let isAvailable = proposedMeetingTime.isAvailable
                let data:[String:AnyObject] = ["time":timeStr, "duration":duration, "is_available":isAvailable]
                proposedMeetingTimesData.append(data)
            }
            
            params["proposed_meeting_times"] = proposedMeetingTimesData
        }
        
        // JSONify the FavoriteMeetingLocations IDs
        if let proposedMeetingLocationIDs = proposedMeetingLocationIDs {
            params["proposed_meeting_locations"] = proposedMeetingLocationIDs
        }
        
        guard let request = URLServiceProvider().getNewJsonPostRequest(withURL: urlString, params: params) else { return }
        
        // Execute the request
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {
            
            // Handle the request
            (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            if error != nil {
                dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
                return
            }
            
            let statusCode = (response as? NSHTTPURLResponse)!.statusCode
            switch statusCode {
            case 201: // Catching status code 200, success
                do {
                    // Parse the JSON response
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    guard let eventID           = json["event_id"]  as? String else { return }
                    let meetingID               = json["meeting_id"] as? String
                    let dateFormatter           = NSDateFormatter()
                    dateFormatter.dateFormat    = "yyyy MM dd HH:mm:SS"
                    guard let dateCreated       = dateFormatter.dateFromString(json["date_created"] as! String) else { return }

                    // Update the AdvertisedListing
                    dispatch_async(GlobalMainQueue, {
                        let realm = try! Realm()
                        
                        let rentEvent                   = RentEvent()
                        rentEvent.eventID               = eventID
                        rentEvent.ownerID               = ownerID
                        rentEvent.renterID              = renterID
                        rentEvent.listingID             = listingID
                        rentEvent.status                = status
                        rentEvent.proposedBy            = proposedBy
                        rentEvent.rentalRate.value      = rentalRate
                        rentEvent.timeFrame             = timeFrame
                        rentEvent.dateCreated           = dateCreated
                        rentEvent.startMeetingEventID   = meetingID
                        
                        try! realm.write {
                            realm.add(rentEvent)
                        }
                        
                        if let meetingID = meetingID {
                            let meetingEvent                = MeetingEvent()
                            meetingEvent.deliverer          = "Owner"
                            meetingEvent.meetingID          = meetingID
                            meetingEvent.ownerID            = ownerID
                            meetingEvent.renterID           = renterID
                            meetingEvent.listingID          = listingID
                            meetingEvent.status             = status
                            meetingEvent.dateCreated        = dateCreated
                            meetingEvent.proposedMeetingTimes.appendContentsOf(proposedMeetingTimes!)
                            for locationID in proposedMeetingLocationIDs! {
                                let realmID = RealmString()
                                realmID.value = locationID
                                meetingEvent.proposedMeetingLocations.append(realmID)
                            }
                            print("\n\nMEETING EVENT\n\(meetingEvent)\n\n")

                            try! realm.write {
                                realm.add(meetingEvent)
                            }
                        }

                        completionHandler(success: true)
                    })
                } catch {
                    dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
                }
            default:
                print("/create_new/rent_event: \(statusCode)")
                dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
            }
        })
        task.resume()
    }
    
    private func rejectAllRentRequestsExcept(eventID:String, listingID:String, completionHandler:(success:Bool)->Void) {
        let realm           = try! Realm()
        let rentRequests    = realm.objects(RentEvent).filter("listingID == \"\(listingID)\" AND (status == \"Proposed\" OR status == \"Inquired\") AND eventID != \"\(eventID)\"").sorted("dateCreated")
        
        // Base Case
        if rentRequests.count == 0 { completionHandler(success: true); return }

        // Recursive case
        guard let requestID = rentRequests.first?.eventID else { completionHandler(success: false); return }
        rejectRentRequest(requestID, completionHandler: {
            (success:Bool) in
            if success {
                self.rejectAllRentRequestsExcept(eventID, listingID: listingID, completionHandler: completionHandler)
            }
        })
    }
    
    func acceptRentRequest(eventID:String, listingID:String, time:NSDate, locationID:String, completionHandler:(success:Bool)->Void) {
        print("Accept request")
        
        // Automatically reject all of the other rent requests for this Listing
//        let realm           = try! Realm()
//        let rentRequests    = realm.objects(RentEvent).filter("listingID == \"\(listingID)\" AND (status == \"Proposed\" OR status == \"Inquired\")").sorted("dateCreated")
        rejectAllRentRequestsExcept(eventID, listingID: listingID, completionHandler: {
            (success:Bool) in
            if success {
                
                print("Create request")
                // Create the request
                let urlString       = "\(self.serverURL)/rent/accept_rent_request"
                let calendar        = NSCalendar.currentCalendar()
                let components      = calendar.components([.Year, .Month, .Day, .Hour, .Minute, .Second], fromDate: time)
                let year            = components.year
                let month           = components.month
                let day             = components.day
                let hour            = components.hour
                let minute          = components.minute
                let second          = components.second
                let timeStr         = "\(year) \(month) \(day) \(hour):\(minute):\(second)"
                let params          = ["event_id":eventID, "time":timeStr, "location_id":locationID]
                guard let request   = URLServiceProvider().getNewJsonPostRequest(withURL: urlString, params: params) else { return }
                
                print("Execute request")
                
                // Execute the request
                let session = NSURLSession.sharedSession()
                let task = session.dataTaskWithRequest(request, completionHandler: {
                    
                    // Handle the request
                    (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
                    print("Handle response request")
                    if error != nil {
                        completionHandler(success: false)
                        return
                    }
                    
                    let statusCode = (response as? NSHTTPURLResponse)!.statusCode
                    switch statusCode {
                    case 200: // Catching status code 200, success
                        do {
                            // Parse the JSON response
                            let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                            guard let eventID           = json["event_id"]          as? String else { return }
                            guard let status            = json["status"]            as? String else { return }
                            guard let meetingID         = json["meeting_id"]        as? String else { return }
                            guard let meetingStatus     = json["meeting_status"]    as? String else { return }
                            guard let listingID         = json["listing_id"]        as? String else { return }
                            guard let listingStatus     = json["listing_status"]    as? String else { return }
                            print("parsed JSON")
                            
                            // Update the RentEvent
                            let realm = try! Realm()
                            guard let rentEvent = realm.objects(RentEvent).filter("eventID == \"\(eventID)\"").first else { return }
                            try! realm.write {
                                rentEvent.status = status
                            }
                            
                            // Update the MeetingEvent
                            guard let meetingEvent = realm.objects(MeetingEvent).filter("meetingID == \"\(meetingID)\"").first else { return }
                            try! realm.write {
                                meetingEvent.status = meetingStatus
                            }
                            
                            // Update the Listing
                            guard let listing = realm.objects(Listing).filter("listingID == \"\(listingID)\"").first else { return }
                            try! realm.write {
                                listing.status = listingStatus
                            }
                            
                            completionHandler(success: true)
                        } catch {
                            completionHandler(success: false)
                        }
                    default:
                        print("/rent/accept_rent_request: \(statusCode)")
                        completionHandler(success: false)
                    }
                })
                task.resume()
            }
        })
    }
    
    func rejectRentRequest(eventID:String, completionHandler:(success:Bool)->Void) {
        // Create the request
        let urlString       = "\(serverURL)/rent/reject_rent_request"
        let params          = ["event_id":eventID]
        guard let request   = URLServiceProvider().getNewJsonPostRequest(withURL: urlString, params: params) else { return }
        
        // Execute the request
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {
            
            // Handle the request
            (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            if error != nil {
                completionHandler(success: false)
                return
            }
            
            let statusCode = (response as? NSHTTPURLResponse)!.statusCode
            switch statusCode {
            case 200: // Catching status code 200, success
                do {
                    // Parse the JSON response
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    guard let eventID           = json["event_id"]          as? String else { return }
                    guard let status            = json["status"]            as? String else { return }
                    guard let meetingID         = json["meeting_id"]        as? String else { return }
                    guard let meetingStatus     = json["meeting_status"]    as? String else { return }
                    
                    // Update the RentEvent
                    let realm = try! Realm()
                    guard let rentEvent = realm.objects(RentEvent).filter("eventID == \"\(eventID)\"").first else { return }
                    try! realm.write {
                        rentEvent.status = status
                    }

                    // Update the MeetingEvent
                    guard let meetingEvent = realm.objects(MeetingEvent).filter("meetingID == \"\(meetingID)\"").first else { return }
                    try! realm.write {
                        meetingEvent.status = meetingStatus
                    }

                    completionHandler(success: true)
                } catch {
                    completionHandler(success: false)
                }
            default:
                print("/rent/reject_rent_request: \(statusCode)")
                completionHandler(success: false)
            }
        })
        task.resume()
    }
    
    func fetchUsersRentEvents(userID:String, completionHandler:(success:Bool)->Void) {
        // Delete all current RentEvents
        let realm = try! Realm()
        let cachedRentEvents = realm.objects(RentEvent)
        try! realm.write { realm.delete(cachedRentEvents) }
        
        // Create the request
        let urlString                   = "\(serverURL)/request/users_rent_events"
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
                        guard let eventID       = eventData["event_id"]                 as? String else { return }
                        guard let ownerID       = eventData["owner_id"]                 as? String else { return }
                        guard let renterID      = eventData["renter_id"]                as? String else { return }
                        guard let listingID     = eventData["listing_id"]               as? String else { return }
                        let rentalRate          = eventData["rental_rate"]              as? Double
                        let timeFrame           = eventData["time_frame"]               as? String
                        guard let proposedBy    = eventData["proposed_by"]              as? String else { return }
                        guard let status        = eventData["status"]                   as? String else { return }
                        let startMeetingEventID = eventData["start_meeting_event_id"]   as? String
                        let endMeetingEventID   = eventData["end_meeting_event_id"]     as? String
                        
                        let rentEvent                   = RentEvent()
                        rentEvent.eventID               = eventID
                        rentEvent.ownerID               = ownerID
                        rentEvent.renterID              = renterID
                        rentEvent.listingID             = listingID
                        rentEvent.rentalRate.value      = rentalRate
                        rentEvent.timeFrame             = timeFrame
                        rentEvent.proposedBy            = proposedBy
                        rentEvent.status                = status
                        rentEvent.startMeetingEventID   = startMeetingEventID
                        rentEvent.endMeetingEventID     = endMeetingEventID
                        
                        try! realm.write {
                            realm.add(rentEvent)
                        }
                    }
                    
                    completionHandler(success: true)
                } catch {
                    dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
                }
            default:
                print("/request/users_rent_events: \(statusCode)")
                dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
            }
        })
        task.resume()
    }
    
    
    func generateNewProposedMeetingTimes() -> [ProposedMeetingTime] {
        let numMeetingTimes     = 24    // Every half hour over the next 12 hours
        let duration:Double     = 30.0  // 1 half hour
        let now                 = NSDate()
        let timestamp           = now.timeIntervalSince1970
        let calendar            = NSCalendar.currentCalendar()
        let components          = calendar.components([.Minute], fromDate: now)
        let minutes             = components.minute
        var startingTimeStamp   = timestamp - fmod(timestamp, 3600)
        if minutes > 30 {
            startingTimeStamp   = startingTimeStamp + 3600
        } else {
            startingTimeStamp   = startingTimeStamp + 1800
        }
        
        let realm = try! Realm()
        
        var proposedMeetingTimes:[ProposedMeetingTime] = []
        for i in 0..<numMeetingTimes {
            let pmt = ProposedMeetingTime()
            pmt.time        = NSDate(timeIntervalSince1970: startingTimeStamp+(1800.0 * Double(i)))
            pmt.duration    = duration
            pmt.isAvailable = false
            proposedMeetingTimes.append(pmt)
            
            try! realm.write {
                realm.add(pmt)
            }
        }
        return proposedMeetingTimes
    }

}

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
        let urlString                   = "\(serverURL)/create_new/rent_event"
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
            
//            var proposedMeetingLocationsData:[String] = []
//            for proposedMeetingLocation in proposedMeetingLocations {
//                guard let locationID = proposedMeetingLocation.locationID else { completionHandler(success: false); return }
//                proposedMeetingLocationsData.append(locationID)
//            }
//            params["proposed_meeting_locations"] = proposedMeetingLocationsData
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
                    guard let dateLastModified  = dateFormatter.dateFromString(json["date_last_modified"] as! String) else { return }

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
                        rentEvent.dateLastModified      = dateLastModified
                        rentEvent.startMeetingEventID   = meetingID
                        
                        try! realm.write {
                            realm.add(rentEvent)
                        }
                        
//                        if let meetingID = meetingID {
//                            let meetingEvent                = MeetingEvent()
//                            meetingEvent.deliverer          = "Owner"
//                            meetingEvent.meetingID          = meetingID
//                            meetingEvent.ownerID            = ownerID
//                            meetingEvent.renterID           = renterID
//                            meetingEvent.listingID          = listingID
//                            meetingEvent.status             = status
//                            meetingEvent.dateLastModified   = dateLastModified
//                            meetingEvent.proposedMeetingTimes.appendContentsOf(proposedMeetingTimes!)
//                            for locationID in proposedMeetingLocationIDs! {
//                                let realmID = RealmString()
//                                realmID.value = locationID
//                                meetingEvent.proposedMeetingLocations.append(realmID)
//                            }
//                            print("\n\nMEETING EVENT\n\(meetingEvent)\n\n")
//
//                            try! realm.write {
//                                realm.add(meetingEvent)
//                            }
//                        }

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

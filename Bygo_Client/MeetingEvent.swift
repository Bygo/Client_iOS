//
//  MeetingEvent.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 4/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import RealmSwift
import Realm

class MeetingEvent: Object {
    dynamic var meetingID:String?                   = nil
    dynamic var ownerID:String?                     = nil
    dynamic var renterID:String?                    = nil
    dynamic var listingID:String?                   = nil
    dynamic var deliverer:String?                   = nil
    dynamic var status:String?                      = nil
    let proposedMeetingTimes                        = List<ProposedMeetingTime>()
    let proposedMeetingLocations                    = List<RealmString>()
    dynamic var time:NSDate?                        = nil
    dynamic var locationID: String?                 = nil
    dynamic var ownerConfirmationTime: NSDate?      = nil
    dynamic var renterConfirmationTime: NSDate?     = nil
    dynamic var dateCreated: NSDate?                = nil
}

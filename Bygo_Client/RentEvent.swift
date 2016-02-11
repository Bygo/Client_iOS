//
//  RentEvent.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 4/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import RealmSwift

class RentEvent: Object {
    dynamic var eventID:String?             = nil
    dynamic var ownerID:String?             = nil
    dynamic var renterID:String?            = nil
    dynamic var listingID:String?           = nil
    let rentalRate                          = RealmOptional<Double>()
    dynamic var timeFrame:String?           = nil
    dynamic var status:String?              = nil
    dynamic var proposedBy:String?          = nil
    dynamic var startMeetingEventID:String? = nil
    dynamic var endMeetingEventID:String?   = nil
    dynamic var dateCreated:NSDate?         = nil
}

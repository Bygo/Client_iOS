//
//  Listing.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 3/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import RealmSwift

class Listing: Object {
    
    dynamic var listingID:String?       = nil
    dynamic var status:String?          = nil
    dynamic var name:String?            = nil
    dynamic var itemDescription:String? = nil
    let rating      = RealmOptional<Double>()
    let totalValue  = RealmOptional<Double>()
    let hourlyRate  = RealmOptional<Double>()
    let dailyRate   = RealmOptional<Double>()
    let weeklyRate  = RealmOptional<Double>()
    dynamic var dateLastModified:NSDate? = nil
    
    
    // Relations
    dynamic var ownerID:String?     = nil
    dynamic var renterID:String?    = nil
    dynamic var categoryID:String?  = nil
}

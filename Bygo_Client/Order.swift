//
//  Order.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 5/4/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import RealmSwift

class Order: Object {
    // Attributes
    dynamic var orderID:String? = nil
    dynamic var userID:String? = nil
    dynamic var typeID:String? = nil
    let duration = RealmOptional<Int>()
    dynamic var timeFrame: String? = nil
    let rentalFee = RealmOptional<Double>()
    dynamic var status: String? = nil
    let offeredListings = List<RealmString>()
}

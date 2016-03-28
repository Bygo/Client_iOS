//
//  Category.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 3/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import RealmSwift

class ItemType: Object {
    
    dynamic var typeID:String? = nil
    dynamic var name:String? = nil
    let deliveryFee = RealmOptional<Double>()
    let value = RealmOptional<Double>()
    let imageLinks = List<RealmString>()
}

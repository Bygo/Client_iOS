//
//  FavoriteMeetingLocation.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 2/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import RealmSwift

class FavoriteMeetingLocation: Object {

    // Attributes
    dynamic var locationID:String? = nil
    dynamic var googlePlacesID:String? = nil
    dynamic var address:String? = nil
    dynamic var name:String? = nil
    dynamic var dateLastModified:NSDate? = nil
    dynamic var isPrivate:Bool = false
    
    // Relations
    dynamic var userID:String? = nil
    
}

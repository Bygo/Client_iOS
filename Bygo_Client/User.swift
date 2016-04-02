//
//  User.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 1/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import RealmSwift

class User: Object {
    // Attributes
    dynamic var userID:String?              = nil
    dynamic var firstName:String?           = nil
    dynamic var lastName:String?            = nil
    dynamic var email:String?               = nil
    dynamic var phoneNumber:String?         = nil
    dynamic var facebookID:String?          = nil
    dynamic var password:String?            = nil
    dynamic var isPhoneNumberVerified:Bool  = false
    dynamic var isEmailVerified:Bool        = false
    dynamic var credit:Double               = 0.0
    dynamic var debit:Double                = 0.0
    dynamic var profileImageLink:String?    = nil
    dynamic var dateLastModified:NSDate?    = nil
    
    dynamic var homeAddress_googlePlacesID: String? = nil
    dynamic var homeAddress_name: String? = nil
    dynamic var homeAddress_address: String? = nil
}

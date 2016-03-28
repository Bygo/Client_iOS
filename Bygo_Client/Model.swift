//
//  Model.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 1/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

// curl -H "Content-Type: application/json" -X POST -d item_type_data.json https://bygo-client-server.appspot.com/item_type/load

private let serverURL = "https://bygo-client-server.appspot.com"

enum Notifications:String {
    case DidFetchNewRentRequest = "DidFetchNewRentRequest"
    case RentRequestWasRejected = "RentRequestWasRejected"
    case RentRequestWasAccepted = "RentRequestWasAccepted"
}

enum RentalTimeFrame:String {
    case Hour   = "Hour"
    case Day    = "Day"
    case Week   = "Week"
}

class Model: NSObject {
    let userServiceProvider                     = UserServiceProvider(serverURL: serverURL)
    let favoriteMeetingLocationServiceProvider  = FavoriteMeetingLocationServiceProvider(serverURL: serverURL)
    let listingServiceProvider                  = ListingsServiceProvider(serverURL: serverURL)
    let rentServiceProvider                     = RentServiceProvider(serverURL: serverURL)
    let meetingServiceProvider                  = MeetingServiceProvider(serverURL: serverURL)
    let paymentsServiceProvider                 = PaymentsServiceProvider(serverURL: serverURL)
    let phoneNumberServiceProvider              = PhoneNumberVerificationServiceProvider(serverURL: serverURL)
    let itemTypeServiceProvider                 = ItemTypeServiceProvider(serverURL: serverURL)
    let discoveryServiceProvider                = DiscoveryServiceProvider(serverURL: serverURL)
    let dataValidator = DataValidator()
    
    // TODO: Remove this function and get the AdListingsSP to accept the userID instead
    internal func getLocalUser() -> User? {
        return userServiceProvider.getLocalUser()
    }
}


// MARK: - MultiThreadingQueues
var GlobalMainQueue: dispatch_queue_t {
    return dispatch_get_main_queue()
}

var GlobalUserInteractiveQueue: dispatch_queue_t {
    return dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.rawValue), 0)
}

var GlobalUserInitiatedQueue: dispatch_queue_t {
    return dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)
}

var GlobalUtilityQueue: dispatch_queue_t {
    return dispatch_get_global_queue(Int(QOS_CLASS_UTILITY.rawValue), 0)
}

var GlobalBackgroundQueue: dispatch_queue_t {
    return dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.rawValue), 0)
}
//
//  Model.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 1/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

private let serverURL = "https://spartan-1131.appspot.com"

enum RentalTimeFrame:String {
    case Hour = "Hour"
    case Day = "Day"
    case Week = "Week"
}

class Model: NSObject, AdvertisedListingsServiceProviderDataSource {
    let userServiceProvider = UserServiceProvider(serverURL: serverURL)
    let favoriteMeetingLocationServiceProvider  = FavoriteMeetingLocationServiceProvider(serverURL: serverURL)
    let advertisedListingServiceProvider        = AdvertisedListingsServiceProvider(serverURL: serverURL)
    let listingServiceProvider                  = ListingsServiceProvider(serverURL: serverURL)
    let departmentServiceProvider               = DepartmentsServiceProvider(serverURL: serverURL)
    let categoryServiceProvider                 = CategoriesServiceProvider(serverURL: serverURL)
    let rentServiceProvider                     = RentServiceProvider(serverURL: serverURL)
    let meetingServiceProvider                  = MeetingServiceProvider(serverURL: serverURL)
    let dataValidator = DataValidator()

    override init() {
        super.init()
        advertisedListingServiceProvider.dataSource = self
    }
    
    
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
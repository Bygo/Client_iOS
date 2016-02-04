//
//  Model.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 1/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

private let serverURL = "https://spartan-1131.appspot.com"

class Model: NSObject, AdvertisedListingsServiceProviderDataSource {
    let userServiceProvider = UserServiceProvider(serverURL: serverURL)
    let favoriteMeetingLocationServiceProvider = FavoriteMeetingLocationServiceProvider(serverURL: serverURL)
    let advertisedListingServiceProvider = AdvertisedListingsServiceProvider(serverURL: serverURL)
    let listingServiceProvider = ListingsServiceProvider(serverURL: serverURL)
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

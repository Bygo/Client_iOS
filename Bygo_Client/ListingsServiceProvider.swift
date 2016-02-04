//
//  RentalsServiceProvider.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 3/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import RealmSwift

class ListingsServiceProvider: NSObject {
    let serverURL:String
    
    
    init(serverURL:String) {
        self.serverURL = serverURL
    }
    
    
    func fetchUsersListings(userID:String, completionHandler:(success:Bool)->Void) {
        // First check the local cache
        let realm = try! Realm()
        let cachedResults = realm.objects(Listing).filter("ownerID == \"\(userID)\"")
        if cachedResults.count > 0 {
            completionHandler(success: true); return
        }
        
        // If no FavoriteMeetingLocations were found for this user, query the database
        
        // Create the request
        let urlString       = "\(serverURL)/request/users_listings"
        let params          = ["user_id":userID]
        guard let request   = URLServiceProvider().getNewJsonPostRequest(withURL: urlString, params: params) else { return }
        
        // Execute the request
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {
            
            // Handle the server response
            (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            if error != nil {
                dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
                return
            }
            
            let realm = try! Realm()
            
            let statusCode = (response as? NSHTTPURLResponse)!.statusCode
            switch statusCode {
            case 200: // Catching status code 200, success
                
                do {
                    // Parse the JSON response
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    guard let listingsData = json["listings"] as? [[String:AnyObject]] else { return }
                    for listingData in listingsData {
                        guard let listingID         = listingData["listing_id"] as? String else { return }
                        guard let name              = listingData["name"] as? String else { return }
                        guard let ownerID           = listingData["owner_id"] as? String else { return }
                        let renterID                = listingData["renter_id"] as? String
                        guard let status            = listingData["status"] as? String else { return }
                        guard let itemDescription   = listingData["item_description"] as? String else { return }
                        guard let rating            = listingData["rating"] as? Double else { return }
                        guard let totalValue        = listingData["total_value"] as? Double else { return }
                        guard let hourlyRate        = listingData["hourly_rate"] as? Double else { return }
                        guard let dailyRate         = listingData["daily_rate"] as? Double else { return }
                        guard let weeklyRate        = listingData["weekly_rate"] as? Double else { return }
                        guard let categoryID        = listingData["category_id"] as? String else { return }
                        let dateFormatter           = NSDateFormatter()
                        dateFormatter.dateFormat    = "yyyy MM dd HH:mm:SS"
                        guard let dateLastModified  = dateFormatter.dateFromString(listingData["date_last_modified"] as! String) else { return }
                        
                        // Add the FavoriteMeetingLocation entity to the local cache
                        let listing                 = Listing()
                        listing.listingID           = listingID
                        listing.name                = name
                        listing.ownerID             = ownerID
                        listing.renterID            = renterID
                        listing.status              = status
                        listing.itemDescription     = itemDescription
                        listing.rating.value        = rating
                        listing.totalValue.value    = totalValue
                        listing.hourlyRate.value    = hourlyRate
                        listing.dailyRate.value     = dailyRate
                        listing.weeklyRate.value    = weeklyRate
                        listing.categoryID          = categoryID
                        listing.dateLastModified    = dateLastModified
                        
                        try! realm.write {
                            realm.add(listing)
                        }
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), { completionHandler(success: true) })
                } catch {
                    dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
                }
            default:
                print("/request/users_listings : \(statusCode)")
                dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
            }
        })
        task.resume()
    }
}

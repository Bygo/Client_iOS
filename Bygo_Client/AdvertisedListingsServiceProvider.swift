//
//  AdvertisedListingsServiceProvider.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 3/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import RealmSwift

class AdvertisedListingsServiceProvider: NSObject {
    let serverURL:String
    var dataSource:AdvertisedListingsServiceProviderDataSource?
    
    init(serverURL:String) {
        self.serverURL = serverURL
    }
    
    func refreshAdvertisedListingsSnapshots(completionHandler:(success:Bool)->Void) {
        
        // Delete all current listings
        let realm = try! Realm()
        let cachedAdvertisedListings = realm.objects(AdvertisedListing)
        try! realm.write { realm.delete(cachedAdvertisedListings) }
        
        // Create the request
        guard let localUser = dataSource?.getLocalUser() else { return }
        guard let userID    = localUser.userID else { return }
        let urlString       = "\(serverURL)/advertised_listings/snapshots/user_id=\(userID)/radius=10"
//        let params          = ["user_id": userID]
        guard let request   = URLServiceProvider().getNewGETRequest(withURL: urlString) else { return }
        
        // Execute the request
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {
            
            // Handle the request
            (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            if error != nil {
                completionHandler(success: false)
                return
            }
            
            let statusCode = (response as? NSHTTPURLResponse)!.statusCode
            switch statusCode {
            case 200: // Catching status code 200, success
                do {
                    
                    // Parse the JSON response
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    guard let listings = json["listings"] as? [[String:AnyObject]] else { return }
                    
                    dispatch_async(GlobalMainQueue, {
                        let realm = try! Realm()
                        
                        for listing in listings {
                            print(listing)
                            
                            guard let listingID     = listing["listing_id"]     as? String else { return }
                            guard let dailyRate     = listing["daily_rate"]     as? Double else { return }
                            // guard let location      = listing["location"]       as? String else { return }
                            guard let name          = listing["name"]           as? String else { return }
                            guard let distance      = listing["distance"]       as? Double else { return }
                            guard let rating        = listing["rating"]         as? Double else { return }
                            guard let score         = listing["score"]          as? Double else { return }
                            guard let categoryID    = listing["category_id"]    as? String else { return }
                            let imageMediaLinks = listing["image_media_links"] as? [String]
                            
                            // Add a new AdvertisedListing snapshot
                            let snapshot = AdvertisedListing()
                            snapshot.isSnapshot         = true
                            snapshot.score              = score
                            snapshot.name               = name
                            snapshot.distance           = distance
                            snapshot.rating.value       = rating
                            snapshot.dailyRate.value    = dailyRate
                            snapshot.categoryID         = categoryID
                            snapshot.listingID          = listingID
                            
                            if let imageMediaLinks = imageMediaLinks {
                                for imageMediaLink in imageMediaLinks {
                                    let realmString = RealmString()
                                    realmString.value = imageMediaLink
                                    snapshot.imageLinks.append(realmString)
                                }
                            }
                            
                            try! realm.write { realm.add(snapshot) }
                        }
                        
                        completionHandler(success: true)
                    })
                } catch {
                    completionHandler(success: false)
                }
            default:
                print("Snapshots: \(statusCode)")
                completionHandler(success: false)
            }
        })
        task.resume()
    }
    
//    func downloadAdvertisedListingSnapshot(listingID:String, completionHandler:(success:Bool)->Void) {
//        
//        // Create the request
//        let urlString       = "\(serverURL)/advertised_listings/snapshot"
//        let params          = ["listing_id": listingID]
//        guard let request   = URLServiceProvider().getNewJsonPostRequest(withURL: urlString, params: params) else { return }
//        
//        // Execute the request
//        let session = NSURLSession.sharedSession()
//        let task = session.dataTaskWithRequest(request, completionHandler: {
//            
//            // Handle the request
//            (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
//            if error != nil {
//                dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
//                return
//            }
//            
//            let statusCode = (response as? NSHTTPURLResponse)!.statusCode
//            switch statusCode {
//            case 200: // Catching status code 200, success
//                do {
//                    // Parse the JSON response
//                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
//                    guard let name  = json["name"] as? String else { return }
//                    let rating      = json["rating"] as? Double
//                        
//                    // Update the AdvertisedListing
//                    dispatch_async(GlobalMainQueue, {
//                        let realm = try! Realm()
//                        let listings = realm.objects(AdvertisedListing).filter("listingID == \"\(listingID)\"")
//                        let listing = listings.first
//                        try! realm.write {
//                            listing?.name               = name
//                            listing?.rating.value       = rating
//                            listing?.isPartialSnapshot  = false
//                            listing?.isSnapshot         = true
//                        }
//                        
//                        completionHandler(success: true)
//                    })
//                } catch {
//                    dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
//                }
//            default:
//                print("Snapshots: \(statusCode)")
//                dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
//            }
//        })
//        task.resume()
//    }
    
    func downloadAdvertisedListingComplete(listingID:String, completionHandler:(success:Bool)->Void) {
        
        // Create the request
        let urlString       = "\(serverURL)/advertised_listings/complete/listing_id=\(listingID)"
//        let params          = ["listing_id": listingID]
//        guard let request   = URLServiceProvider().getNewJsonPostRequest(withURL: urlString, params: params) else { return }
        guard let request = URLServiceProvider().getNewGETRequest(withURL: urlString) else { return }
        
        // Execute the request
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {
            
            // Handle the request
            (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            if error != nil {
                dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
                return
            }
            
            let statusCode = (response as? NSHTTPURLResponse)!.statusCode
            switch statusCode {
            case 200: // Catching status code 200, success
                do {
                    // Parse the JSON response
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    guard let name              = json["name"] as? String               else { return }
//                    let rating                  = json["rating"] as? Double             
                    guard let ownerID           = json["owner_id"] as? String           else { return }
                    guard let categoryID        = json["category_id"] as? String        else { return }
                    guard let totalValue        = json["total_value"] as? Double        else { return }
                    guard let dailyRate         = json["daily_rate"] as? Double         else { return }
                    guard let hourlyRate        = json["hourly_rate"] as? Double        else { return }
                    guard let weeklyRate        = json["weekly_rate"] as? Double        else { return }
                    guard let itemDescription   = json["item_description"] as? String   else { return }
                    
                    // Update the AdvertisedListing
                    dispatch_async(GlobalMainQueue, {
                        let realm = try! Realm()
                        let listings = realm.objects(AdvertisedListing).filter("listingID == \"\(listingID)\"")
                        let listing = listings.first
                        try! realm.write {
                            listing?.name               = name
                            listing?.ownerID            = ownerID
//                            listing?.rating.value       = rating
                            listing?.categoryID         = categoryID
                            listing?.totalValue.value   = totalValue
                            listing?.dailyRate.value    = dailyRate
                            listing?.hourlyRate.value   = hourlyRate
                            listing?.weeklyRate.value   = weeklyRate
                            listing?.itemDescription    = itemDescription
//                            listing?.isPartialSnapshot  = false
                            listing?.isSnapshot         = false
                        }
                        
                        completionHandler(success: true)
                    })
                } catch {
                    dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
                }
            default:
                print("Snapshots: \(statusCode)")
                dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
            }
        })
        task.resume()
    }
}

protocol AdvertisedListingsServiceProviderDataSource {
    func getLocalUser() -> User?
}

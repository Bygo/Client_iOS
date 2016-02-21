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
        if cachedResults.count > 0 { completionHandler(success: true); return }
        
        // If no FavoriteMeetingLocations were found for this user, query the database
        
        print("USER ID: \(userID)")
        
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
            
            print(response)
            
            let realm = try! Realm()
            
            let statusCode = (response as? NSHTTPURLResponse)!.statusCode
            switch statusCode {
            case 200: // Catching status code 200, success
                
                do {
                    // Parse the JSON response
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    guard let listingsData = json["listings"] as? [[String:AnyObject]] else { return }
                    
                    print("LISTING DATA: \(listingsData)")
                    
                    for listingData in listingsData {
                        print("Parsing Listing JSON data")
                        
                        guard let listingID         = listingData["listing_id"] as? String else { return }
                        guard let name              = listingData["name"] as? String else { return }
                        guard let ownerID           = listingData["owner_id"] as? String else { return }
                        let renterID                = listingData["renter_id"] as? String
                        print("renterID")
                        guard let status            = listingData["status"] as? String else { return }
                        guard let itemDescription   = listingData["item_description"] as? String else { return }
                        let rating                  = listingData["rating"] as? Double
                        print("Rating")
                        guard let totalValue        = listingData["total_value"] as? Double else { return }
                        guard let hourlyRate        = listingData["hourly_rate"] as? Double else { return }
                        guard let dailyRate         = listingData["daily_rate"] as? Double else { return }
                        guard let weeklyRate        = listingData["weekly_rate"] as? Double else { return }
                        print("weekly rate")
                        guard let categoryID        = listingData["category_id"] as? String else { return }
                        let dateFormatter           = NSDateFormatter()
                        dateFormatter.dateFormat    = "yyyy MM dd HH:mm:SS"
                        guard let dateLastModified  = dateFormatter.dateFromString(listingData["date_last_modified"] as! String) else { return }
                        
                        print("Success parsing Listing JSON data")
                        
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
    
    func createNewListing(userID:String, name:String, categoryID:String, totalValue:Double, hourlyRate:Double, dailyRate:Double, weeklyRate:Double, itemDescription:String, completionHandler:(success:Bool)->Void) {
        
        // Create the request
        print("Create the request")
        let urlString = "\(serverURL)/create_new/listing"
        let params:[String:AnyObject] = ["owner_id":userID, "name":name, "item_description":itemDescription, "total_value":totalValue, "hourly_rate":hourlyRate, "daily_rate":dailyRate, "weekly_rate":weeklyRate, "category_id":categoryID]
        guard let request = URLServiceProvider().getNewJsonPostRequest(withURL: urlString, params: params) else { return }
        

        // Execute the request
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {
            
            // Handle the response
            (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            if error != nil {
                dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
                return
            }
            
            let statusCode = (response as? NSHTTPURLResponse)!.statusCode
            switch statusCode {
            case 201:       // Catching status code 201, success

                // Parse the JSON response object
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    dispatch_async(dispatch_get_main_queue(), {
                        guard let listingID         = json["listing_id"] as? String else { return }
                        guard let status            = json["status"] as? String else { return }
                        let dateFormatter           = NSDateFormatter()
                        dateFormatter.dateFormat    = "yyyy MM dd HH:mm:SS"
                        guard let dateLastModified  = dateFormatter.dateFromString(json["date_last_modified"] as! String) else { return }
    
                        
                        // Add new Listing to local cache
                        let realm                   = try! Realm()
                        let listing                 = Listing()
                        listing.listingID           = listingID
                        listing.name                = name
                        listing.ownerID             = userID
                        listing.categoryID          = categoryID
                        listing.totalValue.value    = totalValue
                        listing.hourlyRate.value    = hourlyRate
                        listing.dailyRate.value     = dailyRate
                        listing.weeklyRate.value    = weeklyRate
                        listing.itemDescription     = itemDescription
                        listing.status              = status
                        listing.dateLastModified    = dateLastModified
                        try! realm.write { realm.add(listing) }
                    
                        completionHandler(success: true)
                    })
                } catch {
                    dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
                }
            default:
                print("/create_new/listing : \(statusCode)")
                dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
            }
        })
        task.resume()

    }
    
    func addImageForListing(listingID:String, image:UIImage, completionHandler:(success:Bool)->Void) {
        
        let format = NSDateFormatter()
        format.dateFormat = "yyyyMMddHHmmss"
        let now = NSDate()
        
        let filename = format.stringFromDate(now)
        
        let url = NSURL(string: "\(serverURL)/create_new/listing_image/listing_id=\(listingID)")!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        let boundary = "---------------------------Boundary Line---------------------------"
        let contentTpe = "multipart/form-data; boundary=\(boundary)"
        request.addValue(contentTpe, forHTTPHeaderField: "Content-Type")
        
        let body = NSMutableData()
        body.appendData("\r\n--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("Content-Disposition: form-data; name=\"userfile\"; filename=\"\(filename).jpg\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("Content-Type: application/octet-stream\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData(UIImageJPEGRepresentation(image, 90)!)
        body.appendData("\r\n--\(boundary)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        request.HTTPBody = body
        request.addValue("\(body.length)", forHTTPHeaderField: "Content-Length")
        
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            if error != nil {
                completionHandler(success: false)
                return
            }
            
            print(response)
            
            let statusCode = (response as? NSHTTPURLResponse)!.statusCode
            switch statusCode {
            case 201:
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    guard let mediaImageLink = json["image_media_link"] as? String else { return }
                    
//                    guard let user = self.getLocalUser() else { return }
                    
                    
                    let realm = try! Realm()
                    guard let listing = realm.objects(Listing).filter("listingID == \"\(listingID)\"").first else { return }
                    
                    try! realm.write {
                        let link = RealmString()
                        link.value = mediaImageLink
                        listing.imageLinks.append(link)
                    }
                    
                    print(listing)
                    
                    completionHandler(success: true)
                } catch {
                    completionHandler(success: false)
                }
                
            default:
                print("/create_new/listing_image : \(statusCode)")
                completionHandler(success: false)
            }
        })
        task.resume()
    }
    
    func updateListing(listingID:String, name:String, categoryID:String, totalValue:Double, hourlyRate:Double, dailyRate:Double, weeklyRate:Double, itemDescription:String, completionHandler:(success:Bool)->Void) {
        
        // Create the request
        let urlString = "\(serverURL)/update/listing"
        let params = ["listing_id":listingID, "name":name, "category_id":categoryID, "total_value":totalValue, "hourly_rate":hourlyRate, "daily_rate":dailyRate, "weekly_rate":weeklyRate, "item_description":itemDescription] as [String:AnyObject]
        guard let request = URLServiceProvider().getNewJsonPostRequest(withURL: urlString, params: params) else { return }
        
        
        // Execute the request
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {
            
            // Handle the response
            (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            if error != nil {
                dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
                return
            }
            
            let statusCode = (response as? NSHTTPURLResponse)!.statusCode
            switch statusCode {
            case 200:   // Catching status code 200, success
                do {
                    
                    // Parse the JSON response object
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    guard let name              = json["name"] as? String else { return }
                    guard let categoryID        = json["category_id"] as? String else { return }
                    guard let totalValue        = json["total_value"] as? Double else { return }
                    guard let hourlyRate        = json["hourly_rate"] as? Double else { return }
                    guard let dailyRate         = json["daily_rate"] as? Double else { return }
                    guard let weeklyRate        = json["weekly_rate"] as? Double else { return }
                    guard let itemDescription   = json["item_description"] as? String else { return }
                    let dateFormatter           = NSDateFormatter()
                    dateFormatter.dateFormat    = "yyyy MM dd HH:mm:SS"
                    guard let dateLastModified  = dateFormatter.dateFromString(json["date_last_modified"] as! String) else { return }
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        // Update the local data cache
                        let realm   = try! Realm()
                        guard let listing = realm.objects(Listing).filter("listingID == \"\(listingID)\"").first else { return }
                        
                        try! realm.write {
                            listing.name                = name
                            listing.categoryID          = categoryID
                            listing.totalValue.value    = totalValue
                            listing.hourlyRate.value    = hourlyRate
                            listing.dailyRate.value     = dailyRate
                            listing.weeklyRate.value    = weeklyRate
                            listing.itemDescription     = itemDescription
                            listing.dateLastModified    = dateLastModified
                        }
                        
                        completionHandler(success: true)
                    })
                } catch {
                    dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
                }
            default:
                print("/update/listing : \(statusCode)")
                dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
            }
        })
        task.resume()
    }
    
    
    func fetchListing(listingID:String, completionHandler:(success:Bool)->Void) {
        print("fetch listing")
        let realm = try! Realm()
        let listings = realm.objects(Listing).filter("listingID == \"\(listingID)\"")
        if listings.count > 0 {
            completionHandler(success: true)
            return
        }
        
        // Create the request
        let urlString       = "\(serverURL)/request/listing"
        let params          = ["listing_id":listingID]
        guard let request   = URLServiceProvider().getNewJsonPostRequest(withURL: urlString, params: params) else { return }
        
        // Execute the request
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {
            
            // Handle the server response
            (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            if error != nil {
                completionHandler(success: false)
                return
            }
            
            print("refresh listing response handler")
            
            let realm = try! Realm()
            
            let statusCode = (response as? NSHTTPURLResponse)!.statusCode
            switch statusCode {
            case 200: // Catching status code 200, success
                
                do {
                    // Parse the JSON response
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    guard let listingID         = json["listing_id"]        as? String else { return }
                    guard let name              = json["name"]              as? String else { return }
                    guard let ownerID           = json["owner_id"]          as? String else { return }
                    let renterID                = json["renter_id"]         as? String
                    guard let status            = json["status"]            as? String else { return }
                    guard let itemDescription   = json["item_description"]  as? String else { return }
                    let rating                  = json["rating"]            as? Double
                    guard let totalValue        = json["total_value"]       as? Double else { return }
                    guard let hourlyRate        = json["hourly_rate"]       as? Double else { return }
                    guard let dailyRate         = json["daily_rate"]        as? Double else { return }
                    guard let weeklyRate        = json["weekly_rate"]       as? Double else { return }
                    guard let categoryID        = json["category_id"]       as? String else { return }
                    let dateFormatter           = NSDateFormatter()
                    dateFormatter.dateFormat    = "yyyy MM dd HH:mm:SS"
                    guard let dateLastModified  = dateFormatter.dateFromString(json["date_last_modified"] as! String) else { return }
                    
                    
                    print("refresh listing update")
                    // Add the FavoriteMeetingLocation entity to the local cache
                    let listing = Listing()
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
                    
                    print("Refresh listing returning success")
                    
                    completionHandler(success: true)
                } catch {
                    completionHandler(success: false)
                }
            default:
                print("/request/listing : \(statusCode)")
                completionHandler(success: false)
            }
        })
        task.resume()

    }

}

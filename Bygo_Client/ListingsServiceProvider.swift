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
        
        // TODO: If it has been more than a day since the last fetch, delete the cached results and fetch again
        
        let realm = try! Realm()
        let cachedResults = realm.objects(Listing).filter("ownerID == \"\(userID)\"")
        if cachedResults.count > 0 { completionHandler(success: true); return }
        
        // Create the request
        let urlString       = "\(serverURL)/listing/get_users_listings/user_id=\(userID)"
        guard let request = URLServiceProvider().getNewGETRequest(withURL: urlString) else { return }
        
        print("Executing request")
        
        // Execute the request
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {
            
            // Handle the server response
            (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in

            print(response)

            if error != nil {
                dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
                return
            }
            
            let statusCode = (response as? NSHTTPURLResponse)!.statusCode
            
            print(statusCode)
            switch statusCode {
            case 200: // Catching status code 200, success
                
                do {
                    
                    print(200)
                    // Parse the JSON response
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    guard let listingsData = json["listings_data"] as? [[String:AnyObject]] else { return }
                    
                    print("\n\nLISTINGS DATA\n\(listingsData)")
                    
                    let realm = try! Realm()
                    
                    for listingData in listingsData {
                        guard let listingID = listingData["listing_id"] as? String else { return }
                        guard let ownerID   = listingData["owner_id"] as? String else { return }
                        guard let status    = listingData["status"] as? String else { return }
                        guard let typeID    = listingData["type_id"] as? String else { return }
                        let renterID        = listingData["renter_id"] as? String
                        let itemDescription = listingData["item_description"] as? String
                        let rating          = listingData["rating"] as? Double
                        let mediaLinks      = listingData["image_media_links"] as? [String]
                        
                        
                        // Add the FavoriteMeetingLocation entity to the local cache
                        let listing                 = Listing()
                        listing.listingID           = listingID
                        listing.ownerID             = ownerID
                        listing.typeID              = typeID
                        listing.renterID            = renterID
                        listing.status              = status
                        listing.itemDescription     = itemDescription
                        listing.rating.value        = rating

                        if let mediaLinks = mediaLinks {
                            for link in mediaLinks {
                                let realmLink   = RealmString()
                                realmLink.value = link
                                listing.imageLinks.append(realmLink)
                            }
                        }
                        
                        try! realm.write {
                            realm.add(listing)
                        }
                    }
                    
                    completionHandler(success: true)
                    
                } catch {
                    print("Catching error")
                    dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
                }
            default:
                print("/request/users_listings : \(statusCode)")
                dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
            }
        })
        task.resume()
    }
    
    func fetchUsersRentedListings(userID:String, completionHandler:(success:Bool)->Void) {
        // First check the local cache
        
        // TODO: If it has been more than a day since the last fetch, delete the cached results and fetch again
        
        let realm = try! Realm()
        let cachedResults = realm.objects(Listing).filter("renterID == \"\(userID)\"")
        if cachedResults.count > 0 { completionHandler(success: true); return }
        
        // Create the request
        let urlString       = "\(serverURL)/listing/get_users_rented_listings/user_id=\(userID)"
        guard let request = URLServiceProvider().getNewGETRequest(withURL: urlString) else { return }
        
        
        // Execute the request
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {
            
            // Handle the server response
            (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            
            print(response)
            
            if error != nil {
                dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
                return
            }
            
            let statusCode = (response as? NSHTTPURLResponse)!.statusCode
            
            print(statusCode)
            switch statusCode {
            case 200: // Catching status code 200, success
                
                do {
                    
                    print(200)
                    // Parse the JSON response
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    guard let listingsData = json["listings_data"] as? [[String:AnyObject]] else { return }
                    
                    let realm = try! Realm()
                    
                    for listingData in listingsData {
                        guard let listingID = listingData["listing_id"] as? String else { return }
                        guard let ownerID   = listingData["owner_id"] as? String else { return }
                        guard let status    = listingData["status"] as? String else { return }
                        guard let typeID    = listingData["type_id"] as? String else { return }
                        let renterID        = listingData["renter_id"] as? String
                        let itemDescription = listingData["item_description"] as? String
                        let rating          = listingData["rating"] as? Double
                        let mediaLinks      = listingData["image_media_links"] as? [String]
                        
                        
                        // Add the FavoriteMeetingLocation entity to the local cache
                        let listing                 = Listing()
                        listing.listingID           = listingID
                        listing.ownerID             = ownerID
                        listing.typeID              = typeID
                        listing.renterID            = renterID
                        listing.status              = status
                        listing.itemDescription     = itemDescription
                        listing.rating.value        = rating
                        
                        if let mediaLinks = mediaLinks {
                            for link in mediaLinks {
                                let realmLink   = RealmString()
                                realmLink.value = link
                                listing.imageLinks.append(realmLink)
                            }
                        }
                        
                        try! realm.write {
                            realm.add(listing)
                        }
                    }
                    
                    completionHandler(success: true)
                    
                } catch {
                    print("Catching error")
                    dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
                }
            default:
                print("/listing/get_users_rented_listings: \(statusCode)")
                dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
            }
        })
        task.resume()
    }
    
    func createNewListing(userID:String, typeID:String, image:UIImage, completionHandler:(success:Bool, error:BygoError?)->Void) {
        
        // Create the request
        let urlString = "\(serverURL)/listing/create"
        let params:[String:AnyObject] = ["user_id":userID, "type_id": typeID]
        guard let request = URLServiceProvider().getNewJsonPostRequest(withURL: urlString, params: params) else { return }
        

        // Execute the request
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {
            
            // Handle the response
            (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            if error != nil {
                dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false, error: .Unknown) })
                return
            }
            
            let statusCode = (response as? NSHTTPURLResponse)!.statusCode
            switch statusCode {
            case 201:       // Catching status code 201, success

                // Parse the JSON response object
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    guard let listingID = json["listing_id"] as? String else { return }
                    
                    // Add new Listing to local cache
                    let realm                   = try! Realm()
                    let listing                 = Listing()
                    listing.listingID           = listingID
                    
                    try! realm.write { realm.add(listing) }
                    self.addImageForListing(listingID, image: image, completionHandler: {
                        (success:Bool) in
                        dispatch_async(GlobalMainQueue, {
                            completionHandler(success: success, error: nil)
                        })
                    })
                } catch {
                    completionHandler(success: false, error: .Unknown)
                }
                
            case 400:
                
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    guard let message = json["message"] as? String else { completionHandler(success: false, error: .Unknown); return }
                    
                    switch message {
                    case "Home address not found":
                        completionHandler(success: false, error: .HomeAddressNotFound)
                    
                    case "Phone number not found":
                        completionHandler(success: false, error: .PhoneNumberNotFound)
                        
                    case "Phone number not verified":
                        completionHandler(success: false, error: .PhoneNumberNotVerified)
                        
                    default:
                        completionHandler(success: false, error: .Unknown)
                    }
                } catch {
                    completionHandler(success: false, error: .Unknown)
                }
                

            default:
                print("/listing/create : \(statusCode)")
                completionHandler(success: false, error: .Unknown)
            }
        })
        task.resume()

    }
    
    func addImageForListing(listingID:String, image:UIImage, completionHandler:(success:Bool)->Void) {
        
        let format = NSDateFormatter()
        format.dateFormat = "yyyyMMddHHmmss"
        let now = NSDate()
        
        let filename = format.stringFromDate(now)
        
        let url = NSURL(string: "\(serverURL)/listing/create_listing_image/listing_id=\(listingID)")!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        let boundary = "---------------------------Boundary Line---------------------------"
        let contentTpe = "multipart/form-data; boundary=\(boundary)"
        request.addValue(contentTpe, forHTTPHeaderField: "Content-Type")
        
        let body = NSMutableData()
        body.appendData("\r\n--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("Content-Disposition: form-data; name=\"userfile\"; filename=\"\(filename).jpg\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("Content-Type: application/octet-stream\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData(UIImageJPEGRepresentation(image, 0.25)!)
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
                    guard let ownerID           = json["owner_id"]          as? String else { return }
                    let renterID                = json["renter_id"]         as? String
                    guard let status            = json["status"]            as? String else { return }
                    guard let itemDescription   = json["item_description"]  as? String else { return }
                    let rating                  = json["rating"]            as? Double
                    
                    
                    // Add the FavoriteMeetingLocation entity to the local cache
                    let listing = Listing()
                    listing.listingID           = listingID
                    listing.ownerID             = ownerID
                    listing.renterID            = renterID
                    listing.status              = status
                    listing.itemDescription     = itemDescription
                    listing.rating.value        = rating
                    
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


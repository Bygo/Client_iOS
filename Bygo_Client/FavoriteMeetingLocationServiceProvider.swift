//
//  FavoriteMeetingLocationServiceProvider.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 2/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import RealmSwift

class FavoriteMeetingLocationServiceProvider: NSObject {
    let serverURL:String
    
    init(serverURL:String) {
        self.serverURL = serverURL
    }
    
    
    // MARK: - Queries
    // Query for a set of favorite meeting locations
    func fetchUsersFavoriteMeetingLocations(userID:String, completionHandler:(success:Bool)->Void) {
        
        // First check the local cache
        let realm = try! Realm()
        let cachedResults = realm.objects(FavoriteMeetingLocation).filter("userID == \"\(userID)\"").sorted("name", ascending: true)
        if cachedResults.count > 0 {
            completionHandler(success: true)
            return
        }
        
        // If no FavoriteMeetingLocations were found for this user, query the database
        
        // Create the request
        let urlString = "\(serverURL)/request/users_favorite_meeting_locations"
        let params = ["user_id":userID]
        guard let request = URLServiceProvider().getNewJsonPostRequest(withURL: urlString, params: params) else { return }
        
        // Execute the request
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {
            
            // Handle the server response
            (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            if error != nil {
                dispatch_async(dispatch_get_main_queue(), { completionHandler(success: true) })
                return
            }
            
            let realm = try! Realm()
            
            let statusCode = (response as? NSHTTPURLResponse)!.statusCode
            switch statusCode {
            case 200: // Catching status code 200, success
                
                do {
                    // Parse the JSON response
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    guard let locations = json["locations"] as? [[String:AnyObject]] else { return }
                    for location in locations {
                        guard let locationID        = location["location_id"] as? String else { return }
                        guard let googlePlacesID    = location["google_places_id"] as? String else { return }
                        guard let address           = location["address"] as? String else { return }
                        guard let name              = location["name"] as? String else { return }
                        guard let isPrivate         = location["is_private"] as? Bool else { return }
                        let dateFormatter           = NSDateFormatter()
                        dateFormatter.dateFormat    = "yyyy MM dd HH:mm:SS"
                        guard let dateLastModified  = dateFormatter.dateFromString(location["date_last_modified"] as! String) else { return }
                        
                        
                        // Add the FavoriteMeetingLocation entity to the local cache
                        let location                = FavoriteMeetingLocation()
                        location.locationID         = locationID
                        location.googlePlacesID     = googlePlacesID
                        location.address            = address
                        location.name               = name
                        location.isPrivate          = isPrivate
                        location.userID             = userID
                        location.dateLastModified   = dateLastModified
                        
                        try! realm.write {
                            realm.add(location)
                        }
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), { completionHandler(success: true) })
                } catch {
                    dispatch_async(dispatch_get_main_queue(), { completionHandler(success: true) })
                }
            default:
                dispatch_async(dispatch_get_main_queue(), { completionHandler(success: true) })
            }
        })
        task.resume()
    }
    
    func queryForFavoriteMeetingLocations(locationIDs:[String], completionHandler:(favoriteMeetingLocations:[FavoriteMeetingLocation])->Void) {
        
        let realm = try! Realm()
        
        var cachedFavoriteMeetingLocations:[FavoriteMeetingLocation] = []
        var uncachedLocationIDs:[String] = []
        
        // For each locationID, check the the local cache for the FavoriteMeetingLocation
        for locationID in locationIDs {
            
            let cachedResult:Results<FavoriteMeetingLocation> = realm.objects(FavoriteMeetingLocation).filter("locationID == \"\(locationID)\"")
            if let location = cachedResult.first {
                
                // TODO: If time sice dateLastModifed is greater than some pre determined constant, redownload the entity
                cachedFavoriteMeetingLocations.append(location)
                
            } else {
                uncachedLocationIDs.append(locationID)
            }
        }
        
        // If all of the locations were found in the local cache, just return
        if uncachedLocationIDs.count == 0 {
            completionHandler(favoriteMeetingLocations: cachedFavoriteMeetingLocations)
        }
        
        // Fetch all of the uncached FavoriteMeetingLocations from the server
        downloadFavoriteMeetingLocations(uncachedLocationIDs, completionHandler: {
            (fetchedFavoriteMeetingLocations:[FavoriteMeetingLocation])->Void in
            
            // Return the cached and fetch FavoriteMeetingLocations together
            cachedFavoriteMeetingLocations.appendContentsOf(fetchedFavoriteMeetingLocations)
            completionHandler(favoriteMeetingLocations: cachedFavoriteMeetingLocations)
        })
    }
    
    private func downloadFavoriteMeetingLocations(locationIDs:[String], completionHandler:(favoriteMeetingLocations:[FavoriteMeetingLocation])->Void) {
        
        var fetchedLocations:[FavoriteMeetingLocation] = []
        
        // Create the request
        let urlString = "\(serverURL)/request/favorite_meeting_locations"
        let params = ["location_ids":locationIDs]
        guard let request = URLServiceProvider().getNewJsonPostRequest(withURL: urlString, params: params) else {
            completionHandler(favoriteMeetingLocations: fetchedLocations)
            return
        }
        
        // Execute the request
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {
            
            // Handle the response
            (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            if error != nil {
                dispatch_async(dispatch_get_main_queue(), { completionHandler(favoriteMeetingLocations: fetchedLocations) })
                return
            }
            
            let statusCode = (response as? NSHTTPURLResponse)!.statusCode
            switch statusCode {
            case 200: // Catching status code 200, Success
                
                do {
                    // Parse JSON response data
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    guard let serverLocations = json["locations"] as? [[String:AnyObject]] else {
                        dispatch_async(dispatch_get_main_queue(), { completionHandler(favoriteMeetingLocations: fetchedLocations) })
                        return
                    }
                    
                    dispatch_async(GlobalMainQueue, {
                        let realm = try! Realm()
                        
                        for location in serverLocations {
                            guard let locationID        = location["location_id"] as? String else { return }
                            guard let googlePlacesID    = location["google_places_id"] as? String else { return }
                            guard let address           = location["address"] as? String else { return }
                            guard let name              = location["name"] as? String else { return }
                            guard let userID            = location["user_id"] as? String else { return }
                            guard let isPrivate         = location["is_private"] as? Bool else { return }
                            let dateFormatter           = NSDateFormatter()
                            dateFormatter.dateFormat    = "yyyy MM dd HH:mm:SS"
                            guard let dateLastModified  = dateFormatter.dateFromString(location["date_last_modified"] as! String) else { return }
                            
                            
                            // Create and cache new FavoriteMeetingLocation object
                            let location                = FavoriteMeetingLocation()
                            location.locationID         = locationID
                            location.googlePlacesID     = googlePlacesID
                            location.address            = address
                            location.name               = name
                            location.isPrivate          = isPrivate
                            location.dateLastModified   = dateLastModified
                            location.userID             = userID
                            
                            try! realm.write { realm.add(location) }
                            
                            fetchedLocations.append(location)
                        }
                        
                        completionHandler(favoriteMeetingLocations: fetchedLocations)
                    })
                } catch {
                    dispatch_async(dispatch_get_main_queue(), { completionHandler(favoriteMeetingLocations: fetchedLocations) })
                }
                
            default: // Catching some unexpected status code
                print("/request/favorite_meeting_locations – \(statusCode)")
                dispatch_async(dispatch_get_main_queue(), { completionHandler(favoriteMeetingLocations: fetchedLocations) })
            }
        })
        task.resume()
    }
    

    
    // MARK: - Create New
    func createNewFavoriteMeetingLocation(googlePlacesID:String, address:String, name:String, isPrivate:Bool, completionHandler:(success:Bool)->Void) {
        
        // Create the request
        guard let localUser = UserServiceProvider(serverURL: serverURL).getLocalUser() else { return }
        guard let userID = localUser.userID else { return }
        let urlString = "\(serverURL)/create_new/favorite_meeting_location"
        let params:[String:AnyObject] = ["google_places_id":googlePlacesID, "user_id":userID, "address":address, "name":name, "isPrivate":isPrivate]
        
        print("Create new")
        guard let request = URLServiceProvider().getNewJsonPostRequest(withURL: urlString, params: params) else {
            completionHandler(success: false)
            return
        }
        
        
        // Execute the request
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {
            
            // Handle the server response
            (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            
            print("Handle response")
            if error != nil {
                dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
                return
            }

            let statusCode = (response as? NSHTTPURLResponse)!.statusCode
            print(statusCode)
            switch statusCode {
            case 201:   // Catching status code 201, success, new location created
                do {
                    
                    // Parse JSON response data
                    let json                    = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    guard let locationID        = json["location_id"] as? String else { return }
                    let dateFormatter           = NSDateFormatter()
                    dateFormatter.dateFormat    = "yyyy MM dd HH:mm:SS"
                    guard let dateLastModified  = dateFormatter.dateFromString(json["date_last_modified"] as! String) else { return }
                
                    dispatch_async(dispatch_get_main_queue(), {
                        // Create and cache new FavoriteMeetingLocation object
                        let realm = try! Realm()
                        let location                = FavoriteMeetingLocation()
                        location.locationID         = locationID
                        location.googlePlacesID     = googlePlacesID
                        location.address            = address
                        location.name               = name
                        location.isPrivate          = isPrivate
                        location.userID             = userID
                        location.dateLastModified   = dateLastModified
                        
                        try! realm.write { realm.add(location) }
                        
                        completionHandler(success: true)
                    })
                } catch {
                    dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
                }
            default:
                dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
            }
        })
        task.resume()
    }
    
    
    // MARK: - Upadate
    func updateFavoriteMeetingLocation(locationID:String, name:String, address:String, isPrivate:Bool, completionHandler:(success:Bool)->Void) {
        
        // Create the request
        let urlString = "\(serverURL)/update/favorite_meeting_location"
        let params = ["location_id":locationID, "name":name, "address":address, "isPrivate":isPrivate] as [String:AnyObject]
        guard let request = URLServiceProvider().getNewJsonPostRequest(withURL: urlString, params: params) else { return }

        // Execute the request
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {
            
            // Handle the server response
            (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            if error != nil {
                dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
                return
            }
            
            let statusCode = (response as? NSHTTPURLResponse)!.statusCode
            switch statusCode {
            case 200:
                do {
                    
                    // Parse the JSON response object
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    guard let name      = json["name"] as? String else { return }
                    guard let address   = json["address"] as? String else { return }
                    guard let isPrivate = json["is_private"] as? Bool else { return }
                    
                    
                    // Update the local cache
                    let realm           = try! Realm()
                    let results         = realm.objects(FavoriteMeetingLocation).filter("locationID == \"\(locationID)\"")
                    guard let location  = results.first else { return }
                    try! realm.write {
                        location.name = name
                        location.address = address
                        location.isPrivate = isPrivate
                    }

                    dispatch_async(dispatch_get_main_queue(), { completionHandler(success: true) })
                } catch {
                    dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
                }
            default:
                dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
            }
        })
        task.resume()
    }
    
    
    // MARK: - Delete
    func deleteFavoriteMeetingLocation(locationID:String, completionHandler:(success:Bool)->Void) {
        
        // Create the request
        let urlString = "\(serverURL)/delete/favorite_meeting_location"
        let params = ["location_id":locationID]
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
            case 200:   // Catching 200, successfully deleted FavoriteMeetingLocation
                
                // Delete the FavoriteMeetingLocation from local cache
                dispatch_async(dispatch_get_main_queue(), {
                    let realm = try! Realm()
                    let results = realm.objects(FavoriteMeetingLocation).filter("locationID == \"\(locationID)\"")
                    guard let location = results.first else { return }
                    try! realm.write { realm.delete(location) }
                    
                    completionHandler(success: true)
                })
            default:
                dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
            }
        })
        task.resume()
    }


}

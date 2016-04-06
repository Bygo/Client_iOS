//
//  OrderServiceProvider.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 5/4/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import RealmSwift

class OrderServiceProvider: NSObject {
    let serverURL:String
    
    init(serverURL:String) {
        self.serverURL = serverURL
    }
    
    func createOrder(userID: String, typeID: String, geoPoint: String, duration: Int, rentalFee: Double, completionHandler:(success:Bool, error:BygoError?)->Void) {
        // Create the request
        let urlString = "\(serverURL)/order/create"
        let params: [String: AnyObject] = ["user_id":userID, "type_id":typeID, "geo_point":geoPoint, "duration":duration, "rental_fee":rentalFee, "time_frame":"Daily"]
        
        guard let request = URLServiceProvider().getNewJsonPostRequest(withURL: urlString, params: params) else {
            completionHandler(success: false, error: .Unknown)
            return
        }
        
        // Execute the request
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            if error != nil {
                completionHandler(success: false, error: .Unknown)
                return
            }
            
            let statusCode = (response as? NSHTTPURLResponse)!.statusCode
            switch statusCode {
                
            case 201: // Catching status code 201. New user was created
                do {
                    
                    // Parse JSON response data
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    guard let orderID = json["order_id"] as? String else { return }
                    guard let renterID = json["renter_id"] as? String else { return }
                    guard let typeID = json["type_id"] as? String else { return }
                    guard let duration = json["duration"] as? Int else { return }
                    guard let timeFrame = json["time_frame"] as? String else { return }
                    guard let status = json["status"] as? String else { return }
                    guard let rentalFee = json["rental_fee"] as? Double else { return }
                    
                    
                    let o = Order()
                    o.orderID = orderID
                    o.renterID = renterID
                    o.typeID = typeID
                    o.duration.value = duration
                    o.timeFrame = timeFrame
                    o.status = status
                    o.rentalFee.value = rentalFee
                    
                    let realm = try! Realm()
                    try! realm.write {
                        realm.add(o)
                    }
                    completionHandler(success: true, error: nil)
                    
                } catch {
                    completionHandler(success: false, error: .Unknown)
                }
                
            case 400:
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    guard let message = json["message"] as? String else { completionHandler(success: false, error: .Unknown); return }
                    
                    switch message {
                    case "User not found":
                        completionHandler(success: false, error: .UserNotFound)
                        
                    case "Item type not found":
                        completionHandler(success: false, error: .ItemTypeNotFound)
                        
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
                print("/order/create \(statusCode)")
                completionHandler(success: false, error: .Unknown)
            }
        })
        task.resume()
    }
    
    func fetchUsersUnfilledOrders(userID:String, completionHandler:(success:Bool)->Void) {
        
        // TODO: If it has been more than a day since the last fetch, delete the cached results and fetch again
        let realm = try! Realm()
        let cachedResults = realm.objects(Order).filter("(renterID == \"\(userID)\") AND (status == \"Requested\" OR status == \"Offered\")")
        if cachedResults.count > 0 { completionHandler(success: true); return }
        
        // Create the request
        let urlString       = "\(serverURL)/order/get_users_orders/user_id=\(userID)"
        guard let request = URLServiceProvider().getNewGETRequest(withURL: urlString) else { return }
        
        // Execute the request
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {
            
            // Handle the server response
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
                    guard let ordersData = json["orders_data"] as? [[String:AnyObject]] else { return }
                    
                    let realm = try! Realm()
                    
                    for orderData in ordersData {
                        guard let orderID = orderData["order_id"] as? String else { return }
                        guard let renterID = orderData["renter_id"] as? String else { return }
                        guard let typeID = orderData["type_id"] as? String else { return }
                        guard let duration = orderData["duration"] as? Int else { return }
                        guard let timeFrame = orderData["time_frame"] as? String else { return }
                        guard let status = orderData["status"] as? String else { return }
                        guard let rentalFee = orderData["rental_fee"] as? Double else { return }
                        guard let offeredListings = orderData["offered_listings"] as? [String] else { return }
                        
                        
                        // Add the FavoriteMeetingLocation entity to the local cache
                        let o = Order()
                        o.orderID = orderID
                        o.renterID = renterID
                        o.typeID = typeID
                        o.duration.value = duration
                        o.timeFrame = timeFrame
                        o.status = status
                        o.rentalFee.value = rentalFee
                        
                        for l in offeredListings {
                            let s = RealmString()
                            s.value = l
                            o.offeredListings.append(s)
                        }
                        
                        try! realm.write {
                            realm.add(o)
                        }
                    }
                    
                    completionHandler(success: true)
                    
                } catch {
                    completionHandler(success: false)
                }
            default:
                completionHandler(success: false)
            }
        })
        task.resume()
    }
    
    func fetchOrder(orderID:String, completionHandler:(success:Bool)->Void) {
        // First check the local cache
        
        // TODO: If it has been more than a day since the last fetch, delete the cached results and fetch again
        let realm = try! Realm()
        let cachedResults = realm.objects(Order).filter("orderID == \"\(orderID)\"")
        if cachedResults.count > 0 { completionHandler(success: true); return }
        
        // Create the request
        let urlString       = "\(serverURL)/order/order_id=\(orderID)"
        guard let request = URLServiceProvider().getNewGETRequest(withURL: urlString) else { return }
        
        // Execute the request
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {
            
            // Handle the server response
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
                    
                    guard let orderID = json["order_id"] as? String else { return }
                    guard let renterID = json["renter_id"] as? String else { return }
                    guard let typeID = json["type_id"] as? String else { return }
                    guard let duration = json["duration"] as? Int else { return }
                    guard let timeFrame = json["time_frame"] as? String else { return }
                    guard let status = json["status"] as? String else { return }
                    guard let rentalFee = json["rental_fee"] as? Double else { return }
                    guard let offeredListings = json["offered_listings"] as? [String] else { return }
                    
                    
                    // Add the FavoriteMeetingLocation entity to the local cache
                    let o = Order()
                    o.orderID = orderID
                    o.renterID = renterID
                    o.typeID = typeID
                    o.duration.value = duration
                    o.timeFrame = timeFrame
                    o.status = status
                    o.rentalFee.value = rentalFee
                    
                    for l in offeredListings {
                        let s = RealmString()
                        s.value = l
                        o.offeredListings.append(s)
                    }
                    
                    let realm = try! Realm()
                    try! realm.write {
                        realm.add(o)
                    }
                    
                    completionHandler(success: true)
                    
                } catch {
                    completionHandler(success: false)
                }
            default:
                completionHandler(success: false)
            }
        })
        task.resume()
    }
    
    func cancelOrder(orderID: String, completionHandler:(success:Bool, error:BygoError?)->Void) {
        // Create the request
        let urlString       = "\(serverURL)/order/cancel/order_id=\(orderID)"
        guard let request = URLServiceProvider().getNewDELETERequest(withURL: urlString) else { return }
        
        // Execute the request
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {
            
            // Handle the server response
            (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            
            if error != nil {
                completionHandler(success: false, error: .Unknown)
                return
            }
            
            let statusCode = (response as? NSHTTPURLResponse)!.statusCode
            
            switch statusCode {
            case 204:
                
                let realm = try! Realm()
                let order = realm.objects(Order).filter("orderID == \"\(orderID)\"")[0]
                
                try! realm.write {
                    order.status = "Canceled"
                }
                
                completionHandler(success: true, error: nil)
                
            default:
                completionHandler(success: false, error: .Unknown)
            }
        })
        task.resume()
    }
}

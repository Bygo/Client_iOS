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
                    guard let userID = json["user_id"] as? String else { return }
                    guard let typeID = json["type_id"] as? String else { return }
                    guard let duration = json["duration"] as? Int else { return }
                    guard let timeFrame = json["time_frame"] as? String else { return }
                    guard let status = json["status"] as? String else { return }
                    guard let rentalFee = json["rental_fee"] as? Double else { return }
                    
                    
                    let o = Order()
                    o.orderID = orderID
                    o.userID = userID
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
}

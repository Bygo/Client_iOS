//
//  HistoryServiceProvider.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 2/4/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import RealmSwift

class HistoryServiceProvider: NSObject {

    let serverURL: String
    
    init(serverURL:String) {
        self.serverURL = serverURL
    }
    
    func fetchUsersHistoricalRentEvents(userID:String, completionHandler:(success:Bool)->Void) {
        let realm = try! Realm()
        let cachedEvents = realm.objects(RentEvent).filter("((renterID == \"\(userID)\") OR (ownerID == \"\(userID)\")) AND ((status == \"Concluded\"))")
        if cachedEvents.count > 0 {
            completionHandler(success: true)
            return
        }
        
        let urlString = "\(serverURL)/rent_event/users_history/user_id=\(userID)"
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
                    
                    // TODO: Complete when orders are done
                    
                    print(json)
                    
                    completionHandler(success: true)
                } catch {
                    completionHandler(success: false)
                }
            default:
                print("/rent_event/users_history/ : \(statusCode)")
                completionHandler(success: false)
            }
        })
        task.resume()
    }
}

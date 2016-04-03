//
//  NotificationsServiceProvider.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 2/4/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class NotificationServiceProvider: NSObject {
    let serverURL:String
    
    init(serverURL:String) {
        self.serverURL = serverURL
    }
    
    func fetchUsersNotificationData(userID:String, completionHandler:(data:AnyObject?)->Void) {
        // Create the request
        let urlString       = "\(serverURL)/notification/get_users_notification_data/user_id=\(userID)"
        guard let request = URLServiceProvider().getNewGETRequest(withURL: urlString) else { completionHandler(data: nil); return }
        
        
        // Execute the request
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {
            
            // Handle the server response
            (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            if error != nil {
                dispatch_async(dispatch_get_main_queue(), { completionHandler(data: nil) })
                return
            }
            
            let statusCode = (response as? NSHTTPURLResponse)!.statusCode
            switch statusCode {
            case 200: // Catching status code 200, success
                
                do {
                    // Parse the JSON response
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    guard let notificationData = json["notification_data"] else { completionHandler(data: nil); return }
                    dispatch_async(dispatch_get_main_queue(), { completionHandler(data: notificationData) })
                } catch {
                    dispatch_async(dispatch_get_main_queue(), { completionHandler(data: nil) })
                }
            default:
                print("/notification/get_users_notification_data/ : \(statusCode)")
                dispatch_async(dispatch_get_main_queue(), { completionHandler(data: nil) })
            }
        })
        task.resume()
        
    }
}

//
//  DiscoveryServiceProvider.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 27/3/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import RealmSwift

class DiscoveryServiceProvider: NSObject {
    let serverURL:String
    
    
    init(serverURL:String) {
        self.serverURL = serverURL
    }
    
    
    func fetchDefaultHomePageData(completionHandler:(data:AnyObject?)->Void) {
        // Create the request
        let urlString       = "\(serverURL)/discovery/default_home_page"
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
                    guard let layoutData = json["layout_data"] else { completionHandler(data: nil); return }
                    dispatch_async(dispatch_get_main_queue(), { completionHandler(data: layoutData) })
                } catch {
                    dispatch_async(dispatch_get_main_queue(), { completionHandler(data: nil) })
                }
            default:
                print("/discovery/default_home_page : \(statusCode)")
                dispatch_async(dispatch_get_main_queue(), { completionHandler(data: nil) })
            }
        })
        task.resume()

    }
    
    
    func search(query: String, completionHanlder:(data:AnyObject?)->Void) {
        
        // Create the request
        let urlString = "\(serverURL)/discovery/search_item_types"
        let params = ["query":query]
        //        print(params)
        guard let request = URLServiceProvider().getNewJsonPostRequest(withURL: urlString, params: params) else { completionHanlder(data: nil); return }
        // guard let request = URLServiceProvider().getNewGETRequest(withURL: urlString) else { completionHanlder(data: nil); return }
        print(request)
        
        // Execute the request
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {
            
            // Handle the server response
            (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            if error != nil {
                dispatch_async(dispatch_get_main_queue(), { completionHanlder(data: nil) })
                return
            }
            
            let statusCode = (response as? NSHTTPURLResponse)!.statusCode
            switch statusCode {
            case 200: // Catching status code 200, success
                
                do {
                    // Parse the JSON response
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    guard let layoutData = json["layout_data"] else { completionHanlder(data: nil); return }
                    dispatch_async(GlobalMainQueue, { completionHanlder(data: layoutData) })
                } catch {
                    dispatch_async(dispatch_get_main_queue(), { completionHanlder(data: nil) })
                }
            default:
                print("/discovery/search : \(statusCode)")
                dispatch_async(dispatch_get_main_queue(), { completionHanlder(data: nil) })
            }
        })
        task.resume()
    }
}


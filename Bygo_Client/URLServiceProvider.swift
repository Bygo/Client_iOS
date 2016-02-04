//
//  URLServiceProvider.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 1/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class URLServiceProvider: NSObject {
    
    // Creates a new JSON POST request with the given URL string and parameters
    func getNewJsonPostRequest(withURL urlString:String, params:[String:AnyObject]) -> NSURLRequest? {
        guard let url = NSURL(string: urlString) else { return nil }
        let request = NSMutableURLRequest(URL: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.HTTPMethod = "POST"
        
        do {
            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: [])
            return request
        } catch {
            print("Error creating JSON POST request")
            return nil
        }
    }
}

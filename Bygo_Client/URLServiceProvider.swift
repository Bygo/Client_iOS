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
        guard let url   = NSURL(string: urlString) else { return nil }
        let request     = NSMutableURLRequest(URL: url)
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
    
    
    // Creates a new GET request with the give URL string
    func getNewGETRequest(withURL urlString:String) -> NSURLRequest? {
        guard let url = NSURL(string: urlString) else { return nil }
        let request = NSMutableURLRequest(URL: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.HTTPMethod = "GET"
        return request
    }
    
    func getNewDELETERequest(withURL urlString:String) -> NSURLRequest? {
        guard let url = NSURL(string: urlString) else { return nil }
        let request = NSMutableURLRequest(URL: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.HTTPMethod = "DELETE"
        return request
    }
    
    func downloadImage(url: NSURL, completionHandler:(image:UIImage?)->Void){
        getDataFromUrl(url) { (data, response, error)  in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                guard let data = data where error == nil else { return }
                completionHandler(image: UIImage(data: data))
            }
        }
    }
    
    // Get the data from this URL
    private func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
}

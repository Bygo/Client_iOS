//
//  CategoriesServiceProvider.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 3/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import RealmSwift

class CategoriesServiceProvider: NSObject {
    let serverURL:String
    
    init(serverURL:String) {
        self.serverURL = serverURL
    }
    
    func refreshCategories(completionHandler:(success:Bool)->Void) {
        
        // If there are Departments in the local cache, return success
        // FIXME: Bad assumptions here. Need to check some dateLastModified attribute
        let realm = try! Realm()
        if realm.objects(Category).count > 0 {
            completionHandler(success: true)
            return
        }
        
        // Create the request
        let urlString       = "\(serverURL)/request/all_categories"
        guard let request   = URLServiceProvider().getNewGETRequest(withURL: urlString) else { return }
        
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
            case 200: // Catching status code 200, success
                do {
                    
                    // Parse the JSON response object
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    guard let categoriesData = json["categories"] as? [[String:AnyObject]] else { return }
                    
                    dispatch_async(GlobalMainQueue, {
                        let realm = try! Realm()
                        
                        for categoryData in categoriesData {
                            guard let name          = categoryData["name"]          as? String else { return }
                            guard let departmentID  = categoryData["department_id"] as? String else { return }
                            guard let categoryID    = categoryData["category_id"]   as? String else { return }
                            
                            // Create the new Department entity
                            let category            = Category()
                            category.name           = name
                            category.departmentID   = departmentID
                            category.categoryID     = categoryID
                            try! realm.write { realm.add(category) }
                        }
                        
                        completionHandler(success: true)
                    })
                } catch {
                    dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
                }
            default:
                print("/request/all_categories : \(statusCode)")
                dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
            }
        })
        task.resume()
    }
}

//
//  ItemTypeServiceProvider.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 27/3/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import RealmSwift

class ItemTypeServiceProvider: NSObject {

    let serverURL:String
    
    
    init(serverURL:String) {
        self.serverURL = serverURL
    }
    
    func fetchItemType(typeID:String, completionHandler:(success:Bool)->Void) {
        let realm = try! Realm()
        let itemTypes = realm.objects(ItemType).filter("typeID == \"\(typeID)\"")
        if itemTypes.count > 0 {
            completionHandler(success: true)
            return
        }
        
        // Create the request
        let urlString       = "\(serverURL)/item_type/get/type_id=\(typeID)"
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
            
            let realm = try! Realm()
            let statusCode = (response as? NSHTTPURLResponse)!.statusCode
            switch statusCode {
            case 200: // Catching status code 200, success
                
                do {
                    // Parse the JSON response
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    
                    print(json)
                    
                    guard let typeID        = json["type_id"]       as? String else { return }
                    guard let name          = json["name"]          as? String else { return }
                    guard let value         = json["value"]         as? Double else { return }
                    guard let deliveryFee   = json["delivery_fee"]  as? Double else { return }
                    let mediaLinks    = json["image_media_links"] as? [String]
                    
                    // Add the FavoriteMeetingLocation entity to the local cache
                    let i = ItemType()
                    i.typeID = typeID
                    i.name = name
                    i.value.value = value
                    i.deliveryFee.value = deliveryFee
                    
                    if let mediaLinks = mediaLinks {
                        for link in mediaLinks {
                            let realmLink   = RealmString()
                            realmLink.value = link
                            i.imageLinks.append(realmLink)
                        }
                    }
                    
                    try! realm.write {
                        realm.add(i)
                    }
                    
                    completionHandler(success: true)
                } catch {
                    completionHandler(success: false)
                }
            default:
                print("/item_type/get/ : \(statusCode)")
                completionHandler(success: false)
            }
        })
        task.resume()
        
    }

}

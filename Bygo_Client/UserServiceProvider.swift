//
//  UserServiceProvider.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 1/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import RealmSwift

class UserServiceProvider: NSObject {
    let serverURL:String
    
    init(serverURL:String) {
        self.serverURL = serverURL
    }
    
    // MARK: - Queries
    // Query for user with userID
    func fetchUser(userID:String, completionHandler:(success:Bool)->Void) {
        let result:Results<User> = try! Realm().objects(User).filter("userID == \"\(userID)\"")
        if result.count == 0 {
            downloadUserPublicData(userID, completionHandler: completionHandler); return
        }
        completionHandler(success: true)
    }
    
    // Get the local user
    func getLocalUser() -> User? {
        guard let userID = NSUserDefaults.standardUserDefaults().valueForKey("LocalUserID") as? String else { return nil }
        let result:Results<User> = try! Realm().objects(User).filter("userID == \"\(userID)\"")
        guard let user = result.first else { return nil }
        return user
    }
    
    // Return if there is a local user
    func isLocalUserLoggedIn() -> Bool {
        return NSUserDefaults.standardUserDefaults().valueForKey("LocalUserID") as? String != nil
    }
    
    
    // MARK: - Create New
    func createNewUser(firstName:String, lastName:String, email:String, phoneNumber:String?, facebookID:String?, password:String?, signupMethod:String, completionHandler:(success:Bool)->Void) {
        
        // Create the request
        let urlString = "\(serverURL)/create_new/user"
        var params = ["first_name":firstName, "last_name":lastName, "email":email, "phone_number":"", "facebook_id":"", "password":"", "signup_method":signupMethod]
        if let notificationToken = (UIApplication.sharedApplication().delegate as? AppDelegate)?.registrationToken {
            params["notification_token"] = notificationToken
        }
        if let phoneNumber  = phoneNumber { params.updateValue(phoneNumber, forKey: "phone_number") }
        if let facebookID   = facebookID { params.updateValue(facebookID, forKey: "facebook_id") }
        if let password     = password { params.updateValue(password, forKey: "password") }
        guard let request = URLServiceProvider().getNewJsonPostRequest(withURL: urlString, params: params) else {
            completionHandler(success: false)
            return
        }
        
        // Execute the request
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            if error != nil {
                dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
                return
            }
            
            let statusCode = (response as? NSHTTPURLResponse)!.statusCode
            switch statusCode {
            case 200: // Catching status code 200. User was already in database. If signup method was facebook, user_id is returned
                
                // TODO: Handle this login case
                dispatch_async(dispatch_get_main_queue(), { completionHandler(success: true) })
                
            case 201: // Catching status code 201. New user was created
                do {
                    
                    // Parse JSON response data
                    let json                    = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    guard let userID            = json["user_id"] as? String else { return }
                    let dateFormatter           = NSDateFormatter()
                    dateFormatter.dateFormat    = "yyyy MM dd HH:mm:SS"
                    guard let dateLastModified  = dateFormatter.dateFromString(json["date_last_modified"] as! String) else { return }
                    
                    // Create new user
                    dispatch_async(dispatch_get_main_queue(), {
                        let user                    = User()
                        user.userID                 = userID
                        user.firstName              = firstName
                        user.lastName               = lastName
                        user.password               = password
                        user.facebookID             = facebookID
                        user.phoneNumber            = phoneNumber
                        user.email                  = email
                        user.dateLastModified       = dateLastModified
                        
                        let realm = try! Realm()
                        try! realm.write {
                            realm.add(user)
                        }
                        
                        // Save the LocalUserID to user defaults for easy login when the user closes and reopens the app
                        NSUserDefaults.standardUserDefaults().setObject(userID, forKey: "LocalUserID")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        
                        completionHandler(success: true)
                    })
                } catch {
                    dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
                }
            default:
                print("/create_new/user \(statusCode)")
                dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
            }
        })
        task.resume()
    }
    
    
    func setUserProfileImage(userID:String, image:UIImage, completionHandler:(success:Bool)->Void) {
        let filename = "profile_picture.jpg"
        
        let url = NSURL(string: "\(serverURL)/create_new/user_image/user_id=\(userID)")!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        let boundary = "---------------------------Boundary Line---------------------------"
        let contentTpe = "multipart/form-data; boundary=\(boundary)"
        request.addValue(contentTpe, forHTTPHeaderField: "Content-Type")
        
        let body = NSMutableData()
        body.appendData("\r\n--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("Content-Disposition: form-data; name=\"userfile\"; filename=\"\(filename)\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("Content-Type: application/octet-stream\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData(UIImageJPEGRepresentation(image, 90)!)
        body.appendData("\r\n--\(boundary)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        request.HTTPBody = body
        request.addValue("\(body.length)", forHTTPHeaderField: "Content-Length")
        
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            if error != nil {
                completionHandler(success: false)
                return
            }
            
            print(response)
            
            let statusCode = (response as? NSHTTPURLResponse)!.statusCode
            switch statusCode {
            case 201:
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    guard let mediaImage = json["image_media_link"] as? String else { return }
                    guard let user = self.getLocalUser() else { return }
                    
                    
                    let realm = try! Realm()
                    try! realm.write {
                        user.profileImageLink = mediaImage
                    }
                    
                    completionHandler(success: true)
                } catch {
                    completionHandler(success: false)
                }
            
            default:
                print("/create_new/user_image : \(statusCode)")
                completionHandler(success: false)
            }
        })
        task.resume()
    }
    
    // Download user public data from the server
    private func downloadUserPublicData(userID:String, completionHandler:(success:Bool)->Void) {
        
        // Create the request
        let urlString = "\(serverURL)/request/user_public_data/user_id=\(userID)"
        guard let request = URLServiceProvider().getNewGETRequest(withURL: urlString) else { return }
//        let params = ["user_id":userID]
//        guard let request = URLServiceProvider().getNewJsonPostRequest(withURL: urlString, params: params) else {
//            completionHandler(success: false)
//            return
//        }
        
        // Execute the request
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {
            (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            
            // Handle the response
            if error != nil {
                dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
                return
            }
            
            let statusCode = (response as? NSHTTPURLResponse)!.statusCode
            switch statusCode {
                
            case 200: // Catching success code 200
                do {
                    
                    // Parse JSON response data
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    guard let userID        = json["user_id"] as? String else { return }
                    guard let firstName     = json["first_name"] as? String else { return }
                    guard let lastName      = json["last_name"] as? String else { return }
                    guard let email         = json["email"] as? String else { return }
                    guard let phoneNumber   = json["phone_number"] as? String else { return }
                    let imageMediaLink      = json["image_media_link"] as? String
                    
                    // Create new user
                    let user            = User()
                    user.userID         = userID
                    user.firstName      = firstName
                    user.lastName       = lastName
                    user.email          = email
                    user.phoneNumber    = phoneNumber
                    user.profileImageLink = imageMediaLink
                    
                    let realm = try! Realm()
                    try! realm.write {
                        realm.add(user)
                    }
                    
                    completionHandler(success: true)
                } catch {
                    dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
                }
            default:
                dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
            }
        })
        task.resume()
    }
    
    
    // MARK: - Login Handlers
    // Send call to Bygo server to login with phone number and password
    func login(phoneNumber:String, password:String, completionHandler:(success:Bool)->Void) {
        
        // Create the request
        let urlString   = "\(serverURL)/login/user"
        var params      = ["login_id":phoneNumber, "password":password]
        if let notificationToken = (UIApplication.sharedApplication().delegate as? AppDelegate)?.registrationToken {
            params["notification_token"] = notificationToken
        }
        guard let request = URLServiceProvider().getNewJsonPostRequest(withURL: urlString, params: params) else {
            completionHandler(success: false)
            return
        }
        
        // Execute the request
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {
            (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            self.loginServerResponseHandler(data, response: response, error: error, completionHandler: completionHandler)
        })
        task.resume()   
    }
    
    // Send call to Facebook to get user data
    func attemptFacebookLogin(completionHandler:(data:[String:AnyObject]?)->Void) {
        let fbManager = FBSDKLoginManager()
        let permissions = ["public_profile", "email", "user_friends"]
       
        fbManager.logInWithReadPermissions(permissions, fromViewController: nil, handler: { (result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
            if error != nil {
                print(error)
                completionHandler(data: nil)
            } else if result.isCancelled {
                print("User cancelled the sign up")
                completionHandler(data: nil)
            } else {
                let fbParams = ["fields":"id, name, first_name, last_name, email, gender, age_range, picture.type(large)"]
                let fbRequest = FBSDKGraphRequest(graphPath:"me", parameters: fbParams);
                fbRequest.startWithCompletionHandler { (connection:FBSDKGraphRequestConnection!, result:AnyObject!, error:NSError!) -> Void in
                    if error == nil {
                        guard let data = result as? [String:AnyObject] else {
                            print("Data did not convert to dictionary type")
                            return
                        }
                        completionHandler(data: data)
                    } else {
                        print("Error Getting Info \(error)")
                        completionHandler(data: nil)
                    }
                }
            }
        })
    }
    
    // Send call to Bygo server to login with facebookID
    func login(facebookID:String, completionHandler:(success:Bool)->Void) {
        
        // Create the request
        let urlString = "\(serverURL)/login/facebook_user"
        var params = ["facebook_id":facebookID]
        if let notificationToken = (UIApplication.sharedApplication().delegate as? AppDelegate)?.registrationToken {
            params["notification_token"] = notificationToken
        }
        guard let request = URLServiceProvider().getNewJsonPostRequest(withURL: urlString, params: params) else {
            completionHandler(success: false)
            return
        }
        
        // Execute the request
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {
            (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            self.loginServerResponseHandler(data, response: response, error: error, completionHandler: completionHandler)
        })
        task.resume()
        
    }
    
    // Handle the Bygo server login response
    private func loginServerResponseHandler(data:NSData?, response:NSURLResponse?, error:NSError?, completionHandler:(success:Bool)->Void) {
        if error != nil {
            print("Server returned an error \(error)")
            dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
            return
        }
        
        let statusCode = (response as? NSHTTPURLResponse)!.statusCode
        switch statusCode {
            
        case 200: // Catch status code 200, SUCCESS
            do {
                
                print("Catching 200")
                // Parse JSON response data
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                
                print(json)
                
                guard let userID                = json["user_id"] as? String else { return }
                guard let firstName             = json["first_name"] as? String else { return }
                guard let lastName              = json["last_name"] as? String else { return }
                let password                    = json["password"] as? String
                let facebookID                  = json["facebook_id"] as? String
                let phoneNumber                 = json["phone_number"] as? String
                guard let isPhoneNumberVerified = json["is_phone_number_verified"] as? Bool else { return }
                guard let email                 = json["email"] as? String else { return }
                guard let isEmailVerified       = json["is_phone_number_verified"] as? Bool else { return }
                guard let credit                = json["credit"] as? Double else { return }
                guard let debit                 = json["debit"] as? Double else { return }
                let mediaImageLink              = json["image_media_link"] as? String
                let dateFormatter               = NSDateFormatter()
                dateFormatter.dateFormat        = "yyyy MM dd HH:mm:SS"
                guard let dateLastModified      = dateFormatter.dateFromString(json["date_last_modified"] as! String) else { return }
                
                // Create new user
                let user                    = User()
                user.userID                 = userID
                user.firstName              = firstName
                user.lastName               = lastName
                user.password               = password
                user.facebookID             = facebookID
                user.phoneNumber            = phoneNumber
                user.isPhoneNumberVerified  = isPhoneNumberVerified
                user.email                  = email
                user.isEmailVerified        = isEmailVerified
                user.credit                 = credit
                user.debit                  = debit
                user.dateLastModified       = dateLastModified
                user.profileImageLink       = mediaImageLink
                
                let realm = try! Realm()
                try! realm.write { realm.add(user) }
                
                // Save the LocalUserID to user defaults for easy login when the user closes and reopens the app
                NSUserDefaults.standardUserDefaults().setObject(userID, forKey: "LocalUserID")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                completionHandler(success: true)
                
            } catch {
                completionHandler(success: false)
            }
            
        default:
            print("/login : \(statusCode)")
            completionHandler(success: false)
        }
    }
    
    // MARK: - Logout
    func logout(completionHandler:(success:Bool)->Void) {
        
        // Delete entire local data cache
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
        
        // TODO: Must also disable push notifications
        // TODO: (Possibly) remove the registration token that this app registered for
        
        NSUserDefaults.standardUserDefaults().removeObjectForKey("LocalUserID")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("DepartmentsDateLastFetched")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("CategoriesDateLastFetched")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        completionHandler(success: true)
    }
    
    // MARK: - Update
    func updateLocalUser(firstName:String, lastName:String, email:String, phoneNumber:String, completionHandler:(success:Bool)->Void) {
        
        // Create the request
        guard let userID = getLocalUser()?.userID else { return }
        let urlString = "\(serverURL)/update/user"
        let params = ["user_id":userID, "first_name":firstName, "last_name":lastName, "email":email, "phone_number":phoneNumber] as [String:String]
        guard let request = URLServiceProvider().getNewJsonPostRequest(withURL: urlString, params: params) else {
            completionHandler(success: false)
            return
        }
        
        // Execute the request
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            if error != nil {
                dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
                return
            }
            
            let statusCode = (response as? NSHTTPURLResponse)!.statusCode
            switch statusCode {
            case 200: // Catching status code 200, update was successful
                do {
                    
                    // Parse JSON data
                    let json                        = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    let dateFormatter               = NSDateFormatter()
                    dateFormatter.dateFormat        = "yyyy MM dd HH:mm:SS"
                    guard let dateLastModified      = dateFormatter.dateFromString(json["date_last_modified"] as! String) else { return }
                    guard let firstName             = json["first_name"] as? String else { return }
                    guard let lastName              = json["last_name"] as? String else { return }
                    guard let phoneNumber           = json["phone_number"] as? String else { return }
                    guard let isPhoneNumberVerified = json["is_phone_number_verified"] as? Bool else { return }
                    guard let email                 = json["email"] as? String else { return }
                    guard let isEmailVerified       = json["is_email_verified"] as? Bool else { return }
                    
                    
                    // Update the local user
                    dispatch_async(dispatch_get_main_queue(), {
                        let realm = try! Realm()
                        try! realm.write {
                            guard let localUser = self.getLocalUser() else { return }
                            localUser.firstName             = firstName
                            localUser.lastName              = lastName
                            localUser.phoneNumber           = phoneNumber
                            localUser.isPhoneNumberVerified = isPhoneNumberVerified
                            localUser.email                 = email
                            localUser.isEmailVerified       = isEmailVerified
                            localUser.dateLastModified      = dateLastModified
                        }
                        
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
}

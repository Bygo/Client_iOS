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
    func createNewUser(firstName:String, lastName:String, email:String, phoneNumber:String?, facebookID:String?, password:String?, signupMethod:String, completionHandler:(success:Bool, error: BygoError?)->Void) {
        
        // Create the request
        let urlString = "\(serverURL)/user/create"
        var params = ["first_name":firstName, "last_name":lastName, "email":email, "phone_number":"", "facebook_id":"", "password":"", "signup_method":signupMethod]
        if let notificationToken = (UIApplication.sharedApplication().delegate as? AppDelegate)?.registrationToken {
            params["notification_token"] = notificationToken
        }
        if let phoneNumber  = phoneNumber { params.updateValue(phoneNumber, forKey: "phone_number") }
        if let facebookID   = facebookID { params.updateValue(facebookID, forKey: "facebook_id") }
        if let password     = password { params.updateValue(password, forKey: "password") }
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
                    let json                    = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    guard let userID            = json["user_id"] as? String else { return }
                    
                    // Create new user
                    let user                    = User()
                    user.userID                 = userID
                    user.firstName              = firstName
                    user.lastName               = lastName
                    user.password               = password
                    user.facebookID             = facebookID
                    user.phoneNumber            = phoneNumber
                    user.email                  = email
                    
                    let realm = try! Realm()
                    try! realm.write {
                        realm.add(user)
                    }
                    
                    // Save the LocalUserID to user defaults for easy login when the user closes and reopens the app
                    NSUserDefaults.standardUserDefaults().setObject(userID, forKey: "LocalUserID")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    
                    completionHandler(success: true, error: nil)
                } catch {
                    completionHandler(success: false, error: .Unknown)
                }
                
            case 400:
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    guard let message = json["message"] as? String else { completionHandler(success: false, error: .Unknown); return }
                    
                    switch message {
                    case "Phone number already registered":
                        completionHandler(success: false, error: .PhoneNumberAlreadyRegistered)
                        
                    case "Email address already registered":
                        completionHandler(success: false, error: .EmailAddressAlreadyRegistered)
                        
                    default:
                        completionHandler(success: false, error: .Unknown)
                    }
                } catch {
                    completionHandler(success: false, error: .Unknown)
                }
                
            default:
                print("/create_new/user \(statusCode)")
                completionHandler(success: false, error: .Unknown)
            }
        })
        task.resume()
    }
    
    
    func setUserProfileImage(userID:String, image:UIImage, completionHandler:(success:Bool)->Void) {
        let filename = "profile_picture.jpg"
        
        let url = NSURL(string: "\(serverURL)/user/create_user_image/user_id=\(userID)")!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        let boundary = "---------------------------Boundary Line---------------------------"
        let contentTpe = "multipart/form-data; boundary=\(boundary)"
        request.addValue(contentTpe, forHTTPHeaderField: "Content-Type")
        
        let body = NSMutableData()
        body.appendData("\r\n--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("Content-Disposition: form-data; name=\"userfile\"; filename=\"\(filename)\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("Content-Type: application/octet-stream\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData(UIImageJPEGRepresentation(image, 0.4)!)
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
                        completionHandler(success: true)
                    }
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
        let urlString = "\(serverURL)/user/user_id=\(userID)"
        guard let request = URLServiceProvider().getNewGETRequest(withURL: urlString) else { return }
        
        
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
    func login(phoneNumber:String, password:String, completionHandler:(success:Bool, error: BygoError?)->Void) {
        
        // Create the request
        let urlString   = "\(serverURL)/user/login"
        var params      = ["login_id":phoneNumber, "password":password]
        if let notificationToken = (UIApplication.sharedApplication().delegate as? AppDelegate)?.registrationToken {
            params["notification_token"] = notificationToken
        }
        guard let request = URLServiceProvider().getNewJsonPostRequest(withURL: urlString, params: params) else {
            completionHandler(success: false, error: .Unknown)
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
                        print("\n\nFACEBOOK DATA")
                        print(data)
                        print("\n\n")
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
    func login(facebookID:String, completionHandler:(success:Bool, error: BygoError?)->Void) {
        
        // Create the request
        let urlString = "\(serverURL)/user/login_facebook"
        var params = ["facebook_id":facebookID]
        if let notificationToken = (UIApplication.sharedApplication().delegate as? AppDelegate)?.registrationToken {
            params["notification_token"] = notificationToken
        }
        guard let request = URLServiceProvider().getNewJsonPostRequest(withURL: urlString, params: params) else {
            completionHandler(success: false, error: .Unknown)
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
    private func loginServerResponseHandler(data:NSData?, response:NSURLResponse?, error:NSError?, completionHandler:(success:Bool, error:BygoError?)->Void) {
        if error != nil {
            print("Server returned an error \(error)")
            dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false, error: .Unknown) })
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
//                guard let isPhoneNumberVerified = json["is_phone_number_verified"] as? Bool else { return }
                guard let email                 = json["email"] as? String else { return }
//                guard let isEmailVerified       = json["is_phone_number_verified"] as? Bool else { return }
                guard let credit                = json["credit"] as? Double else { return }
                guard let debit                 = json["debit"] as? Double else { return }
                let mediaImageLink              = json["image_media_link"] as? String
                let homeAddressAddress = json["home_address_address"] as? String
                let homeAddressName = json["home_address_name"] as? String
                let homeAddressGooglePlacesID = json["home_address_google_places_id"] as? String
                
                // Create new user
                let user                    = User()
                user.userID                 = userID
                user.firstName              = firstName
                user.lastName               = lastName
                user.password               = password
                user.facebookID             = facebookID
                user.phoneNumber            = phoneNumber
//                user.isPhoneNumberVerified  = isPhoneNumberVerified
                user.email                  = email
//                user.isEmailVerified        = isEmailVerified
                user.credit                 = credit
                user.debit                  = debit
                user.profileImageLink       = mediaImageLink
                user.homeAddress_name = homeAddressName
                user.homeAddress_address = homeAddressAddress
                user.homeAddress_googlePlacesID = homeAddressGooglePlacesID
                
                let realm = try! Realm()
                try! realm.write { realm.add(user) }
                
                // Save the LocalUserID to user defaults for easy login when the user closes and reopens the app
                NSUserDefaults.standardUserDefaults().setObject(userID, forKey: "LocalUserID")
                NSUserDefaults.standardUserDefaults().synchronize()
                
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
                    
                default:
                    completionHandler(success: false, error: .Unknown)
                }
            } catch {
                completionHandler(success: false, error: .Unknown)
            }
            
        default:
            print("/login : \(statusCode)")
            completionHandler(success: false, error: .Unknown)
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
    func updateLocalUser(firstName:String, lastName:String, email:String, phoneNumber:String, completionHandler:(success:Bool, error: BygoError?)->Void) {
        
        // Create the request
        guard let userID = getLocalUser()?.userID else { return }
        let urlString = "\(serverURL)/user/update/user_id=\(userID)"
        let params = ["user_id":userID, "first_name":firstName, "last_name":lastName, "email":email, "phone_number":phoneNumber] as [String:String]
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
            case 200: // Catching status code 200, update was successful
                do {
                    
                    // Parse JSON data
                    let json                        = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    guard let firstName             = json["first_name"] as? String else { return }
                    guard let lastName              = json["last_name"] as? String else { return }
                    guard let phoneNumber           = json["phone_number"] as? String else { return }
                    guard let email                 = json["email"] as? String else { return }
                    
                    
                    // Update the local user
                    dispatch_async(dispatch_get_main_queue(), {
                        let realm = try! Realm()
                        try! realm.write {
                            guard let localUser = self.getLocalUser() else { return }
                            localUser.firstName             = firstName
                            localUser.lastName              = lastName
                            localUser.phoneNumber           = phoneNumber
                            localUser.email                 = email
                        }
                        
                        completionHandler(success: true, error: nil)
                    })
                } catch {
                    completionHandler(success: false, error: .Unknown)
                }
            case 400:
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    guard let message = json["message"] as? String else { completionHandler(success: false, error: .Unknown); return }
                    
                    print(message)
                    
                    switch message {
                    case "Phone number already registered":
                        completionHandler(success: false, error: .PhoneNumberAlreadyRegistered)
                        
                    case "Email address already registered":
                        completionHandler(success: false, error: .EmailAddressAlreadyRegistered)
                        
                    default:
                        completionHandler(success: false, error: .Unknown)
                    }
                } catch {
                    completionHandler(success: false, error: .Unknown)
                }
                
            default:
                completionHandler(success: false, error: .Unknown)
            }
        })
        task.resume()
    }
    
    func updateHomeAddress(googlePlacesID:String, address:String, name:String, geoPoint:String, completionHandler:(success:Bool, error: BygoError?)->Void) {
        
        // Create the request
        guard let userID = getLocalUser()?.userID else { return }
        let urlString = "\(serverURL)/user/update_home_address/user_id=\(userID)"
        let params:[String:AnyObject] = ["google_places_id":googlePlacesID, "address":address, "name":name, "geo_point":geoPoint]
        
        guard let request = URLServiceProvider().getNewJsonPostRequest(withURL: urlString, params: params) else {
            completionHandler(success: false, error: nil)
            return
        }
        
        
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
            case 201:   // Catching status code 201, success, new location created
                do {
                    
                    // Parse JSON response data
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    guard let address = json["home_address_address"] as? String else { return }
                    guard let name = json["home_address_name"] as? String else { return }
                    guard let googlePlacesID = json["home_address_google_places_id"] as? String else { return }
                    let realm = try! Realm()
                    try! realm.write {
                        guard let localUser = self.getLocalUser() else { return }
                        localUser.homeAddress_name = name
                        localUser.homeAddress_address = address
                        localUser.homeAddress_googlePlacesID = googlePlacesID
                    }
                    completionHandler(success: true, error: nil)
                } catch {
                    completionHandler(success: false, error: .Unknown)
                }
            default:
                completionHandler(success: false, error: .Unknown)
            }
        })
        task.resume()
    }
}

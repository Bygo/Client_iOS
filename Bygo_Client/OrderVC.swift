//
//  OrderVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 16/3/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import RealmSwift
import GoogleMaps
import MapKit

class OrderVC: UIViewController, UITextFieldDelegate, SuccessDelegate, LoginDelegate, ErrorMessageDelegate {
    
    var typeID: String?
    var model: Model?
    
    let locationManager = CLLocationManager()
    
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var sendButton: UIBarButtonItem!
    @IBOutlet var promptLabel: UILabel!
    @IBOutlet var rentalDurationTextField: UITextField!
    @IBOutlet var rentalValueTextField: UITextField!
    @IBOutlet var rentalDurationLabel: UILabel!
    @IBOutlet var rentalValueLabel: UILabel!
    @IBOutlet var loginContainer:UINavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor    = kCOLOR_ONE
        navigationController?.navigationBar.translucent     = false
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        cancelButton.tintColor = .whiteColor()
        sendButton.tintColor = .whiteColor()
        
        view.backgroundColor = kCOLOR_THREE
        
        // Do any additional setup after loading the view.
        rentalValueTextField.userInteractionEnabled = false
        
        rentalDurationTextField.addTarget(self, action: #selector(OrderVC.rentalDurationTextFieldDidChange(_:)), forControlEvents: .EditingChanged)
        rentalDurationTextField.tintColor = kCOLOR_ONE
        rentalDurationTextField.text = ""
        sendButton.enabled = isDataValid()
        rentalDurationTextField.becomeFirstResponder()
        
        
        print(typeID)
        guard let typeID = typeID else { promptLabel.text = nil; return }
        let realm = try! Realm()
        guard let itemName = realm.objects(ItemType).filter("typeID == \"\(typeID)\"")[0].name else { promptLabel.text = nil; return }
        promptLabel.text = "How long do you want the \(itemName) for?"
            
    }
    
    override func viewWillDisappear(animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func isDataValid() -> Bool {
        guard let text = rentalDurationTextField.text else { return false }
        let data = NSString(string: text).integerValue
        return data > 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == rentalDurationTextField {
            if let text = textField.text {
                let newString = (text as NSString).stringByReplacingCharactersInRange(range, withString: string)
                let duration = NSString(string: newString).integerValue
                return duration < 366
            }
        }
        return true
    }
    
    @IBAction func rentalDurationTextFieldDidChange(sender: AnyObject) {
        guard let text = rentalDurationTextField.text else {
            rentalValueTextField.text = "$5"
            sendButton.enabled = isDataValid()
            return
        }
        
        let duration = NSString(string: text).integerValue
        if duration < 1 {
            rentalValueTextField.text = "$5"
            sendButton.enabled = isDataValid()
            return
        }
        
        let deliveryRate = 5.0
        let rentalRate = 4.0
        let rentalValue = deliveryRate + (Double(duration)*rentalRate)
        rentalValueTextField.text = "$\(Int(rentalValue))"
        
        sendButton.enabled = isDataValid()
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        rentalDurationTextField.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func sendButtonTapped(sender: AnyObject) {
        rentalDurationTextField.resignFirstResponder()
        createOrder()
    }
    
    @IBAction func panGestureRecognized(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(view)
        if abs(translation.y) > abs(translation.x) && translation.y > 0.0 {
            rentalDurationTextField.resignFirstResponder()
        }
    }
    
    func doneButtonTapped() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: - CreateOrder
    private func createOrder() {
        print("Create order")
        guard let userID = model?.userServiceProvider.getLocalUser()?.userID else {
            handleError(.UserNotFound)
            return
        }
        guard let typeID = typeID else { return }
        guard let duration = Int(rentalDurationTextField.text!) else { return }
        guard let rentalFee = Double(String(rentalValueTextField.text!.characters.dropFirst())) else { return }
        
        
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse {
            if let currentLocation:CLLocation = locationManager.location {
                let lat = currentLocation.coordinate.latitude
                let lon = currentLocation.coordinate.longitude
                let geoPt = "\(lat), \(lon)"
                
                self.navigationController?.navigationBar.userInteractionEnabled = false
                let l = LoadingScreen(frame: view.bounds, message: "Creating Listing")
                view.addSubview(l)
                l.beginAnimation()
                
                model?.orderServiceProvider.createOrder(userID, typeID: typeID, geoPoint: geoPt, duration: duration, rentalFee: rentalFee, completionHandler: {
                    (success:Bool, error:BygoError?) in
                    dispatch_async(GlobalMainQueue, {
                        self.navigationController?.navigationBar.userInteractionEnabled = true
                        if success {
                            self.performSegueWithIdentifier("SentSegue", sender: nil)
                        } else {
                            l.endAnimation()
                            self.handleError(error)
                        }
                    })
                })
            }
        } else {
            handleError(.LocationServicesRequired)
            return
        }
    }
    
    // MARK: - ErrorMessageDelegate
    private func handleError(error: BygoError?) {
        let window = UIApplication.sharedApplication().keyWindow!
        var e: ErrorMessage?
        
        guard let error = error else {
            e = ErrorMessage(frame: window.bounds, title: "Uh oh!", detail: "Something went wrong.", error: .Unknown, priority: .High, options: [ErrorMessageOptions.Cancel, ErrorMessageOptions.Retry])
            if let e = e {
                e.delegate = self
                window.addSubview(e)
                e.show()
            }
            return
        }
        
        switch error {
        case .UserNotFound:
            e = ErrorMessage(frame: window.bounds, title: "Login Required", detail: "Tap \"Okay\" to login", error: .UserNotFound, priority: .Low, options: [ErrorMessageOptions.Cancel, ErrorMessageOptions.Okay])
            
        case .PhoneNumberNotFound:
            e = ErrorMessage(frame: window.bounds, title: "Mobile Number Required", detail: "Tap \"Okay\" to verify the mobile number associated with this account", error: error, priority: .Low, options: [ErrorMessageOptions.Cancel, ErrorMessageOptions.Okay])
            
        case .PhoneNumberNotVerified:
            e = ErrorMessage(frame: window.bounds, title: "Verify Mobile Number", detail: "Tap \"Okay\" to verify the mobile number associated with this account", error: error, priority: .Low, options: [ErrorMessageOptions.Cancel, ErrorMessageOptions.Okay])
        
        case .LocationServicesRequired:
            e = ErrorMessage(frame: window.bounds, title: "Location Services Required", detail: "Please enable location services for Bygo in your phone's Settings", error: error, priority: .High, options: [ErrorMessageOptions.Okay])
            
        default:
            e = ErrorMessage(frame: window.bounds, title: "Uh oh!", detail: "Something went wrong", error: .Unknown, priority: .High, options: [ErrorMessageOptions.Cancel, ErrorMessageOptions.Retry])
        }
        
        if let e = e {
            e.delegate = self
            window.addSubview(e)
            e.show()
        }
    }

    func okayButtonTapped(error: BygoError) {
        switch error {
        case .PhoneNumberNotVerified:
            self.performSegueWithIdentifier("VerifyMobile", sender: nil)
            
        case .PhoneNumberNotFound:
            self.performSegueWithIdentifier("PhoneNumber", sender: nil)
            
        case .UserNotFound:
            showLoginMenu()
            
        default:
            return
        }
    }
    
    func retryButtonTapped(error: BygoError) {
        print("\n\nRETRY!!")
        createOrder()
    }
    
    
    // MARK: - Login
    func showLoginMenu() {
        let loginSB = UIStoryboard(name: "Login", bundle: NSBundle.mainBundle())
        loginContainer = loginSB.instantiateInitialViewController() as? UINavigationController
        (loginContainer?.topViewController as? WelcomeVC)?.model = model
        (loginContainer?.topViewController as? WelcomeVC)?.delegate = self
        presentViewController(loginContainer!, animated: true, completion: nil)
    }
    
    
    // MARK: - HomeAddress Delegate
    func didUpdateHomeAddress() {
        createOrder()
    }
    
    // MARK: - LoginDelegate
    func userDidLogin(shouldDismissLogin: Bool) {
        NSNotificationCenter.defaultCenter().postNotificationName("UserDidLogin", object: false)
        dispatch_async(GlobalMainQueue, {
            if shouldDismissLogin {
                self.loginContainer?.dismissViewControllerAnimated(true, completion: {
                    self.loginContainer = nil
                    self.createOrder()
                })
            }
        })
    }
    
    func phoneNumberDidVerify(shouldDismissLogin: Bool) {
        dispatch_async(GlobalMainQueue, {
            if shouldDismissLogin {
                self.dismissViewControllerAnimated(true, completion: {
                    self.createOrder()
                })
            }
        })
    }


    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SentSegue" {
            guard let destVC = segue.destinationViewController as? SuccessVC else { return }
            
            destVC.delegate = self
            destVC.titleString = "Order Sent!"
            
            guard let typeID = typeID else { destVC.detailString = nil; return }
            let realm = try! Realm()
            guard let itemName = realm.objects(ItemType).filter("typeID == \"\(typeID)\"")[0].name else { destVC.detailString = nil; return }
            destVC.detailString = "We'll notify you when we find a \(itemName) to fill your order."
            
        } else if segue.identifier == "PhoneNumber" {
            guard let navVC = segue.destinationViewController as? UINavigationController else { return }
            guard let destVC = navVC.topViewController as? PhoneNumberVC else { return }
            destVC.model = model
            destVC.isModalPresentation = true
            destVC.delegate = self
            
        } else if segue.identifier == "VerifyMobile" {
            guard let navVC = segue.destinationViewController as? UINavigationController else { return }
            guard let destVC = navVC.topViewController as? VerifyPhoneNumberVC else { return }
            destVC.model = model
            destVC.isModalPresentation = true
            destVC.delegate = self
            
        }
    }
}

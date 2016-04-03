           //
//  CreateAccountVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 26/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class CreateAccountVC: UIViewController, UITextFieldDelegate {

    var model:Model?
    var delegate:LoginDelegate?
    
    
    @IBOutlet var firstNameView: UIView!
    @IBOutlet var lastNameView: UIView!
    @IBOutlet var mobileView: UIView!
    @IBOutlet var emailView: UIView!
    @IBOutlet var passwordView: UIView!
    
    @IBOutlet var phoneDisclaimerLabel: UILabel!
    
    @IBOutlet var firstNameLabel: UILabel!
    @IBOutlet var lastNameLabel: UILabel!
    @IBOutlet var mobileLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var passwordLabel: UILabel!
    @IBOutlet var orLabel: UILabel!
    
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var mobileTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    @IBOutlet var facebookButton: UIButton!
    
    @IBOutlet var backButton: UIBarButtonItem!
    @IBOutlet var doneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstNameTextField.tintColor    = kCOLOR_ONE
        lastNameTextField.tintColor     = kCOLOR_ONE
        mobileTextField.tintColor       = kCOLOR_ONE
        emailTextField.tintColor        = kCOLOR_ONE
        passwordTextField.tintColor     = kCOLOR_ONE

        view.backgroundColor = kCOLOR_THREE
        
        phoneDisclaimerLabel.textColor = .blackColor()
        phoneDisclaimerLabel.alpha = 0.75
        
        orLabel.textColor = .blackColor()
        orLabel.font = UIFont.systemFontOfSize(12.0, weight: UIFontWeightMedium)
        orLabel.alpha = 0.75
        
        firstNameView.backgroundColor   = .whiteColor()
        lastNameView.backgroundColor    = .whiteColor()
        mobileView.backgroundColor      = .whiteColor()
        emailView.backgroundColor       = .whiteColor()
        passwordView.backgroundColor    = .whiteColor()
        
        firstNameTextField.addTarget(self, action: #selector(CreateAccountVC.textFieldDidChange(_:)), forControlEvents: .EditingChanged)
        lastNameTextField.addTarget(self, action: #selector(CreateAccountVC.textFieldDidChange(_:)), forControlEvents: .EditingChanged)
        mobileTextField.addTarget(self, action: #selector(CreateAccountVC.textFieldDidChange(_:)), forControlEvents: .EditingChanged)
        emailTextField.addTarget(self, action: #selector(CreateAccountVC.textFieldDidChange(_:)), forControlEvents: .EditingChanged)
        passwordTextField.addTarget(self, action: #selector(CreateAccountVC.textFieldDidChange(_:)), forControlEvents: .EditingChanged)
        
        doneButton.enabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func isUserDataValid() -> Bool {
        guard let model = model else { return false }
        
        guard let firstName = firstNameTextField.text else {
            return false
        }
        guard let lastName = lastNameTextField.text else {
            return false
        }
        guard let mobile = mobileTextField.text else {
            return false
        }
        guard let email = emailTextField.text else {
            return false
        }
        guard let password = passwordTextField.text else {
            return false
        }
        
        if !model.dataValidator.isValidFirstName(firstName) {
            return false
        }
        if !model.dataValidator.isValidLastName(lastName) {
            return false
        }
        if !model.dataValidator.isValidPhoneNumber(mobile)  { return false
        }
        if !model.dataValidator.isValidEmail(email) {
            return false
        }
        if !model.dataValidator.isValidPassword(password)   { return false
        }
        
        
        return true
    }
    
    
    // MARK: - TextFieldDelegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if textField == mobileTextField {
            if let text = textField.text {
                let newString = (text as NSString).stringByReplacingCharactersInRange(range, withString: string)
                let components = newString.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
                
                let decimalString = components.joinWithSeparator("") as NSString
                let length = decimalString.length
                if length == 0 || length > 11 {
                    let newLength = (text as NSString).length + (string as NSString).length - range.length as Int
                    return (newLength > 11) ? false : true
                }
                var index = 0 as Int
                let formattedString = NSMutableString()
                
                formattedString.appendString("+1 ")
                index += 1
                
                if (length-index) > 3 {
                    let areaCode = decimalString.substringWithRange(NSMakeRange(index, 3))
                    formattedString.appendFormat("%@ ", areaCode)
                    index += 3
                }
                if length - index > 3 {
                    let prefix = decimalString.substringWithRange(NSMakeRange(index, 3))
                    formattedString.appendFormat("%@ ", prefix)
                    index += 3
                }
                
                let remainder = decimalString.substringFromIndex(index)
                formattedString.appendString(remainder)
                textField.text = formattedString as String
                doneButton.enabled = isUserDataValid()
                return false
            }
        }
        
        return true
    }
    
    
    func textFieldDidChange(textfield: UITextField) {
        doneButton.enabled = isUserDataValid()
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        doneButton.enabled = false
        
        if textField == mobileTextField {
            textField.text = "+1 "
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case firstNameTextField:
            lastNameTextField.becomeFirstResponder()
        case lastNameTextField:
            mobileTextField.becomeFirstResponder()
        case mobileTextField:
            emailTextField.becomeFirstResponder()
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            passwordTextField.resignFirstResponder()
        default:
            break
        }
        return true
    }

    // MARK: - UI Actions
    @IBAction func backButtonTapped(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func nextButtonTapped(sender: AnyObject) {
        if isUserDataValid() {
            model?.userServiceProvider.createNewUser(firstNameTextField.text!, lastName: lastNameTextField.text!, email: emailTextField.text!, phoneNumber: mobileTextField.text!, facebookID: nil, password: passwordTextField.text!, signupMethod: "Phone Number", completionHandler: { (success:Bool)->Void in
                if success {
                    self.delegate?.userDidLogin(false)
                    self.performSegueWithIdentifier("VerifyMobileSegue", sender: nil)
                } else {
                    print("Error creating new user")
                }
            })
        }
    }
    
    @IBAction func facebookButtonTapped(sender: AnyObject) {
        model?.userServiceProvider.attemptFacebookLogin({
            (data:[String:AnyObject]?) in
            if let data = data {
                guard let firstName     = data["first_name"]    as? String else { return }
                guard let lastName      = data["last_name"]     as? String else { return }
                guard let email         = data["email"]         as? String else { return }
                guard let facebookID    = data["id"]            as? String else { return }
                let picture = data["picture"] as? [String:AnyObject]
                let signUpMethod        = "Facebook"
                
                self.model?.userServiceProvider.login(facebookID, completionHandler: { (loginSuccess:Bool)->Void in
                    if loginSuccess {
                        dispatch_async(GlobalMainQueue, {
                            self.delegate?.userDidLogin(true)
                        })
                    } else {
                        self.model?.userServiceProvider.createNewUser(firstName, lastName: lastName, email: email, phoneNumber: nil, facebookID: facebookID, password: nil, signupMethod: signUpMethod, completionHandler: { (success:Bool)->Void in
                            if success {
                                
                                self.setUserFacebookProfileImage(picture, completionHandler: {
                                    dispatch_async(GlobalMainQueue, {
                                        self.delegate?.userDidLogin(false)
                                        self.performSegueWithIdentifier("MobileSegue", sender: nil)
                                    })
                                })
                                
                            } else {
                                print("Error creating new user")
                            }
                        })
                    }
                })
            } else {
                print("Error while logging in (signing up) with facebook")
            }
        })
    }
    
    // Upload the user's profile image from facebook
    private func setUserFacebookProfileImage(picture: [String:AnyObject]?, completionHandler:()->Void) {
        if let userID = self.model?.userServiceProvider.getLocalUser()?.userID {
            if let picture = picture {
                if let data = picture["data"] as? [String:AnyObject] {
                    if let urlString = data["url"] as? String {
                        if let url = NSURL(string: urlString) {
                            URLServiceProvider().downloadImage(url, completionHandler: {
                                (image:UIImage?) in
                                if let image = image {
                                    self.model?.userServiceProvider.setUserProfileImage(userID, image: image, completionHandler: {
                                        (success:Bool) in
                                        completionHandler()
                                    })
                                } else { completionHandler() }
                            })
                        } else { completionHandler() }
                    } else { completionHandler() }
                } else { completionHandler() }
            } else { completionHandler() }
        } else { completionHandler() }
    }
    
    
    @IBAction func panGestureRecognized(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(view)
        if abs(translation.y) > abs(translation.x) && translation.y > 0.0 {
            firstNameTextField.resignFirstResponder()
            lastNameTextField.resignFirstResponder()
            mobileTextField.resignFirstResponder()
            emailTextField.resignFirstResponder()
            passwordTextField.resignFirstResponder()
        }
    }

    
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "MobileSegue" {
            guard let destVC = segue.destinationViewController as? PhoneNumberVC else { return }
            destVC.delegate = delegate
            destVC.model = model
            
        } else if segue.identifier == "VerifyMobileSegue" {
            guard let destVC = segue.destinationViewController as? VerifyPhoneNumberVC else { return }
            destVC.delegate = delegate
            destVC.model = model
        }
    }
}

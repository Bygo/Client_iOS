//
//  SignUpVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 2/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class SignUpVC: UIViewController, UITextFieldDelegate {

    var model:Model?
    
    //    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var welcomeLabel: UILabel!
    @IBOutlet var facebookButton: UIButton!
    
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var cancelButton: UIBarButtonItem!
    
    @IBOutlet var firstNameLabel: UILabel!
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameLabel: UILabel!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var phoneNumberLabel: UILabel!
    @IBOutlet var phoneNumberTextField: UITextField!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordLabel: UILabel!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var signUpButton: UIButton!
    
    var delegate:LoginDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // UI Design
        navigationController?.navigationBar.barTintColor    = kCOLOR_ONE
        navigationController?.navigationBar.translucent     = false
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        signUpButton.backgroundColor = kCOLOR_ONE
        loginButton.titleLabel?.textColor = kCOLOR_ONE
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func isUserDataValid() -> Bool {
        if firstNameTextField.text?.characters.count < 1 {
            // TODO: Send error that first name is missing
            return false
        } else if lastNameTextField.text?.characters.count < 1 {
            // TODO: Send error that last name is missing
            return false
        } else if passwordTextField.text?.characters.count < 5 {
            // TODO: Send error that no password was made
            return false
        } else if !isValidEmail(emailTextField.text!) {
            // TODO: Send error that email was invalid
            return false
        } else if !isValidPhoneNumber(phoneNumberTextField.text!) {
            // TODO: Send error that phonenumber is invalid
            return false
        }
        return true
    }
    
    // MARK: - TextFieldDelegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == phoneNumberTextField
        {
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
                return false
            }
        }
        return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        if textField == phoneNumberTextField {
            textField.text = "+1 "
            return false
        }
        return true
    }
    
    // MARK: - Help
    func isValidEmail(str:String) -> Bool {
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(str)
    }
    
    func isValidPhoneNumber(str:String) -> Bool {
        var digits = str.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
        digits = digits.filter({$0 != ""})
        if digits.count != 4 { return false }
        let countryCode = digits[0]
        let areaCode = digits[1]
        let prefix = digits[2]
        let suffix = digits[3]
        if countryCode != "1" { return false }
        if areaCode.characters.count != 3 { return false }
        if prefix.characters.count != 3 { return false }
        if suffix.characters.count != 4 { return false }
        return true
    }
    
    // MARK: - UI Actions
    @IBAction func panGestureRecognized(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(view)
        if abs(translation.y) > abs(translation.x) && translation.y > 0.0 {
            firstNameTextField.resignFirstResponder()
            lastNameTextField.resignFirstResponder()
            phoneNumberTextField.resignFirstResponder()
            emailTextField.resignFirstResponder()
            passwordTextField.resignFirstResponder()
        }
    }
    
    @IBAction func signUpButtonTapped(sender: AnyObject) {
        if isUserDataValid() {
            model?.userServiceProvider.createNewUser(firstNameTextField.text!, lastName: lastNameTextField.text!, email: emailTextField.text!, phoneNumber: phoneNumberTextField.text!, facebookID: nil, password: passwordTextField.text!, signupMethod: "Phone Number", completionHandler: { (success:Bool)->Void in
                if success {
                    self.delegate?.userDidLogin(false)
                    self.performSegueWithIdentifier("ShowPhoneNumberVerification", sender: nil)
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
                guard let firstName     = data["first_name"] as? String else { return }
                guard let lastName      = data["last_name"] as? String else { return }
                guard let email         = data["email"] as? String else { return }
                guard let facebookID    = data["id"] as? String else { return }
                let signUpMethod        = "Facebook"
                
                self.model?.userServiceProvider.login(facebookID, completionHandler: { (loginSuccess:Bool)->Void in
                    if loginSuccess {
                        dispatch_async(GlobalMainQueue, {
                            self.delegate?.userDidLogin(true)
                        })
                    } else {
                        self.model?.userServiceProvider.createNewUser(firstName, lastName: lastName, email: email, phoneNumber: nil, facebookID: facebookID, password: nil, signupMethod: signUpMethod, completionHandler: { (success:Bool)->Void in
                            if success {
                                dispatch_async(GlobalMainQueue, {
                                    self.delegate?.userDidLogin(false)
                                    self.performSegueWithIdentifier("ShowRequestPhoneNumber", sender: nil)
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
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowLogin" {
            guard let destVC = segue.destinationViewController as? LoginVC else { return }
            destVC.delegate = delegate
            destVC.model = model
        } else if segue.identifier == "ShowPhoneNumberVerification" {
            guard let destVC = segue.destinationViewController as? VerifyPhoneNumberVC else { return }
            destVC.delegate = delegate
            destVC.model = model
        } else if segue.identifier == "ShowRequestPhoneNumber" {
            guard let destVC = segue.destinationViewController as? PhoneNumberVC else { return }
            destVC.delegate = delegate
            destVC.model = model
        }
    }
}


public protocol LoginDelegate {
    func userDidLogin(shouldDismissLogin:Bool)
    func phoneNumberDidVerify(shouldDidmissLogin:Bool)
}

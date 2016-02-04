//
//  LoginVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 2/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class LoginVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var phoneNumberLabel: UILabel!
    @IBOutlet var phoneNumberTextField: UITextField!
    @IBOutlet var passwordLabel: UILabel!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var facebookButton: UIButton!
    
    var delegate:LoginDelegate?
    var model:Model?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    // MARK: - TextField Delegate
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
        textField.text = "+1 "
        return false
    }
    
    // MARK: - UI Actions
    @IBAction func panGestureRecognized(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(view)
        if abs(translation.y) > abs(translation.x) && translation.y > 0.0 {
            phoneNumberTextField.resignFirstResponder()
            passwordTextField.resignFirstResponder()
        }
    }
    
    
    @IBAction func loginButtonTapped(sender: AnyObject) {
        if isValidPhoneNumber(phoneNumberTextField.text!) {
            if passwordTextField.text?.characters.count > 4 {
                model?.userServiceProvider.login(phoneNumberTextField.text!, password: passwordTextField.text!, completionHandler: { (success:Bool)->Void in
                    if success {
                        self.delegate?.userDidLogin(true)
                    } else {
                        print("Something went wrong")
                    }
                })
            } else {
                print("Password was not valid")
            }
        } else {
            print("Phone number was not valid")
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
                
                self.model?.userServiceProvider.login(facebookID, completionHandler: {
                    (loginSuccess:Bool)->Void in
                    if loginSuccess {
                        self.delegate?.userDidLogin(true)
                    } else {
                        self.model?.userServiceProvider.createNewUser(firstName, lastName: lastName, email: email, phoneNumber: nil, facebookID: facebookID, password: nil, signupMethod: signUpMethod, completionHandler: { (success:Bool)->Void in
                            if success {
                                self.delegate?.userDidLogin(false)
                                self.performSegueWithIdentifier("ShowRequestPhoneNumber", sender: nil)
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
}

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
    
    @IBOutlet var firstNameCheckIndicator: UIImageView!
    @IBOutlet var lastNameCheckIndicator: UIImageView!
    @IBOutlet var mobileCheckIndicator: UIImageView!
    @IBOutlet var emailCheckIndicator: UIImageView!
    @IBOutlet var passwordCheckIndicator: UIImageView!
    
    @IBOutlet var facebookButton: UIButton!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var nextButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton.setImage(UIImage(named: "Back")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: .Normal)
        backButton.tintColor = .whiteColor()
        
        firstNameTextField.tintColor    = kCOLOR_ONE
        lastNameTextField.tintColor     = kCOLOR_ONE
        mobileTextField.tintColor       = kCOLOR_ONE
        emailTextField.tintColor        = kCOLOR_ONE
        passwordTextField.tintColor     = kCOLOR_ONE
        
        firstNameCheckIndicator.layer.cornerRadius  = firstNameCheckIndicator.bounds.width/2.0
        lastNameCheckIndicator.layer.cornerRadius   = lastNameCheckIndicator.bounds.width/2.0
        mobileCheckIndicator.layer.cornerRadius     = mobileCheckIndicator.bounds.width/2.0
        emailCheckIndicator.layer.cornerRadius      = emailCheckIndicator.bounds.width/2.0
        passwordCheckIndicator.layer.cornerRadius   = passwordCheckIndicator.bounds.width/2.0
        
        firstNameCheckIndicator.alpha   = 0.0
        lastNameCheckIndicator.alpha    = 0.0
        mobileCheckIndicator.alpha      = 0.0
        emailCheckIndicator.alpha       = 0.0
        passwordCheckIndicator.alpha    = 0.0

        firstNameView.backgroundColor   = kCOLOR_THREE
        lastNameView.backgroundColor    = kCOLOR_THREE
        mobileView.backgroundColor      = kCOLOR_THREE
        emailView.backgroundColor       = kCOLOR_THREE
        passwordView.backgroundColor    = kCOLOR_THREE
        
        firstNameTextField.addTarget(self, action: #selector(CreateAccountVC.textFieldDidChange(_:)), forControlEvents: .EditingChanged)
        lastNameTextField.addTarget(self, action: #selector(CreateAccountVC.textFieldDidChange(_:)), forControlEvents: .EditingChanged)
        mobileTextField.addTarget(self, action: #selector(CreateAccountVC.textFieldDidChange(_:)), forControlEvents: .EditingChanged)
        emailTextField.addTarget(self, action: #selector(CreateAccountVC.textFieldDidChange(_:)), forControlEvents: .EditingChanged)
        passwordTextField.addTarget(self, action: #selector(CreateAccountVC.textFieldDidChange(_:)), forControlEvents: .EditingChanged)
        
        nextButton.alpha = 0.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func isUserDataValid() -> Bool {
        guard let model = model else { return false }
        
        var isValid = true
        
        if let firstName = firstNameTextField.text {
            if model.dataValidator.isValidFirstName(firstName) {
                firstNameCheckIndicator.alpha = 1.0
            } else {
                firstNameCheckIndicator.alpha = 0.0
                isValid = false
            }
        } else { isValid = false }
        
        if let lastName = lastNameTextField.text {
            if model.dataValidator.isValidLastName(lastName) {
                lastNameCheckIndicator.alpha = 1.0
            } else {
                lastNameCheckIndicator.alpha = 0.0
                isValid = false
            }
        } else { isValid = false }
        
        if let mobile = mobileTextField.text {
            if model.dataValidator.isValidPhoneNumber(mobile) {
                mobileCheckIndicator.alpha = 1.0
            } else {
                mobileCheckIndicator.alpha = 0.0
                isValid = false
            }
        } else { isValid = false }
        
        if let email = emailTextField.text {
            if model.dataValidator.isValidEmail(email) {
                emailCheckIndicator.alpha = 1.0
            } else {
                emailCheckIndicator.alpha = 0.0
                isValid = false
            }
        } else { isValid = false }
        
        if let password = passwordTextField.text {
            if model.dataValidator.isValidPassword(password) {
                passwordCheckIndicator.alpha = 1.0
            } else {
                passwordCheckIndicator.alpha = 0.0
                isValid = false
            }
        } else { isValid = false }
        
        return isValid
    }
    
    func enableNextButtonIfNeeded() {
        if isUserDataValid() {
            UIView.animateWithDuration(0.5, animations: {
                self.nextButton.alpha = 1.0
            })
        } else {
            UIView.animateWithDuration(0.5, animations: {
                self.nextButton.alpha = 0.0
            })
        }
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
                enableNextButtonIfNeeded()
                return false
            }
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        var targetView:UIView?
        switch textField {
        case firstNameTextField:
            targetView = firstNameView
        case lastNameTextField:
            targetView = lastNameView
        case mobileTextField:
            targetView = mobileView
        case emailTextField:
            targetView = emailView
        case passwordTextField:
            targetView = passwordView
        default:
            break
        }
        
        firstNameView.backgroundColor   = kCOLOR_THREE
        lastNameView.backgroundColor    = kCOLOR_THREE
        mobileView.backgroundColor      = kCOLOR_THREE
        emailView.backgroundColor       = kCOLOR_THREE
        passwordView.backgroundColor    = kCOLOR_THREE
        targetView?.backgroundColor     = .whiteColor()
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        firstNameView.backgroundColor   = kCOLOR_THREE
        lastNameView.backgroundColor    = kCOLOR_THREE
        mobileView.backgroundColor      = kCOLOR_THREE
        emailView.backgroundColor       = kCOLOR_THREE
        passwordView.backgroundColor    = kCOLOR_THREE
    }
    
    func textFieldDidChange(textfield: UITextField) {
        enableNextButtonIfNeeded()
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        nextButton.alpha = 0.0
        isUserDataValid()
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
                                
//                                dispatch_async(GlobalMainQueue, {
//                                    self.delegate?.userDidLogin(false)
//                                    self.performSegueWithIdentifier("MobileSegue", sender: nil)
//                                })
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
        print("A")
        if let userID = self.model?.userServiceProvider.getLocalUser()?.userID {
            print("B")
            if let picture = picture {
                print("C")
                if let data = picture["data"] as? [String:AnyObject] {
                    print("Z")
                    if let urlString = data["url"] as? String {
                        print("D")
                        if let url = NSURL(string: urlString) {
                            print("E")
                            URLServiceProvider().downloadImage(url, completionHandler: {
                                (image:UIImage?) in
                                print("F")
                                if let image = image {
                                    print("G")
                                    self.model?.userServiceProvider.setUserProfileImage(userID, image: image, completionHandler: {
                                        (success:Bool) in
                                        print("H")
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

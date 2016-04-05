//
//  LoginVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 2/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class LoginVC: UIViewController, UITextFieldDelegate, ErrorMessageDelegate {
    
    @IBOutlet var mobileView: UIView!
    @IBOutlet var passwordView: UIView!
    
    @IBOutlet var mobileLabel: UILabel!
    @IBOutlet var passwordLabel: UILabel!
    @IBOutlet var orLabel:UILabel!
    
    @IBOutlet var mobileTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    @IBOutlet var facebookButton: UIButton!

    @IBOutlet var backButton: UIBarButtonItem!
    @IBOutlet var doneButton: UIBarButtonItem!
    @IBOutlet var tapRecognizer: UITapGestureRecognizer!
    
    
    var delegate:LoginDelegate?
    var model:Model?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginVC.tapGestureRecognized(_:)))
        
        navigationController?.navigationBar.barTintColor    = kCOLOR_ONE
        navigationController?.navigationBar.translucent     = false
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        view.backgroundColor = kCOLOR_THREE
        
        mobileTextField.tintColor   = kCOLOR_ONE
        passwordTextField.tintColor = kCOLOR_ONE
        
        mobileView.backgroundColor      = .whiteColor()
        passwordView.backgroundColor    = .whiteColor()
        
        orLabel.textColor = .blackColor()
        orLabel.font = UIFont.systemFontOfSize(12.0, weight: UIFontWeightMedium)
        orLabel.alpha = 0.75
        
        mobileTextField.addTarget(self, action: #selector(LoginVC.textFieldDidChange(_:)), forControlEvents: .EditingChanged)
        passwordTextField.addTarget(self, action: #selector(LoginVC.textFieldDidChange(_:)), forControlEvents: .EditingChanged)
        
        doneButton.enabled = false
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func isUserDataValid() -> Bool {
        guard let model = model else { return false }
        
        guard let mobile    = mobileTextField.text      else { return false }
        guard let password  = passwordTextField.text    else { return false }
        
        if !model.dataValidator.isValidPhoneNumber(mobile)  { return false }
        if !model.dataValidator.isValidPassword(password)   { return false }
        
        return true
    }
    
    func enableDoneButtonIfNeeded() {
        doneButton.enabled = isUserDataValid()
    }
    
    // MARK: - TextField Delegate
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
                enableDoneButtonIfNeeded()
                return false
            }
        }
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        view.addGestureRecognizer(tapRecognizer)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        view.removeGestureRecognizer(tapRecognizer)
    }
    
    func textFieldDidChange(textfield: UITextField) {
        enableDoneButtonIfNeeded()
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
        case mobileTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            passwordTextField.resignFirstResponder()
        default:
            break
        }
        return true
    }
    
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
            e = ErrorMessage(frame: window.bounds, title: "Uh oh!", detail: "No account was found matching this phone number and password.", error: .Unknown, priority: .High, options: [ErrorMessageOptions.Cancel, ErrorMessageOptions.Okay])
        default:
            e = ErrorMessage(frame: window.bounds, title: "Uh oh!", detail: "Something went wrong.", error: .Unknown, priority: .High, options: [ErrorMessageOptions.Cancel, ErrorMessageOptions.Retry])
        }
        
        if let e = e {
            e.delegate = self
            window.addSubview(e)
            e.show()
        }
    }
    
    // MARK: - UI Actions
    @IBAction func backButtonTapped(sender: AnyObject) {
        mobileTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        navigationController?.popViewControllerAnimated(true)
    }
    
    
    @IBAction func doneButtonTapped(sender: AnyObject) {
        guard let model = model else { return }
        
        mobileTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        self.navigationController?.navigationBar.userInteractionEnabled = false
        let l = LoadingScreen(frame: view.bounds, message: "Logging In")
        view.addSubview(l)
        l.beginAnimation()
        
        if model.dataValidator.isValidPhoneNumber(mobileTextField.text!) {
            if model.dataValidator.isValidPassword(passwordTextField.text!) {
                model.userServiceProvider.login(mobileTextField.text!, password: passwordTextField.text!, completionHandler: {
                    (success:Bool, error: BygoError?)->Void in
                    self.navigationController?.navigationBar.userInteractionEnabled = true
                    if success {
                        self.delegate?.userDidLogin(true)
                    } else {
                        dispatch_async(GlobalMainQueue, {
                            l.endAnimation()
                            self.handleError(error)
                        })
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
        
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
        model?.userServiceProvider.attemptFacebookLogin({
            (data:[String:AnyObject]?) in
            if let data = data {
                print(data)
                guard let firstName     = data["first_name"] as? String else { return }
                guard let lastName      = data["last_name"] as? String else { return }
                guard let email         = data["email"] as? String else { return }
                guard let facebookID    = data["id"] as? String else { return }
                let signUpMethod        = "Facebook"
                
                UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
                self.navigationController?.navigationBar.userInteractionEnabled = false
                let l = LoadingScreen(frame: self.view.bounds, message: nil)
                self.view.addSubview(l)
                l.beginAnimation()
                
                self.model?.userServiceProvider.login(facebookID, completionHandler: {
                    (loginSuccess:Bool, error: BygoError?)->Void in
                    if loginSuccess {
                        self.delegate?.userDidLogin(true)
                    } else {
                        self.model?.userServiceProvider.createNewUser(firstName, lastName: lastName, email: email, phoneNumber: nil, facebookID: facebookID, password: nil, signupMethod: signUpMethod, completionHandler: {
                            (success:Bool, error: BygoError?)->Void in
                            self.navigationController?.navigationBar.userInteractionEnabled = true
                            if success {
                                self.delegate?.userDidLogin(false)
                                self.performSegueWithIdentifier("MobileSegue", sender: nil)
                            } else {
                                dispatch_async(GlobalMainQueue, {
                                    l.endAnimation()
                                    self.handleError(error)
                                })
                            }
                        })
                    }
                })
            } else {
                print("Error while logging in (signing up) with facebook")
            }
        })
    }
    
    @IBAction func panGestureRecognized(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(view)
        if abs(translation.y) > abs(translation.x) && translation.y > 0.0 {
            mobileTextField.resignFirstResponder()
            passwordTextField.resignFirstResponder()
        }
    }
    
    @IBAction func tapGestureRecognized(recognizer: UITapGestureRecognizer) {
        mobileTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    // MARK: - ErrorMessageDelegate
    func okayButtonTapped(error: BygoError) {
        return
    }
    
    func retryButtonTapped(error: BygoError) {
        // TODO: Attempt to login the user again
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "MobileSegue" {
            guard let destVC = segue.destinationViewController as? PhoneNumberVC else { return }
            destVC.delegate = delegate
            destVC.model = model
        }
    }
}

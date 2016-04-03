//
//  PhoneNumberVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 2/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class PhoneNumberVC: UIViewController, UITextFieldDelegate {
    
    var model:Model?
    var delegate:LoginDelegate?
    
    @IBOutlet var mobileLabel: UILabel!
    @IBOutlet var mobileTextField: UITextField!
    @IBOutlet var mobileView: UIView!
    
    @IBOutlet var phoneDisclaimerLabel: UILabel!
    
    @IBOutlet var doneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor    = kCOLOR_ONE
        navigationController?.navigationBar.translucent     = false
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        view.backgroundColor = kCOLOR_THREE
        mobileTextField.tintColor = kCOLOR_ONE
        mobileView.backgroundColor = .whiteColor()
        
        phoneDisclaimerLabel.font = UIFont.systemFontOfSize(12.0, weight: UIFontWeightMedium)
        phoneDisclaimerLabel.textColor = .blackColor()
        phoneDisclaimerLabel.alpha = 0.75
        
        mobileTextField.addTarget(self, action: #selector(PhoneNumberVC.textFieldDidChange(_:)), forControlEvents: .EditingChanged)
        
        doneButton.enabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func isUserDataValid() -> Bool {
        guard let model = model else { return false }
        
        guard let mobile = mobileTextField.text else { return false }
        if !model.dataValidator.isValidPhoneNumber(mobile) { return false }
        
        return true
    }
    
    
    
    // MARK: - TextField Delegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == mobileTextField
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
                doneButton.enabled = isUserDataValid()
                return false
            }
        }
        return true
    }
    
    func textFieldDidChange(textfield: UITextField) {
        doneButton.enabled = isUserDataValid()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        mobileTextField.resignFirstResponder()
        return true
    }

    // MARK: - UI Actions
    @IBAction func panGestureRecognized(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(view)
        if abs(translation.y) > abs(translation.x) && translation.y > 0.0 {
            mobileTextField.resignFirstResponder()
        }
    }
    
    @IBAction func nextButtonTapped(sender: AnyObject) {
        guard let model = model else { return }
        if model.dataValidator.isValidPhoneNumber(mobileTextField.text!) {
            // TODO: Send message to model to update the user's phone number
            guard let localUser = model.userServiceProvider.getLocalUser() else { return }
            let phoneNumber = mobileTextField.text!
            model.userServiceProvider.updateLocalUser(localUser.firstName!, lastName: localUser.lastName!, email: localUser.email!, phoneNumber: phoneNumber, completionHandler: { (success:Bool) -> Void in
                if success {
                    self.performSegueWithIdentifier("VerifyMobileSegue", sender: nil)
                } else {
                    print("Something went wrong while updating the user")
                }
            })
            
        } else {
            // TODO: Give user some indication of missing phone n umber
        }
    }
    
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "VerifyMobileSegue" {
            guard let destVC = segue.destinationViewController as? VerifyPhoneNumberVC else { return }
            destVC.delegate = delegate
            destVC.model = model
        }
    }
    
}

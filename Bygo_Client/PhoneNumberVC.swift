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
    var modalDelegate:ModalPhoneNumberDelegate?
    
    @IBOutlet var phoneNumberLabel: UILabel!
    @IBOutlet var phoneNumberTextField: UITextField!
    @IBOutlet var continueButton: UIButton!
    @IBOutlet var cancelButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        continueButton.backgroundColor = kCOLOR_ONE
        navigationController?.navigationBar.barTintColor   = kCOLOR_ONE
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    @IBAction func backButtonTapped(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func panGestureRecognized(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(view)
        if abs(translation.y) > abs(translation.x) && translation.y > 0.0 {
            phoneNumberTextField.resignFirstResponder()
        }
    }
    
    @IBAction func continueButtonTapped(sender: AnyObject) {
        if isValidPhoneNumber(phoneNumberTextField.text!) {
            // TODO: Send message to model to update the user's phone number
            guard let localUser = model?.userServiceProvider.getLocalUser() else { return }
            let phoneNumber = phoneNumberTextField.text!
            model?.userServiceProvider.updateLocalUser(localUser.firstName!, lastName: localUser.lastName!, email: localUser.email!, phoneNumber: phoneNumber, completionHandler: { (success:Bool) -> Void in
                if success {
                    self.performSegueWithIdentifier("ShowVerifyPhoneNumber", sender: nil)
                } else {
                    print("Something went wrong while updating the user")
                }
            })
            
        } else {
            // TODO: Give user some indication of missing phone number
        }
    }
    
    @IBAction func continueModalButtonTapped(sender: AnyObject) {
        if isValidPhoneNumber(phoneNumberTextField.text!) {
            guard let localUser = model?.userServiceProvider.getLocalUser() else { return }
            let phoneNumber = phoneNumberTextField.text!
            model?.userServiceProvider.updateLocalUser(localUser.firstName!, lastName: localUser.lastName!, email: localUser.email!, phoneNumber: phoneNumber, completionHandler: { (success:Bool) -> Void in
                if success {
                    self.modalDelegate?.updatePhoneNumber(phoneNumber)
                    self.dismissViewControllerAnimated(true, completion: nil)
                    //                    self.performSegueWithIdentifier("ShowVerifyPhoneNumber", sender: nil)
                } else {
                    print("Something went wrong while updating the user")
                }
            })
            // TODO: Send message to model to update the user's phone number
        } else {
            // TODO: Give user some indication of missing phone number
        }
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowVerifyPhoneNumber" {
            guard let destVC = segue.destinationViewController as? VerifyPhoneNumberVC else { return }
            destVC.phoneNumber = phoneNumberTextField.text!
            destVC.delegate = delegate
            destVC.model = model
        }
    }
    
}

protocol ModalPhoneNumberDelegate {
    func updatePhoneNumber(phoneNumber:String)
}

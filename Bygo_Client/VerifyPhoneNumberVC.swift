//
//  VerifyPhoneNumberVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 2/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class VerifyPhoneNumberVC: UIViewController, UITextFieldDelegate {
    
    var model:Model?
    
    var delegate:LoginDelegate?
    
    @IBOutlet var codeLabel: UILabel!
    @IBOutlet var codeTextField: UITextField!
    @IBOutlet var instructionLabel: UILabel!

    @IBOutlet var doneButton: UIButton!
    @IBOutlet var resendCodeButton: UIButton!
    @IBOutlet var changePhoneNumberButton: UIButton!
    
    @IBOutlet var codeView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        codeView.backgroundColor = kCOLOR_THREE
        
        doneButton.alpha = 0.0
        
        codeTextField.addTarget(self, action: #selector(VerifyPhoneNumberVC.textFieldDidChange(_:)), forControlEvents: .EditingChanged)
        
        guard let userID = model?.userServiceProvider.getLocalUser()?.userID else { return }
        model?.phoneNumberServiceProvider.sendPhoneNumberVerificationCode(userID, completionHandler: {
            (success:Bool) in
            if !success {
                print("Error sending code")
                // TODO: Show some error message to the user
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func isUserDataValid() -> Bool {
        guard let model = model else { return false }
        
        guard let code = codeTextField.text else { return false }
        if !model.dataValidator.isValidMobileVerificationCode(code) { return false }
        
        return true
    }
    
    func enableDoneButtonIfNeeded() {
        if isUserDataValid() {
            UIView.animateWithDuration(0.5, animations: {
                self.doneButton.alpha = 1.0
            })
        } else {
            UIView.animateWithDuration(0.5, animations: {
                self.doneButton.alpha = 0.0
            })
        }
    }
    
    
    func updatePhoneNumber(phoneNumber: String) {
        guard let userID = model?.userServiceProvider.getLocalUser()?.userID else { return }
        model?.phoneNumberServiceProvider.sendPhoneNumberVerificationCode(userID, completionHandler: {
            (success:Bool) in
            if !success {
                print("Error sending code")
                // TODO: Show some error message to the user
            }
        })
        
    }
    
    // MARK: - TextField Delegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == codeTextField {
            if let text = textField.text {
                let newString = (text as NSString).stringByReplacingCharactersInRange(range, withString: string)
                if newString.characters.count > kREQUIRED_CODE_NUM_CHARACTERS {
                    return false
                }
            }
        }
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        codeView.backgroundColor = .whiteColor()
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        codeView.backgroundColor = kCOLOR_THREE
    }
    
    func textFieldDidChange(textfield: UITextField) {
        enableDoneButtonIfNeeded()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        codeView.resignFirstResponder()
        return true
    }
    
    
    // MARK: - UI Actions
    @IBAction func panGestureRecognized(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(view)
        if abs(translation.y) > abs(translation.x) && translation.y > 0.0 {
            codeTextField.resignFirstResponder()
        }
    }
    
    @IBAction func doneButtonTapped(sender: AnyObject) {
        guard let code = codeTextField.text else { return }
        guard let userID = model?.userServiceProvider.getLocalUser()?.userID else { return }
        model?.phoneNumberServiceProvider.checkPhoneNumberVerificationCode(userID, code: code, completionHandler: {
            (success:Bool) in
            if success {
                self.delegate?.phoneNumberDidVerify(true)
            } else {
                print("Error while checking phone verification code")
                // TODO: Show some error message to the user
            }
        })
    }
    
    @IBAction func resendCodeButtonTapped(sender: AnyObject) {
        guard let userID = model?.userServiceProvider.getLocalUser()?.userID else { return }
        model?.phoneNumberServiceProvider.sendPhoneNumberVerificationCode(userID, completionHandler: {
            (success:Bool) in
            if !success {
                print("Error sending code")
                // TODO: Show some error message to the user
            }
        })
    }
    
    @IBAction func changePhoneNumberButtonTapped(sender: AnyObject) {
        
    }
}

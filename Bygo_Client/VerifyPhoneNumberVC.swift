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
    var isModalPresentation: Bool = false
    
    @IBOutlet var codeLabel: UILabel!
    @IBOutlet var codeTextField: UITextField!
    @IBOutlet var instructionLabel: UILabel!

    @IBOutlet var doneButton: UIBarButtonItem!
    @IBOutlet var resendCodeButton: UIButton!
    @IBOutlet var changePhoneNumberButton: UIButton!
    
    @IBOutlet var codeView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor    = kCOLOR_ONE
        navigationController?.navigationBar.translucent     = false
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        if !isModalPresentation {
            navigationItem.leftBarButtonItem?.enabled = false
            navigationItem.leftBarButtonItem?.tintColor = .clearColor()
        } else {
            navigationItem.leftBarButtonItem?.enabled = true
            navigationItem.leftBarButtonItem?.target = self
            navigationItem.leftBarButtonItem?.action = #selector(cancelButtonTapped(_:))
        }
        
        view.backgroundColor = kCOLOR_THREE
        codeView.backgroundColor = .whiteColor()
        doneButton.enabled = false
        
        instructionLabel.font = UIFont.systemFontOfSize(12.0, weight: UIFontWeightMedium)
        instructionLabel.textColor = .blackColor()
        instructionLabel.alpha = 0.75
        
        resendCodeButton.setTitleColor(kCOLOR_ONE, forState: .Normal)
        if changePhoneNumberButton != nil {
            changePhoneNumberButton.setTitleColor(kCOLOR_ONE, forState: .Normal)
        }
        
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
    
    override func viewDidAppear(animated: Bool) {
        
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
    
    
    func textFieldDidChange(textfield: UITextField) {
        doneButton.enabled = isUserDataValid()
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
        self.codeTextField.resignFirstResponder()
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
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func changePhoneNumberButtonTapped(sender: AnyObject) {
        
    }
}

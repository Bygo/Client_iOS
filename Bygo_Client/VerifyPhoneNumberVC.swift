//
//  VerifyPhoneNumberVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 2/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class VerifyPhoneNumberVC: UIViewController, UITextFieldDelegate, ErrorMessageDelegate {
    
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
            (success:Bool, error: BygoError?) in
            if !success {
                dispatch_async(GlobalMainQueue, {
                    self.handleError(error)
                })
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
    
    
    // TODO: What is this for??
    func updatePhoneNumber(phoneNumber: String) {
        guard let userID = model?.userServiceProvider.getLocalUser()?.userID else { return }
        model?.phoneNumberServiceProvider.sendPhoneNumberVerificationCode(userID, completionHandler: {
            (success:Bool, error: BygoError?) in
            if !success {
                
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
        
        self.navigationController?.navigationBar.userInteractionEnabled = false
        let l = LoadingScreen(frame: self.view.bounds, message: nil)
        self.view.addSubview(l)
        l.beginAnimation()
        
        model?.phoneNumberServiceProvider.checkPhoneNumberVerificationCode(userID, code: code, completionHandler: {
            (success:Bool, error:BygoError?) in
            
            self.navigationController?.navigationBar.userInteractionEnabled = true
            
            if success {
                self.delegate?.phoneNumberDidVerify(true)
            } else {
                dispatch_async(GlobalMainQueue, {
                    l.endAnimation()
                    self.handleError(error)
                })
            }
        })
    }
    
    @IBAction func resendCodeButtonTapped(sender: AnyObject) {
        guard let userID = model?.userServiceProvider.getLocalUser()?.userID else { return }
        
        self.navigationController?.navigationBar.userInteractionEnabled = false
        let l = LoadingScreen(frame: self.view.bounds, message: nil)
        self.view.addSubview(l)
        l.beginAnimation()
        
        model?.phoneNumberServiceProvider.sendPhoneNumberVerificationCode(userID, completionHandler: {
            (success:Bool, error: BygoError?) in
            self.navigationController?.navigationBar.userInteractionEnabled = true
            dispatch_async(GlobalMainQueue, {
                l.endAnimation()
                dispatch_async(GlobalMainQueue, {
                    if success {
                        self.handleError(.VerificationCodeSent)
                    } else {
                        self.handleError(error)
                    }
                })
            })
        })
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func changePhoneNumberButtonTapped(sender: AnyObject) {
        
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
        case .VerificationCodeSent:
            e = ErrorMessage(frame: window.bounds, title: "Verification Code Sent", detail: "Please allow for up to 2 minutes for code to arrive via SMS", error: error, priority: .Low, options: [ErrorMessageOptions.Okay])
        
        case .PhoneNumberAlreadyVerified:
            e = ErrorMessage(frame: window.bounds, title: "Already Verified", detail: "This phone number has already been verified with your account", error: error, priority: .High, options: [ErrorMessageOptions.Okay])
            
        case .VerificationCodeExpired:
            e = ErrorMessage(frame: window.bounds, title: "Verification Code Expired", detail: "Tap \"Okay\" to send a new code via SMS", error: error, priority: .High, options: [ErrorMessageOptions.Okay])
            
        case .VerificationCodeInvalid:
            e = ErrorMessage(frame: window.bounds, title: "Verification Code Invalid", detail: "Tap \"Okay\" to send a new code via SMS", error: error, priority: .High, options: [ErrorMessageOptions.Okay])
            
        default:
            e = ErrorMessage(frame: window.bounds, title: "Uh oh!", detail: "Something went wrong. Please contact support@bygo.io for help", error: .Unknown, priority: .High, options: [ErrorMessageOptions.Okay])
        }
        
        if let e = e {
            e.delegate = self
            window.addSubview(e)
            e.show()
        }
    }
    
    func okayButtonTapped(error: BygoError) {
        return
    }
    
    func retryButtonTapped(error: BygoError) {
        return
    }
}

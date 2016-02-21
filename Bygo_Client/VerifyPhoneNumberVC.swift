//
//  VerifyPhoneNumberVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 2/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class VerifyPhoneNumberVC: UIViewController, ModalPhoneNumberDelegate {
    
    let serverURL = "https://spartan-1131.appspot.com"
    var model:Model? {
        didSet {
            guard let phoneNumber = model?.userServiceProvider.getLocalUser()?.phoneNumber else {
                print("Did not get valid phone number from model")
                return
            }
            self.phoneNumber = phoneNumber
        }
    }
    
    var delegate:LoginDelegate?
    
    var phoneNumber:String = ""
    
    @IBOutlet var instructionLabel: UILabel!
    @IBOutlet var confirmationLabel: UILabel!
    @IBOutlet var codeTextField: UITextField!
    @IBOutlet var confirmButton: UIButton!
    @IBOutlet var resendCodeButton: UIButton!
    @IBOutlet var changePhoneNumberButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let instructionText = "We will text a confirmation code to \(phoneNumber) in the next 30 seconds. Please retype the confirmation code below and press CONFIRM"
        instructionLabel.text = instructionText
        
        confirmButton.backgroundColor   = kCOLOR_ONE
        navigationItem.hidesBackButton  = true
        
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
    
    func updatePhoneNumber(phoneNumber: String) {
        self.phoneNumber = phoneNumber
        
        let instructionText = "We will text a confirmation code to \(phoneNumber) in the next 30 seconds. Please retype the confirmation code below and press CONFIRM"
        instructionLabel.text = instructionText
        
        guard let userID = model?.userServiceProvider.getLocalUser()?.userID else { return }
        model?.phoneNumberServiceProvider.sendPhoneNumberVerificationCode(userID, completionHandler: {
            (success:Bool) in
            if !success {
                print("Error sending code")
                // TODO: Show some error message to the user
            }
        })
        
    }
    
    // MARK: - UI Actions
    @IBAction func panGestureRecognized(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(view)
        if abs(translation.y) > abs(translation.x) && translation.y > 0.0 {
            codeTextField.resignFirstResponder()
        }
    }
    
    @IBAction func confirmButtonTapped(sender: AnyObject) {
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

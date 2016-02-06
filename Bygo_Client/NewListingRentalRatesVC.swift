//
//  NewListingRentalRatesVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 4/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class NewListingRentalRatesVC: UIViewController {
    
    @IBOutlet var instructionLabel:UILabel!
    @IBOutlet var hourlyRateLabel:UILabel!
    @IBOutlet var dailyRateLabel:UILabel!
    @IBOutlet var weeklyRateLabel:UILabel!
    @IBOutlet var hourlyRateCurrencyLabel:UILabel!
    @IBOutlet var dailyRateCurrencyLabel:UILabel!
    @IBOutlet var weeklyRateCurrencyLabel:UILabel!
    @IBOutlet var hourlyRateTextField:UITextField!
    @IBOutlet var dailyRateTextField:UITextField!
    @IBOutlet var weeklyRateTextField:UITextField!
    @IBOutlet var continueButton:UIButton!
    @IBOutlet var resetButton:UIButton!
    
    var model:Model?
    var listingName:String?
    var listingDepartment:Department?
    var listingCategory:Category?
    var listingImages:[UIImage] = []
    var listingValue:Double?
    
    var suggestedHourlyRate:Double?
    var suggestedDailyRate:Double?
    var suggestedWeeklyRate:Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        
        // TODO: Send request to server to get the suggested rates for the itemValue
        suggestedHourlyRate = 2.40
        suggestedDailyRate = 12.50
        suggestedWeeklyRate = 35.00
        hourlyRateTextField.text        = String(format: "%.2f", suggestedHourlyRate!)
        dailyRateTextField.text         = String(format: "%.2f", suggestedDailyRate!)
        weeklyRateTextField.text        = String(format: "%.2f", suggestedWeeklyRate!)
        hourlyRateTextField.placeholder = String(format: "%.2f (suggested)", suggestedHourlyRate!)
        dailyRateTextField.placeholder  = String(format: "%.2f (suggested)", suggestedDailyRate!)
        weeklyRateTextField.placeholder = String(format: "%.2f (suggested)", suggestedWeeklyRate!)
        resetButton.enabled = false
        
        continueButton.enabled = isDataValid()
        
        hourlyRateTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: .EditingChanged)
        dailyRateTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: .EditingChanged)
        weeklyRateTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: .EditingChanged)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Data
    func isDataValid() -> Bool {
        let isHourlyRateValid = hourlyRateTextField.text?.characters.count > 0
        let isDailyRateValid = dailyRateTextField.text?.characters.count > 0
        let isWeeklyRateValid = weeklyRateTextField.text?.characters.count > 0
        
        return isHourlyRateValid && isDailyRateValid && isWeeklyRateValid
    }
    
    func areRatesTheSuggestedRates() -> Bool {
        let hourlyRate = NSString(string: hourlyRateTextField.text!).doubleValue
        let dailyRate = NSString(string: dailyRateTextField.text!).doubleValue
        let weeklyRate = NSString(string: weeklyRateTextField.text!).doubleValue
        let isHourlyRateSuggested = hourlyRate == suggestedHourlyRate
        let isDailyRateSuggested = dailyRate == suggestedDailyRate
        let isWeeklyRateSuggested = weeklyRate == suggestedWeeklyRate
        return isHourlyRateSuggested && isDailyRateSuggested && isWeeklyRateSuggested
    }
    
    // MARK: - Keyboard
    func keyboardWillShow(notification: NSNotification) {
        if let _ = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y = -80.0
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let _ = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y = 0.0
        }
    }
    
    
    // MARK: - TextField Delegate
    func textFieldDidChange(sender:AnyObject) {
        continueButton.enabled = isDataValid()
        resetButton.enabled = !areRatesTheSuggestedRates()
    }
    
    
    // MARK: - UIActions
    @IBAction func panGestureRecognized(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(view)
        if abs(translation.y) > abs(translation.x) && translation.y > 0.0 {
            hourlyRateTextField.resignFirstResponder()
            dailyRateTextField.resignFirstResponder()
            weeklyRateTextField.resignFirstResponder()
        }
    }
    
    @IBAction func continueButtonTapped(sender:AnyObject) {
        if isDataValid() {
            performSegueWithIdentifier("ShowGiveDescription", sender: nil)
        }
    }
    
    @IBAction func resetButtonTapped(sender:AnyObject) {
        guard let suggestedHourlyRate = suggestedHourlyRate else { return }
        guard let suggestedDailyRate = suggestedDailyRate else { return }
        guard let suggestedWeeklyRate = suggestedWeeklyRate else { return }
        hourlyRateTextField.text = String(format: "%.2f", suggestedHourlyRate)
        dailyRateTextField.text = String(format: "%.2f", suggestedDailyRate)
        weeklyRateTextField.text = String(format: "%.2f", suggestedWeeklyRate)
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowGiveDescription" {
            guard let destVC = segue.destinationViewController as? NewListingDescriptionVC else { return }
            destVC.model                = model
            destVC.listingName          = listingName
            destVC.listingDepartment    = listingDepartment
            destVC.listingCategory      = listingCategory
            destVC.listingImages        = listingImages
            destVC.listingValue         = listingValue
            destVC.listingHourlyRate    = Double(NSString(string: hourlyRateTextField.text!).floatValue)
            destVC.listingDailyRate     = Double(NSString(string: dailyRateTextField.text!).floatValue)
            destVC.listingWeeklyRate    = Double(NSString(string: weeklyRateTextField.text!).floatValue)
        }
    }
}

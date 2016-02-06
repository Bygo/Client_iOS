//
//  EditListingRentalRatesVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 4/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

import UIKit

class EditListingRentalRatesVC: UIViewController {
    
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
    var delegate:EditListingRentalRatesDelegate?
    var listing:Listing?
    
    var suggestedHourlyRate:Double?
    var suggestedDailyRate:Double?
    var suggestedWeeklyRate:Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        hourlyRateTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: .EditingChanged)
        dailyRateTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: .EditingChanged)
        weeklyRateTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: .EditingChanged)
        
        if let hourlyRate = listing?.hourlyRate.value {
            hourlyRateTextField.text    = String(format: "%.2f", hourlyRate)
        }
        if let dailyRate = listing?.dailyRate.value {
            dailyRateTextField.text     = String(format: "%.2f", dailyRate)
        }
        if let weeklyRate = listing?.weeklyRate.value {
            weeklyRateTextField.text    = String(format: "%.2f", weeklyRate)
        }
        
        // TODO: Send request to server to get the suggested rates for the itemValue
        suggestedHourlyRate = 2.40
        suggestedDailyRate  = 12.50
        suggestedWeeklyRate = 35.00
        
        hourlyRateTextField.placeholder = String(format: "%.2f (suggested)", suggestedHourlyRate!)
        dailyRateTextField.placeholder  = String(format: "%.2f (suggested)", suggestedDailyRate!)
        weeklyRateTextField.placeholder = String(format: "%.2f (suggested)", suggestedWeeklyRate!)
        resetButton.enabled             = false
        
        continueButton.enabled = isDataValid()
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
        let isHourlyRateValid   = hourlyRateTextField.text?.characters.count > 0
        let isDailyRateValid    = dailyRateTextField.text?.characters.count > 0
        let isWeeklyRateValid   = weeklyRateTextField.text?.characters.count > 0
        
        return isHourlyRateValid && isDailyRateValid && isWeeklyRateValid
    }
    
    func areRatesTheSuggestedRates() -> Bool {
        let hourlyRate              = NSString(string: hourlyRateTextField.text!).doubleValue
        let dailyRate               = NSString(string: dailyRateTextField.text!).doubleValue
        let weeklyRate              = NSString(string: weeklyRateTextField.text!).doubleValue
        let isHourlyRateSuggested   = hourlyRate == suggestedHourlyRate
        let isDailyRateSuggested    = dailyRate  == suggestedDailyRate
        let isWeeklyRateSuggested   = weeklyRate == suggestedWeeklyRate
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
            
            let hourlyRate  = NSString(string: hourlyRateTextField.text!).doubleValue
            let dailyRate   = NSString(string: dailyRateTextField.text!).doubleValue
            let weeklyRate  = NSString(string: weeklyRateTextField.text!).doubleValue
            
            guard let listingID         = listing?.listingID            else { return }
            guard let name              = listing?.name                 else { return }
            guard let categoryID        = listing?.categoryID           else { return }
            guard let totalValue        = listing?.totalValue.value     else { return }
            guard let itemDescription   = listing?.itemDescription      else { return }
            
            model?.listingServiceProvider.updateListing(listingID, name: name, categoryID: categoryID, totalValue: totalValue, hourlyRate: hourlyRate, dailyRate: dailyRate, weeklyRate: weeklyRate, itemDescription: itemDescription, completionHandler: {
                (success:Bool) in
                if success {
                    self.delegate?.didUpdateRentalRates()
                    self.navigationController?.popToRootViewControllerAnimated(true)
                } else {
                    print("Error updating the Listing")
                }
            })
        }
    }
    
    @IBAction func resetButtonTapped(sender:AnyObject) {
        guard let suggestedHourlyRate   = suggestedHourlyRate   else { return }
        guard let suggestedDailyRate    = suggestedDailyRate    else { return }
        guard let suggestedWeeklyRate   = suggestedWeeklyRate   else { return }
        hourlyRateTextField.text        = String(format: "%.2f", suggestedHourlyRate)
        dailyRateTextField.text         = String(format: "%.2f", suggestedDailyRate)
        weeklyRateTextField.text        = String(format: "%.2f", suggestedWeeklyRate)
    }
}


protocol EditListingRentalRatesDelegate {
    func didUpdateRentalRates()
}
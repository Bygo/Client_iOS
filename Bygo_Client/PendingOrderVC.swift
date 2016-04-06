//
//  PendingOrderVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 5/4/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import RealmSwift

class PendingOrderVC: UIViewController, ErrorMessageDelegate {

    var model: Model?
    var orderID: String?
    var delegate: PendingOrderDelegate?
    
    @IBOutlet var itemTypeTextField: UITextField!
    @IBOutlet var durationTextField: UITextField!
    @IBOutlet var priceTextField: UITextField!
    
    @IBOutlet var itemTypeView: UIView!
    @IBOutlet var durationView: UIView!
    @IBOutlet var priceView: UIView!
    
    @IBOutlet var cancelOrderButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = kCOLOR_THREE
        
        itemTypeView.backgroundColor = .whiteColor()
        durationView.backgroundColor = .whiteColor()
        priceView.backgroundColor = .whiteColor()
        
        cancelOrderButton.backgroundColor = .clearColor()
        cancelOrderButton.setTitleColor(kCOLOR_TWO, forState: .Normal)
        cancelOrderButton.setTitleColor(UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 0.75), forState: .Highlighted)
        cancelOrderButton.setTitle("Cancel Order", forState: .Normal)
        
        refresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func refresh() {
        guard let orderID = orderID else { return }
        
        model?.orderServiceProvider.fetchOrder(orderID, completionHandler:{
            (success:Bool) in
            if success {
                let realm = try! Realm()
                let order = realm.objects(Order).filter("orderID == \"\(orderID)\"")[0]
                
                guard let typeID = order.typeID else { return }
                guard let duration = order.duration.value else { return }
                guard let price = order.rentalFee.value else { return }
                
                self.model?.itemTypeServiceProvider.fetchItemType(typeID, completionHandler: {
                    (success:Bool) in
                    if success {
                        let realm = try! Realm()
                        let type = realm.objects(ItemType).filter("typeID == \"\(typeID)\"")[0]
                        guard let name = type.name else { return }
                        dispatch_async(GlobalMainQueue, {
                            self.itemTypeTextField.text = name
                        })
                    }
                })
                
                dispatch_async(GlobalMainQueue, {
                    if duration == 1 {
                        self.durationTextField.text = "\(duration) Day"
                    } else {
                        self.durationTextField.text = "\(duration) Days"
                    }
                    
                    self.priceTextField.text = "$\(Int(price))"
                })
            }
        })
        
        
    }
    
    // MARK: - UIActions
    @IBAction func backButtonTapped(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        // TODO: Cancel the order
        handleError(.CancelOrderWarning)
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
        case .CancelOrderWarning:
            e = ErrorMessage(frame: window.bounds, title: "Are You Sure?", detail: "Tap \"Okay\" to cancel this order", error: .CancelOrderWarning, priority: .Low, options: [ErrorMessageOptions.Cancel, ErrorMessageOptions.Okay])
            
        default:
            e = ErrorMessage(frame: window.bounds, title: "Uh oh!", detail: "Something went wrong", error: .Unknown, priority: .High, options: [ErrorMessageOptions.Cancel, ErrorMessageOptions.Retry])
        }
        
        if let e = e {
            e.delegate = self
            window.addSubview(e)
            e.show()
        }
    }
    
    func okayButtonTapped(error: BygoError) {
        switch error {
        case .CancelOrderWarning:
            guard let orderID = orderID else { return }
            
            // TODO: Add loading screen
            self.navigationController?.navigationBar.userInteractionEnabled = false
            let l = LoadingScreen(frame: view.bounds, message: "Cancelling Order")
            view.addSubview(l)
            l.beginAnimation()
            
            model?.orderServiceProvider.cancelOrder(orderID, completionHandler: {
                (success:Bool, error:BygoError?) in
                // TODO: Dismiss loading screen
                dispatch_async(GlobalMainQueue, {
                    self.navigationController?.navigationBar.userInteractionEnabled = true
                    if success {
                        self.delegate?.didCancelOrder(orderID)
                        self.navigationController?.popViewControllerAnimated(true)
                    } else {
                        self.handleError(error)
                    }
                })
            })
            break
            
        default:
            return
        }
    }
    
    func retryButtonTapped(error: BygoError) {

    }
}


protocol PendingOrderDelegate {
    func didCancelOrder(orderID: String)
}

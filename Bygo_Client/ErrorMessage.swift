//
//  ErrorMessage.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 3/4/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class ErrorMessage: UIView {

    private let kERROR_VIEW_HEIGHT: CGFloat = 320.0
    @IBOutlet private var backgroundView: UIView!
    @IBOutlet private var errorView: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var detailLabel: UILabel!
    @IBOutlet private var errorViewTopOffset: NSLayoutConstraint!
    
    var delegate: ErrorMessageDelegate?
    var error: BygoError?
    var title: String?
    var detail: String?
    
    init(frame: CGRect, title:String, detail:String?, error:BygoError, priority: ErrorMessagePriority, options:[ErrorMessageOptions]) {
        super.init(frame: frame)
        
        self.error = error
        
        backgroundColor = .clearColor()
        
        backgroundView = UIView()
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundView)
        backgroundView.backgroundColor = kCOLOR_THREE
        backgroundView.alpha = 0.0
        backgroundView.widthAnchor.constraintEqualToAnchor(widthAnchor, multiplier: 1.0).active = true
        backgroundView.heightAnchor.constraintEqualToAnchor(heightAnchor, multiplier: 1.0).active = true
        backgroundView.centerXAnchor.constraintEqualToAnchor(centerXAnchor).active = true
        backgroundView.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
        
        
        errorView = UIView()
        errorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(errorView)
        errorView.widthAnchor.constraintEqualToAnchor(widthAnchor, multiplier: 1.0).active = true
        errorView.centerXAnchor.constraintEqualToAnchor(centerXAnchor).active = true
        errorViewTopOffset = errorView.topAnchor.constraintEqualToAnchor(topAnchor, constant: frame.size.height)
        errorViewTopOffset.active = true
//        errorView.backgroundColor = kCOLOR_TWO
        
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFontOfSize(24.0)
//        titleLabel.textColor = .whiteColor()
        titleLabel.text = title
        titleLabel.textAlignment = .Center
        titleLabel.numberOfLines = 0
        titleLabel.sizeToFit()
        errorView.addSubview(titleLabel)
        titleLabel.centerXAnchor.constraintEqualToAnchor(errorView.centerXAnchor).active = true
        titleLabel.leadingAnchor.constraintEqualToAnchor(errorView.leadingAnchor, constant: 24.0).active = true
        titleLabel.topAnchor.constraintEqualToAnchor(errorView.topAnchor, constant: 24.0).active = true

        detailLabel = UILabel()
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.font = UIFont.systemFontOfSize(16.0, weight: UIFontWeightMedium)
//        detailLabel.textColor = .whiteColor()
        detailLabel.alpha = 0.75
        detailLabel.text = detail
        detailLabel.textAlignment = .Center
        detailLabel.numberOfLines = 0
        detailLabel.sizeToFit()
        errorView.addSubview(detailLabel)
        detailLabel.centerXAnchor.constraintEqualToAnchor(errorView.centerXAnchor).active = true
        detailLabel.leadingAnchor.constraintEqualToAnchor(errorView.leadingAnchor, constant: 24.0).active = true
        detailLabel.topAnchor.constraintEqualToAnchor(titleLabel.bottomAnchor, constant: 8.0).active = true

        
        switch priority {
        case .High:
            errorView.backgroundColor = kCOLOR_TWO
            titleLabel.textColor = .whiteColor()
            detailLabel.textColor = .whiteColor()
        default:
            errorView.backgroundColor = .whiteColor()
            titleLabel.textColor = kCOLOR_ONE
            detailLabel.textColor = kCOLOR_ONE
        }
        
        if options.count > 2 || options.count < 1 {
            errorView.bottomAnchor.constraintEqualToAnchor(detailLabel.bottomAnchor, constant: 24.0).active = true
            layoutIfNeeded()
            return
        }
        
        var i = 0
        for option in options {
            let o = UIButton()
            o.translatesAutoresizingMaskIntoConstraints = false
            
            errorView.addSubview(o)
            
//            o.setTitleColor(.whiteColor(), forState: .Normal)
//            o.setTitleColor(UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5), forState: .Highlighted)
            o.titleLabel?.font = UIFont.systemFontOfSize(18.0)
            o.setTitle(option.rawValue, forState: .Normal)
            
            o.widthAnchor.constraintEqualToAnchor(widthAnchor, multiplier: 1.0/CGFloat(options.count)).active = true
            o.topAnchor.constraintEqualToAnchor(detailLabel.bottomAnchor, constant: 24.0).active = true
            o.heightAnchor.constraintEqualToConstant(56.0).active = true
            
            switch priority {
            case .High:
                o.setTitleColor(.whiteColor(), forState: .Normal)
                o.setTitleColor(UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5), forState: .Highlighted)
                
            default:
                o.setTitleColor(kCOLOR_ONE, forState: .Normal)
                o.setTitleColor(UIColor(red: 44.0/255.0, green: 62.0/255.0, blue: 80.0/255.0, alpha: 0.5), forState: .Highlighted)
            }
            
            if i == 0 {
                o.leadingAnchor.constraintEqualToAnchor(leadingAnchor).active = true
                errorView.bottomAnchor.constraintEqualToAnchor(o.bottomAnchor, constant: 12.0).active = true
                if options.count == 1 {
                    o.titleLabel?.font = UIFont.systemFontOfSize(18.0, weight: UIFontWeightMedium)
                }
            }
            else {
                o.titleLabel?.font = UIFont.systemFontOfSize(18.0, weight: UIFontWeightMedium)
                o.trailingAnchor.constraintEqualToAnchor(trailingAnchor).active = true
            }
            
            switch option {
            case .Okay:
                o.addTarget(self, action: #selector(ErrorMessage.okayButtonTapped(_:)), forControlEvents: .TouchUpInside)
            case .Cancel:
                o.addTarget(self, action: #selector(ErrorMessage.cancelButtonTapped(_:)), forControlEvents: .TouchUpInside)
            case .Retry:
                o.addTarget(self, action: #selector(ErrorMessage.retryButtonTapped(_:)), forControlEvents: .TouchUpInside)
            }
            i += 1
        }
        
        layoutIfNeeded()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func show() {
        errorViewTopOffset.constant = (bounds.height/2.0) - (errorView.bounds.height/2.0)
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: {
            self.errorView.layoutIfNeeded()
            self.backgroundView.alpha = 0.75
        }, completion: nil)
    }
    
    @IBAction func okayButtonTapped(sender: UIButton) {
        errorViewTopOffset.constant = bounds.height
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseIn, animations: {
            self.errorView.layoutIfNeeded()
            self.backgroundView.alpha = 0.0
            }, completion: {
                (complete:Bool) in
                if complete {
                    self.removeFromSuperview()
                    self.delegate?.okayButtonTapped(self.error!)
                }
        })
    }
    
    @IBAction func cancelButtonTapped(sender: UIButton) {
        errorViewTopOffset.constant = bounds.height
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseIn, animations: {
            self.errorView.layoutIfNeeded()
            self.backgroundView.alpha = 0.0
        }, completion: {
            (complete:Bool) in
            if complete {
                self.removeFromSuperview()
            }
        })
    }
    
    @IBAction func retryButtonTapped(sender: UIButton) {
        errorViewTopOffset.constant = bounds.height
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseIn, animations: {
            self.errorView.layoutIfNeeded()
            self.backgroundView.alpha = 0.0
            }, completion: {
                (complete:Bool) in
                if complete {
                    self.removeFromSuperview()
                    self.delegate?.retryButtonTapped(self.error!)
                }
        })
    }
}

protocol ErrorMessageDelegate {
    func retryButtonTapped(error: BygoError)
    func okayButtonTapped(error: BygoError)
}


enum ErrorMessagePriority {
    case Low
    case Medium
    case High
}


enum ErrorMessageOptions: String {
    case Okay = "Okay"
    case Retry = "Retry"
    case Cancel = "Cancel"
}
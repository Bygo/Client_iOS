//
//  MeetingTimeProposalView.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 4/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class MeetingTimeProposalView: UIView {
    
    var dataSource:MeetingTimeProposalViewDataSource?
    var delegate:MeetingTimeProposalViewDelegate?
    
    private let kHOUR_SPACING:CGFloat = 60.0
    
    private var timeSlotViews:[UIView] = []
    private var shouldChangeToAvailable:Bool = true
    private var panStartIndx:Int = 0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // FIXME: Pull UI elements from global repo
        layer.cornerRadius = 0.0
        layer.masksToBounds = true
        
    }
    
    
    func reload() {
        guard let dataSource = self.dataSource else { return }
        
        let calendar = NSCalendar.currentCalendar()
        
        for i in 0..<dataSource.numProposedMeetingTimes() {
            
            let timeSlotView = UIView()
            addSubview(timeSlotView)
            if dataSource.availabilityForProposedMeetingTime(atIndex: i) {
                timeSlotView.backgroundColor = .greenColor()
            } else {
                timeSlotView.backgroundColor = .redColor()
            }
            
            let heightFactor = (dataSource.durationForProposedMeetingTime(atIndex: i)/60.0)
            timeSlotView.translatesAutoresizingMaskIntoConstraints = false
            timeSlotView.heightAnchor.constraintEqualToConstant(kHOUR_SPACING * CGFloat(heightFactor)).active = true
            timeSlotView.topAnchor.constraintEqualToAnchor(topAnchor, constant: CGFloat(i)*(kHOUR_SPACING * CGFloat(heightFactor))).active = true
            timeSlotView.widthAnchor.constraintEqualToAnchor(widthAnchor).active = true
            timeSlotView.centerXAnchor.constraintEqualToAnchor(centerXAnchor).active = true
            timeSlotViews.append(timeSlotView)
            sendSubviewToBack(timeSlotView)
            
            
            // Add time label
            if i%2 == 1 {
                let time = dataSource.timeForProposedMeetingTime(atIndex: i)
                let components = calendar.components([.Hour, .Minute], fromDate: time)
                let hour = components.hour
                let minutes = components.minute
                let hourLabel = UILabel()
                addSubview(hourLabel)
                hourLabel.textAlignment = .Center
                hourLabel.textColor = .whiteColor()
                hourLabel.text =  String(format: "%d:%02d", hour, minutes)
                hourLabel.sizeToFit()
                hourLabel.translatesAutoresizingMaskIntoConstraints = false
                hourLabel.widthAnchor.constraintEqualToAnchor(widthAnchor).active = true
                hourLabel.centerXAnchor.constraintEqualToAnchor(centerXAnchor).active = true
                hourLabel.topAnchor.constraintEqualToAnchor(topAnchor, constant: (kHOUR_SPACING/2) + (CGFloat((i-1)/2)*kHOUR_SPACING) - hourLabel.bounds.height/2.0).active = true
            }
            
            if i == dataSource.numProposedMeetingTimes()-1 {
                bottomAnchor.constraintEqualToAnchor(timeSlotView.bottomAnchor, constant: 0).active = true
            }
        }
    }
    
    func tapAtLocation(loc:CGPoint) {
        guard let dataSource = dataSource else { return }
        for i in 0..<dataSource.numProposedMeetingTimes() {
            let timeSlotView = timeSlotViews[i]
            if CGRectContainsPoint(timeSlotView.frame, loc) {
                delegate?.didChangeAvailability(atIndex: i)
                let isAvailable = dataSource.availabilityForProposedMeetingTime(atIndex: i)
                if isAvailable {
                    timeSlotView.backgroundColor = .greenColor()
                } else {
                    timeSlotView.backgroundColor = .redColor()
                }
                return
            }
        }
    }
    
    func panBeganAtLocation(loc:CGPoint) {
        guard let dataSource    = dataSource else { return }
        guard let delegate      = delegate else { return }
        
        for i in 0..<dataSource.numProposedMeetingTimes() {
            let timeSlotView = timeSlotViews[i]
            if CGRectContainsPoint(timeSlotView.frame, loc) {
                panStartIndx = i
                delegate.didChangeAvailability(atIndex: i)
                shouldChangeToAvailable = dataSource.availabilityForProposedMeetingTime(atIndex: i)
                
                if dataSource.availabilityForProposedMeetingTime(atIndex: i) {
                    timeSlotView.backgroundColor = .greenColor()
                } else {
                    timeSlotView.backgroundColor = .redColor()
                }
                return
            }
        }
    }
    
    func panMovedToLocation(loc:CGPoint) {
        
        guard let dataSource    = dataSource else { return }
        guard let delegate      = delegate else { return }
        
        for i in 0..<dataSource.numProposedMeetingTimes() {
            let timeSlotView = timeSlotViews[i]
            if CGRectContainsPoint(timeSlotView.frame, loc) {
                
                if dataSource.availabilityForProposedMeetingTime(atIndex: i) != shouldChangeToAvailable {
                    delegate.didChangeAvailability(atIndex: i)
                }
                if dataSource.availabilityForProposedMeetingTime(atIndex: i) {
                    timeSlotView.backgroundColor = .greenColor()
                } else {
                    timeSlotView.backgroundColor = .redColor()
                }
                
                for j in 0..<dataSource.numProposedMeetingTimes() {
                    let possibleMissedTimeSlotView = timeSlotViews[j]
                    if (i>j && j>panStartIndx) || (i<j && j<panStartIndx) {
                        if dataSource.availabilityForProposedMeetingTime(atIndex: j) != shouldChangeToAvailable {
                            delegate.didChangeAvailability(atIndex: j)
                            if dataSource.availabilityForProposedMeetingTime(atIndex: j) {
                                possibleMissedTimeSlotView.backgroundColor = .greenColor()
                            } else {
                                possibleMissedTimeSlotView.backgroundColor = .redColor()
                            }
                        }
                    }
                }
            }
        }
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    // Drawing code
    }
    */
    
}

protocol MeetingTimeProposalViewDataSource {
    func numProposedMeetingTimes() -> Int
    func timeForProposedMeetingTime(atIndex index:Int) -> NSDate
    func availabilityForProposedMeetingTime(atIndex index:Int) -> Bool
    func durationForProposedMeetingTime(atIndex index:Int) -> Double
}

protocol MeetingTimeProposalViewDelegate {
    func didChangeAvailability(atIndex index:Int)
}


//
//  MeetingTimeResponderView.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 4/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//
//
//  MeetingTimeResponderView.swift
//  MeetingScheduler_iOS
//
//  Created by Nicholas Garfield on 22/12/15.
//  Copyright © 2015 Nicholas Garfield. All rights reserved.
//

import UIKit


private let kHOUR_SPACING:CGFloat       = 60.0
private let k10_MINUTE_SPACING:CGFloat  = 60.0/6.0

class MeetingTimeResponderView: UIView {
    
    private var timeSlotViews:[UIView]  = []
    private var hourLabels:[UILabel]    = []
    var proposalIndex:Int               = 0
    
    
    @IBOutlet var selectionIndicatorView:UIView!
    
    var dataSource:MeetingTimeResponderViewDataSource?
    var delegate:MeetingTimeResponderViewDelegate?
    
    func reload() {
        configureSelectionIndicatorView()
        
        guard let dataSource    = self.dataSource else { return }
        let calendar            = NSCalendar.currentCalendar()
        
        for view in timeSlotViews {
            view.removeFromSuperview()
        }
        timeSlotViews.removeAll()
        
        for hourLabel in hourLabels {
            hourLabel.removeFromSuperview()
        }
        hourLabels.removeAll()
        
        for i in 0..<dataSource.numProposedMeetingTimes(proposalIndex) {
            let timeSlotView = UIView()
            addSubview(timeSlotView)

            if dataSource.availabilityForProposedMeetingTime(atIndex: i, proposalIndex: proposalIndex) {
                timeSlotView.backgroundColor = .greenColor()
            } else {
                timeSlotView.backgroundColor = .redColor()
            }
            let heightFactor = (dataSource.durationForProposedMeetingTime(atIndex: i, proposalIndex: proposalIndex)/60.0)
            timeSlotView.heightAnchor.constraintEqualToConstant(kHOUR_SPACING * CGFloat(heightFactor)).active = true
            timeSlotView.topAnchor.constraintEqualToAnchor(topAnchor, constant: CGFloat(i)*(kHOUR_SPACING * CGFloat(heightFactor))).active = true
            timeSlotView.translatesAutoresizingMaskIntoConstraints                      = false
            timeSlotView.widthAnchor.constraintEqualToAnchor(widthAnchor).active        = true
            timeSlotView.centerXAnchor.constraintEqualToAnchor(centerXAnchor).active    = true
            timeSlotViews.append(timeSlotView)
            sendSubviewToBack(timeSlotView)

            // Add time label
            if i%2 == 1 {
                let propTime    = dataSource.timeForProposedMeetingTime(atIndex: i, proposalIndex: proposalIndex)
                let components  = calendar.components([.Hour, .Minute], fromDate: propTime)
//                let kNUM_SECONDS_IN_12_HOURS = 43200
//                let components  = calendar.componentsInTimeZone(NSTimeZone(forSecondsFromGMT: kNUM_SECONDS_IN_12_HOURS), fromDate: propTime)
                let hour        = components.hour
                let minutes     = components.minute
                let hourLabel   = UILabel()
                addSubview(hourLabel)
                hourLabel.textAlignment = .Center
                hourLabel.textColor     = .whiteColor()
                hourLabel.text          =  String(format: "%d:%02d", hour, minutes)
                hourLabel.sizeToFit()
                hourLabel.translatesAutoresizingMaskIntoConstraints                     = false
                hourLabel.widthAnchor.constraintEqualToAnchor(widthAnchor).active       = true
                hourLabel.centerXAnchor.constraintEqualToAnchor(centerXAnchor).active   = true
                hourLabel.topAnchor.constraintEqualToAnchor(topAnchor, constant: (kHOUR_SPACING/2) + (CGFloat((i-1)/2)*kHOUR_SPACING) - hourLabel.bounds.height/2.0).active = true
                hourLabels.append(hourLabel)
            }
            
            if i == dataSource.numProposedMeetingTimes(proposalIndex)-1 {
                bottomAnchor.constraintEqualToAnchor(timeSlotView.bottomAnchor, constant: 0).active = true
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    

    private func configureSelectionIndicatorView() {
        if selectionIndicatorView == nil {
            let kSPACING_IN_CENTER:CGFloat                  = 30.0
            let kSELECTION_INDICATOR_VIEW_HEIGHT:CGFloat    = 1.5
            
            selectionIndicatorView          = UIView(frame: CGRectMake(0, 0, bounds.width, kSELECTION_INDICATOR_VIEW_HEIGHT))
            selectionIndicatorView.translatesAutoresizingMaskIntoConstraints                     = false
            selectionIndicatorView.heightAnchor.constraintEqualToConstant(kSELECTION_INDICATOR_VIEW_HEIGHT).active = true
            
            let leftIndicator               = UIView()
            leftIndicator.backgroundColor   = .whiteColor()
            selectionIndicatorView.addSubview(leftIndicator)
            leftIndicator.translatesAutoresizingMaskIntoConstraints = false
            leftIndicator.heightAnchor.constraintEqualToAnchor(selectionIndicatorView.heightAnchor).active = true
            leftIndicator.widthAnchor.constraintEqualToAnchor(selectionIndicatorView.widthAnchor, multiplier: 0.5, constant: -kSPACING_IN_CENTER).active = true
            leftIndicator.topAnchor.constraintEqualToAnchor(selectionIndicatorView.topAnchor).active = true
            leftIndicator.leadingAnchor.constraintEqualToAnchor(selectionIndicatorView.leadingAnchor).active = true
            
            let rightIndicator = UIView()
            rightIndicator.backgroundColor = .whiteColor()
            selectionIndicatorView.addSubview(rightIndicator)
            rightIndicator.translatesAutoresizingMaskIntoConstraints = false
            rightIndicator.heightAnchor.constraintEqualToAnchor(selectionIndicatorView.heightAnchor).active = true
            rightIndicator.widthAnchor.constraintEqualToAnchor(selectionIndicatorView.widthAnchor, multiplier: 0.5, constant: -kSPACING_IN_CENTER).active = true
            rightIndicator.topAnchor.constraintEqualToAnchor(selectionIndicatorView.topAnchor).active = true
            rightIndicator.trailingAnchor.constraintEqualToAnchor(selectionIndicatorView.trailingAnchor).active = true
        }
    }
    
    func selectTimeAtLocation(loc:CGPoint) {
        guard let dataSource = dataSource else { return }
        for i in 0..<dataSource.numProposedMeetingTimes(proposalIndex) {
            let timeSlotView = timeSlotViews[i]

            if CGRectContainsPoint(timeSlotView.frame, loc) {
                delegate?.didSelectTime(forProposal: proposalIndex, atIndex: i)
            }
            
            let isSelected = dataSource.isSelectedMeetingTime(atIndex: i, proposalIndex: proposalIndex)
            if isSelected {
                selectionIndicatorView.removeFromSuperview()
                timeSlotView.addSubview(selectionIndicatorView)
                selectionIndicatorView.topAnchor.constraintEqualToAnchor(timeSlotView.topAnchor).active = true
                selectionIndicatorView.leadingAnchor.constraintEqualToAnchor(timeSlotView.leadingAnchor).active = true
                selectionIndicatorView.widthAnchor.constraintEqualToAnchor(timeSlotView.widthAnchor).active = true
            }
        }
    }
    
//    func panAtLocation(loc:CGPoint) {
//        guard let dataSource    = dataSource    else { return }
//        for i in 0..<dataSource.numProposedMeetingTimes(proposalIndex) {
//            let timeSlotView = timeSlotViews[i]
//            
//            if CGRectContainsPoint(timeSlotView.frame, loc) {
//                delegate?.didSelectTime(forProposal: proposalIndex, atIndex: i)
//            }
//            
//            let isSelected = dataSource.isSelectedMeetingTime(atIndex: i, proposalIndex: proposalIndex)
//            if isSelected {
//                selectionIndicatorView.removeFromSuperview()
//                timeSlotView.addSubview(selectionIndicatorView)
//                selectionIndicatorView.topAnchor.constraintEqualToAnchor(timeSlotView.topAnchor).active         = true
//                selectionIndicatorView.leadingAnchor.constraintEqualToAnchor(timeSlotView.leadingAnchor).active = true
//                selectionIndicatorView.widthAnchor.constraintEqualToAnchor(timeSlotView.widthAnchor).active     = true
//            }
//        }
//    }
}


protocol MeetingTimeResponderViewDataSource {
    func numProposedMeetingTimes(proposalIndex:Int) -> Int
    func timeForProposedMeetingTime(atIndex index:Int, proposalIndex:Int) -> NSDate
    func availabilityForProposedMeetingTime(atIndex index:Int, proposalIndex:Int) -> Bool
    func durationForProposedMeetingTime(atIndex index:Int, proposalIndex:Int) -> Double
    func isSelectedMeetingTime(atIndex index:Int, proposalIndex:Int) -> Bool
}

protocol MeetingTimeResponderViewDelegate {
    func didSelectTime(forProposal proposal:Int, atIndex index:Int)
}
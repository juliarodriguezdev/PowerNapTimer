//
//  MyTimer.swift
//  PowerNapTimer
//
//  Created by julia rodriguez on 6/18/19.
//  Copyright © 2019 julia rodriguez. All rights reserved.
//

import UIKit

// 1:
protocol MyTimerDelegate: class {
    
    func timerStopped()
    func timerSecondTicked()
    func timerCompleted()
}

class MyTimer: NSObject {
    
    // How many seconds are remaining on our nap?
    var timeRemaining: TimeInterval?
    
    // The timer object we are hiding behind our wrapper (MyTimer)
    var timer: Timer?
    
    // 2: Create var delegate of Protocol class, lives on object class
    weak var delegate: MyTimerDelegate?
    
    var isOn: Bool {
        if timeRemaining != nil {
            return true
        } else {
            return false
        }
    }
    
   private func secondTicked() {
        guard let timeReamining = timeRemaining else { return }
        if timeReamining > 0 {
            self.timeRemaining = timeReamining - 1
            // Tell the delegate the second ticked, to update its labels
            delegate?.timerSecondTicked()
            print(timeReamining)
        } else {
            timer?.invalidate()
            self.timeRemaining = nil
            // Tell the delegate the timer completed
            delegate?.timerCompleted()
        }
    }
    func startTimer(_ time: TimeInterval) {
        if isOn == false {
            self.timeRemaining = time
            
            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (_) in
                self.secondTicked()
            })
        }
        
    }
    func stopTimer() {
        // if isOn == true (default)
        if isOn {
            self.timeRemaining = nil
            timer?.invalidate()
            // Tell the delegate the timer stopped
            delegate?.timerStopped()
        }
        
    }
}

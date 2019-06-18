//
//  ViewController.swift
//  PowerNapTimer
//
//  Created by julia rodriguez on 6/18/19.
//  Copyright © 2019 julia rodriguez. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var napButton: UIButton!
    
    let timer = MyTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //4 assign self as delegate
        timer.delegate = self
    
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        if timer.isOn {
            timer.stopTimer()
        } else {
            timer.startTimer(5)
        }
        updateLabel()
        updateButton()
    }
    
    func updateLabel() {
        if timer.isOn {
            timerLabel.text = "\(timer.timeRemaining)"
        } else {
            timerLabel.text = "20:00"
        }
    }
    func updateButton() {
        if timer.isOn {
            napButton.setTitle("Cancel Nap", for: .normal)
        } else {
            napButton.setTitle("Start Nap", for: .normal)
        }
    }
    
}
// 3 conform to delegate
extension ViewController: MyTimerDelegate {
    
    func timerStopped() {
        updateButton()
        updateLabel()
    }
    func timerCompleted() {
        updateLabel()
        updateButton()
        // Call the display alert controller func
    }
    
    func timerSecondTicked() {
        updateLabel()
    }
    
}

extension ViewController {
    func displaySnoozeAlertController () {
        
    }
    
}


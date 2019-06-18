//
//  ViewController.swift
//  PowerNapTimer
//
//  Created by julia rodriguez on 6/18/19.
//  Copyright © 2019 julia rodriguez. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController {
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var napButton: UIButton!
    
    let timer = MyTimer()
    
    // the Unique identifier for our notification
    // Identifier for the NotificationRequest
    fileprivate let userNotificationIdentifier = "timerFinishedNotification"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //4 assign self as delegate
        timer.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        if timer.isOn {
            timer.stopTimer()
            cancelLocalNotification()
        } else {
            timer.startTimer(5)
            scheduleLocalNotification()
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
    func updateTimer() {
        // Get all notifications for our current app form the Notification Center
        UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
            
            // Filtering out all notifications that do not have (match) our identifier form our constant
            // $0 = iterate && compare starting at index[0], append the one that == to array
            let ourNotification = requests.filter { $0.identifier == self.userNotificationIdentifier}
            
            // Get our notification from the array, which should have either 1 or 0 elements inside this array
            guard let timerNotificationRequest = ourNotification.last,
                
            // Get the trigger from that request, and cast is as our UNCalenderTrigger
            // as? = type casting as class
            let trigger = timerNotificationRequest.trigger as? UNCalendarNotificationTrigger,
                // Then we get the exact date in which the trigger should fire
                // This iwll give us the exact nanosecond to when the notification was triggered
            let fireDate = trigger.nextTriggerDate() else { return }
            
            // Turn off our timer incase one is still running
            self.timer.stopTimer()
            
            // Turn on the timer and have it correspond to the amount of time between NOW and the next trigger date of the trigger (fireDate)
            self.timer.startTimer(fireDate.timeIntervalSinceNow)
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
        displaySnoozeAlertController()
    }
    
    func timerSecondTicked() {
        updateLabel()
    }
    
}

extension ViewController {
    func displaySnoozeAlertController () {
        let alertController = UIAlertController(title: "Time to wake up!", message: "Go learn to code!", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Snooze for how many minutes?"
            textField.keyboardType = .numberPad
        }
        let snoozeAction = UIAlertAction(title: "Snooze", style: .default) {
            (_) in
            guard let timeText = alertController.textFields?.first?.text,
                let time = TimeInterval(timeText) else { return }
            
            self.timer.startTimer(time*60)
            self.scheduleLocalNotification()
            self.updateLabel()
            self.updateButton()
            
        }
        alertController.addAction(snoozeAction)
        
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        
        alertController.addAction(dismissAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
}

extension ViewController {
    func scheduleLocalNotification() {
        // Create the content for the notification; text, sound, badge#
        let notificationContent = UNMutableNotificationContent()
        // Set the features of the Notificatin Content based on what you asked the user permission for
        notificationContent.title = "Wake Up!"
        notificationContent.subtitle = "Your alarm has executed"
        notificationContent.badge = 1
        notificationContent.sound = .default
        
        // Set up when the Notification should fire
        guard let timeRemaining = timer.timeRemaining else { return }
        // Get the exact current date, then add however many seconds the timer has remaining to find the "fireDate"
        let date = Date(timeInterval: timeRemaining, since: Date())
        
        // Get the Date components from the fire date (Specifically the minutes and seconds)
        let dateComponents = Calendar.current.dateComponents([.minute, .second], from: date)
        
        // Create a trigger for when the notification should fire (send to the user)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // Create the rquest, for this notification by passin in our identifier constanct, the content and the trigger we created above
        let request = UNNotificationRequest(identifier: userNotificationIdentifier, content: notificationContent, trigger: trigger)
        
        // Add that request to the phones notification center
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }

    }
    func cancelLocalNotification() {
        // Removing our notification from the notification center by canceling the request by that notification's identifier
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [userNotificationIdentifier])
    }

}

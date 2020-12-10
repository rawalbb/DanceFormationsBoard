//
//  KeyboardViewController.swift
//  DanceFormationsBoard
//
//  Created by Bansri Rawal on 12/8/20.
//

import Foundation
import UIKit

class KeyboardViewController: UIViewController {

    @IBOutlet weak var backgroundSV: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeToNotification(UIResponder.keyboardWillShowNotification, selector: #selector(keyboardWillShowOrHide))
        subscribeToNotification(UIResponder.keyboardWillHideNotification, selector: #selector(keyboardWillShowOrHide))
        initializeHideKeyboard()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }
}
// MARK : Keyboard Dismissal Handling on Tap
private extension KeyboardViewController {
    func initializeHideKeyboard(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissMyKeyboard))
        view.addGestureRecognizer(tap)
    }
    @objc func dismissMyKeyboard(){
        view.endEditing(true)
    }
}
// MARK : Textfield Visibility Handling with Scroll
private extension KeyboardViewController {
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    @objc func keyboardWillShowOrHide(notification: NSNotification) {
        // Pull a bunch of info out of the notification
        if let scrollView = backgroundSV, let userInfo = notification.userInfo, let endValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey], let durationValue = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey], let curveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] {
            // Transform the keyboard's frame into our view's coordinate system
            let endRect = view.convert((endValue as AnyObject).cgRectValue, from: view.window)
            // Find out how much the keyboard overlaps the scroll view
            // We can do this because our scroll view's frame is already in our view's coordinate system
            let keyboardOverlap = scrollView.frame.maxY - endRect.origin.y
            // Set the scroll view's content inset to avoid the keyboard
            // Don't forget the scroll indicator too!
            scrollView.contentInset.bottom = keyboardOverlap
            scrollView.scrollIndicatorInsets.bottom = keyboardOverlap
            let duration = (durationValue as AnyObject).doubleValue
            let options = UIView.AnimationOptions(rawValue: UInt((curveValue as AnyObject).integerValue << 16))
            UIView.animate(withDuration: duration!, delay: 0, options: options, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
}


class KeyViewController: UIViewController {

    @IBOutlet weak var backgroundSV: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeToNotification(UIResponder.keyboardWillShowNotification, selector: #selector(keyboardWillShowOrHide))
        subscribeToNotification(UIResponder.keyboardWillHideNotification, selector: #selector(keyboardWillShowOrHide))
        //initializeHideKeyboard()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }
}
// MARK : Keyboard Dismissal Handling on Tap
private extension KeyViewController {
    func initializeHideKeyboard(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissMyKeyboard))
        view.addGestureRecognizer(tap)
    }
    @objc func dismissMyKeyboard(){
        view.endEditing(true)
    }
}
// MARK : Textfield Visibility Handling with Scroll
private extension KeyViewController {
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    @objc func keyboardWillShowOrHide(notification: NSNotification) {
        // Pull a bunch of info out of the notification
        if let tableView = backgroundSV, let userInfo = notification.userInfo, let endValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey], let durationValue = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey], let curveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] {
            // Transform the keyboard's frame into our view's coordinate system
            let endRect = view.convert((endValue as AnyObject).cgRectValue, from: view.window)
            // Find out how much the keyboard overlaps the scroll view
            // We can do this because our scroll view's frame is already in our view's coordinate system
            let keyboardOverlap = tableView.frame.maxY - endRect.origin.y
            // Set the scroll view's content inset to avoid the keyboard
            // Don't forget the scroll indicator too!
            tableView.contentInset.bottom = keyboardOverlap
            tableView.scrollIndicatorInsets.bottom = keyboardOverlap
            let duration = (durationValue as AnyObject).doubleValue
            let options = UIView.AnimationOptions(rawValue: UInt((curveValue as AnyObject).integerValue << 16))
            UIView.animate(withDuration: duration!, delay: 0, options: options, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
}




class KeyUIViewController: UIViewController {

    @IBOutlet weak var backgroundSV: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeToNotification(UIResponder.keyboardWillShowNotification, selector: #selector(keyboardWillShowOrHide))
        subscribeToNotification(UIResponder.keyboardWillHideNotification, selector: #selector(keyboardWillShowOrHide))
        //initializeHideKeyboard()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }
}
// MARK : Keyboard Dismissal Handling on Tap
private extension KeyUIViewController {
    func initializeHideKeyboard(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissMyKeyboard))
        view.addGestureRecognizer(tap)
    }
    @objc func dismissMyKeyboard(){
        view.endEditing(true)
    }
}
// MARK : Textfield Visibility Handling with Scroll
private extension KeyUIViewController {
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    @objc func keyboardWillShowOrHide(notification: NSNotification) {
        // Pull a bunch of info out of the notification

        if let view = backgroundSV, let userInfo = notification.userInfo, let endValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey], let durationValue = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey], let curveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] {
            // Transform the keyboard's frame into our view's coordinate system
            _ = view.convert((endValue as AnyObject).cgRectValue, from: view.window)
            // Find out how much the keyboard overlaps the scroll view
            // We can do this because our scroll view's frame is already in our view's coordinate system
            
            if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                    let keyboardRectangle = keyboardFrame.cgRectValue
                    let keyboardHeight = keyboardRectangle.height
                
                view.frame.origin.y = -(view.frame.maxY - keyboardHeight)
                
                
            }
            else{
                view.frame.origin.y = 0
            }
            
            // Set the scroll view's content inset to avoid the keyboard
            // Don't forget the scroll indicator too!
            
           
            //view.largeContentImageInsets.bottom = keyboardOverlap
           // tableView.scrollIndicatorInsets.bottom = keyboardOverlap
            let duration = (durationValue as AnyObject).doubleValue
            let options = UIView.AnimationOptions(rawValue: UInt((curveValue as AnyObject).integerValue << 16))
            UIView.animate(withDuration: duration!, delay: 0, options: options, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
        
    }
}

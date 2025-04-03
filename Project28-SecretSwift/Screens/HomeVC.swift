//  File: HomeVC.swift
//  Project: Project28-SecretSwift
//  Created by: Noah Pope on 4/2/25.

import UIKit
import LocalAuthentication

class HomeVC: UIViewController
{
    @IBOutlet var secret: UITextView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setUpNavigation()
        setUpApplicationNotifications()
        setUpKeyboardNotifications()
    }
    
    
    func setUpNavigation()
    {
        title = SecretKeys.secretTitle
    }
    
    
    @IBAction func authenticateTapped(_ sender: Any)
    {
        let ctx = LAContext()
        var error: NSError?
        
        /** if you can evaluate the policy as true (here's a pointer to my error var btw, you viejo Obj-C remnant) ...
         then evalueate the policy with the OG NSError you set up who's value should now be filled via mem address
         after '.canEvalPolicy' returned its Bool*/
        
        if ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            evaluatePolicy(inContext: ctx, error: error)
        } else {
            /** handle error */
        }
    }
    
    
    func evaluatePolicy(inContext ctx: LAContext, error: NSError?)
    {
        let reason = "Identify yourself!"
        
        ctx.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, authenticationError in
            DispatchQueue.main.async {
                if success { self?.unlockSecretMessage() }
                else { /** handle error */ }
            }
        }
    }
    
    
    func unlockSecretMessage()
    {
        secret.isHidden = false
        title           = "Secret stuff!"
        
        secret.text     = KeychainWrapper.standard.string(forKey: SecretKeys.secretMessage) ?? ""
    }
    
    
    @objc func saveSecretMessage()
    {
        guard secret.isHidden == false else { return }
        
        KeychainWrapper.standard.set(secret.text, forKey: SecretKeys.secretMessage)
        secret.resignFirstResponder()
        secret.isHidden = true
        title           = SecretKeys.secretTitle
    }
    
    //-------------------------------------//
    // MARK: APPLICATION NOTIFICATION METHODS
    
    func setUpApplicationNotifications()
    {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(saveSecretMessage),
                                       name: UIApplication.willResignActiveNotification,
                                       object: nil)
    }
    
    //-------------------------------------//
    // MARK: KEYBOARD NOTIFICATION METHODS
    
    func setUpKeyboardNotifications()
    {
        let notificationCenter  = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(adjustForKeyboard),
                                       name: UIResponder.keyboardWillHideNotification,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(adjustForKeyboard),
                                       name: UIResponder.keyboardWillChangeFrameNotification,
                                       object: nil)
    }
    
    
    @objc func adjustForKeyboard(notification: Notification)
    {
        guard let keyboardValue         = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        else { return }
        let keyboardScreenEndFrame      = keyboardValue.cgRectValue
        let keyboardViewEndFrame        = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification { secret.contentInset = .zero }
        else {
            secret.contentInset = UIEdgeInsets(top: 0,
                                               left: 0,
                                               bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom,
                                               right: 0)
        }
        
        secret.scrollIndicatorInsets    = secret.contentInset
        
        let selectedRange               = secret.selectedRange
        secret.scrollRangeToVisible(selectedRange)
    }
}

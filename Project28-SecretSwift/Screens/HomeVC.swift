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
    
    
    func setUpNavigation() { title = SecretKeys.secretTitle }
    
    
    @IBAction func authenticateTapped(_ sender: Any)
    {
        let ctx = LAContext()
        var error: NSError?
        
        /** if you can evaluate the policy as true (here's a pointer to my error var btw, you viejo Obj-C remnant) ...
         then evalueate the policy with the OG NSError you set up who's value should now be filled via mem address
         after '.canEvalPolicy' returned its Bool*/
        
        if ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) { evaluatePolicy(ctx: ctx) }
        else { handleNoBiometryError() }
    }
    
    
    func evaluatePolicy(ctx: LAContext)
    {
        let reason = SecretKeys.touchIDReason
        
        ctx.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, authenticationError in
            DispatchQueue.main.async {
                if success { self?.unlockSecretMessage() }
                else { self?.handleAuthenticationError() }
            }
        }
    }
    
    
    func unlockSecretMessage()
    {
        secret.isHidden = false
        title           = "Secret stuff!"
        
        secret.text     = KeychainWrapper.standard.string(forKey: SecretKeys.secretMessage) ?? ""
    }
    
    //-------------------------------------//
    // MARK: ERROR HANDLING
    
    func handleNoBiometryError()
    {
        let msg     = "Your device is not configured for biometric authentication"
        let action1 = UIAlertAction(title: "OK", style: .default)
        
        let ac      = UIAlertController(title: "Biometry unavailable", message: msg, preferredStyle: .alert)
        ac.addAction(action1)
        self.present(ac, animated: true)
    }
    
    
    func handleAuthenticationError()
    {
        let msg     = "You could not be verified; please try again."
        let action1 = UIAlertAction(title: "OK", style: .default)
        
        let ac      = UIAlertController(title: "Authentication failed", message: msg, preferredStyle: .alert)
        ac.addAction(action1)
        self.present(ac, animated: true)
    }
    
    //-------------------------------------//
    // MARK: SAVE & LOAD
    
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

//  File: HomeVC.swift
//  Project: Project28-SecretSwift
//  Created by: Noah Pope on 4/2/25.

import UIKit
import LocalAuthentication



class HomeVC: UIViewController
{
    @IBOutlet var secret: UITextView!
    #warning("change back to false : true")
    var isFirstLoad = KeychainWrapper.standard.string(forKey: SecretKeys.password) != nil ? true : true
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        applyNavigationMask()
        setUpApplicationNotifications()
        setUpKeyboardNotifications()
        isFirstLoad ? setPassword() : enterPassword()
    }
    
    
    func setPassword()
    {
        let ac                          = UIAlertController(title: "Set Password",
                                                            message: "Set password",
                                                            preferredStyle: .alert)
        for _ in 0 ... 1 { ac.addTextField() }
        for i in 0 ... 1 { ac.textFields?[i].isSecureTextEntry = true
        }
        ac.textFields?[0].placeholder   = "Set your password"
        ac.textFields?[1].placeholder   = "Confirm your password"
        
        let action1 = UIAlertAction(title: "Confirm", style: .default) { [weak self] _ in
            // present reasons b4 each guard's return
            guard let pwd   = ac.textFields?[0].text else { self?.presentErrorMessage(errorType: .emptyPwdField); return }
            guard let cPwd  = ac.textFields?[1].text else { self?.presentErrorMessage(errorType: .emptyCPwdField); return }
            if pwd == cPwd {
                KeychainWrapper.standard.set(pwd, forKey: SecretKeys.password)
                self?.isFirstLoad       = false
                self?.unlockSecretMessage()
            }
        }
        
        ac.addAction(action1)
        present(ac, animated: true)
    }
    
    
    func enterPassword()
    {
        let ac                              = UIAlertController(title: "Enter password",
                                                            message: "Enter your secure password",
                                                            preferredStyle: .alert)
        ac.addTextField()
        ac.textFields?[0].isSecureTextEntry = true
        ac.textFields?[0].placeholder       = "Enter your password"
        let action1                         = UIAlertAction(title: "Done", style: .default) { [weak self] _ in
            guard let pwd = ac.textFields?[0].text
            else { self?.presentErrorMessage(errorType: .blankPostSet); return }
            
            guard pwd == KeychainWrapper.standard.string(forKey: SecretKeys.password)
            else { self?.presentErrorMessage(errorType: .incorrectPassword) ; return }
            
            self?.unlockSecretMessage()
            
        }
        
        ac.addAction(action1)
        present(ac, animated: true)
    }
    
    
    @IBAction func authenticateTapped(_ sender: Any)
    {
        let ctx = LAContext()
        var error: NSError?
        
        /**
         if you can evaluate the policy as true (here's a pointer to my error var btw, you viejo Obj-C remnant) ...
         then evalueate the policy with the OG NSError you set up who's value should now be filled via mem address
         after '.canEvalPolicy' returned its Bool
         */
        
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
        removeNavigationMask()
        secret.text     = KeychainWrapper.standard.string(forKey: SecretKeys.secretMessage) ?? ""
    }
    
    
    @objc func doneTapped()
    {
        saveSecretMessage()
        applyNavigationMask()
    }
    
    //-------------------------------------//
    // MARK: NAVIGATION MASKING & UNMASKING
    
    func applyNavigationMask()
    {
        title = SecretKeys.maskedTitle
        self.navigationItem.rightBarButtonItem = nil
    }
    
    
    func removeNavigationMask()
    {
        title = SecretKeys.unmaskedTitle
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done",
                                                                 style: .done,
                                                                 target: self,
                                                                 action: #selector(doneTapped))
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
    
    
    func presentErrorMessage(errorType: ErrorTypes)
    {
        switch errorType {
        case .mismatchedPassword:
            presentSSAlertOnMainThread(title: "Mismatch Detected", msg: SSError.mismatchOnCreation.rawValue)
        case .emptyPwdField:
            presentSSAlertOnMainThread(title: "Balnk field detected", msg: SSError.emptyPwdOnCreation.rawValue)
        case .emptyCPwdField:
            presentSSAlertOnMainThread(title: "Blank field detected", msg: SSError.emptyCPwdOnCreation.rawValue)
        case .blankPostSet:
            presentSSAlertOnMainThread(title: "No password entered", msg: SSError.blankPostCreation.rawValue)
        case .incorrectPassword:
            presentSSAlertOnMainThread(title: "Incorrect password", msg: SSError.incorrectPostCreation.rawValue)
        }
    }
    
    //-------------------------------------//
    // MARK: SAVE & LOAD
    
    @objc func saveSecretMessage()
    {
        guard secret.isHidden == false else { return }
        
        KeychainWrapper.standard.set(secret.text, forKey: SecretKeys.secretMessage)
        secret.resignFirstResponder()
        secret.isHidden = true
        title           = SecretKeys.maskedTitle
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
        
        /** secret.scrollIndicatorInsets    = secret.contentInset  (deprecated) */
        secret.horizontalScrollIndicatorInsets  = secret.contentInset
        secret.verticalScrollIndicatorInsets    = secret.contentInset
        
        let selectedRange               = secret.selectedRange
        secret.scrollRangeToVisible(selectedRange)
    }
}

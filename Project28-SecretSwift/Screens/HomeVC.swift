//  File: HomeVC.swift
//  Project: Project28-SecretSwift
//  Created by: Noah Pope on 4/2/25.

import UIKit
import LocalAuthentication

class HomeVC: UIViewController
{
    @IBOutlet var authButton: UIButton!
    @IBOutlet var secret: UITextView!
    var isFirstLoad = KeychainWrapper.standard.string(forKey: SecretKeys.password) != nil ? false : true
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        applyMaskAndSave()
        setUpApplicationNotifications()
        setUpKeyboardNotifications()
        hideAuthButton()
    }
    
    /**
     revealing password alert in viewDidLoad caused soft error regarding detached VC
     presenting the alert after the view appears solved the issue
     */
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        isFirstLoad ? setPassword() : revealAuthButton()
    }
    
    func setPassword()
    {
        let ac                          = UIAlertController(title: "Set Password",
                                                            message: "Set password",
                                                            preferredStyle: .alert)
        for _ in 0 ... 1 { ac.addTextField() }
        for i in 0 ... 1 { ac.textFields?[i].isSecureTextEntry = true }
        ac.textFields?[0].placeholder   = "Set your password"
        ac.textFields?[1].placeholder   = "Confirm your password"
        
        let action1 = UIAlertAction(title: "Confirm", style: .default) { [weak self] _ in
            // present reasons b4 each guard's return
            guard let pwd       = ac.textFields?[0].text
            else { self?.presentSSAlertOnMainThread(errorType: .emptyPwdField); return }
            
            guard let cPwd      = ac.textFields?[1].text
            else { self?.presentSSAlertOnMainThread(errorType: .emptyCPwdField); return }
            
            guard pwd == cPwd
            else { self?.presentSSAlertOnMainThread(errorType: .mismatchedPassword); return }
            
            KeychainWrapper.standard.set(pwd, forKey: SecretKeys.password)
            self?.isFirstLoad   = false
            self?.revealAuthButton()
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
            else { self?.presentSSAlertOnMainThread(errorType: .blankPwdPostSet); return }
            
            guard pwd == KeychainWrapper.standard.string(forKey: SecretKeys.password)
            else { self?.presentSSAlertOnMainThread(errorType: .incorrectPassword); return }
            
            self?.removeMaskAndUnlock()
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
        else { presentSSAlertOnMainThread(errorType: .noBiometry) }
    }
    
    
    func evaluatePolicy(ctx: LAContext)
    {
        let reason = SecretKeys.touchIDReason
        
        ctx.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, authenticationError in
            DispatchQueue.main.async {
                if success { self?.removeMaskAndUnlock() }
                else { self?.presentSSAlertOnMainThread(errorType: .authFail) }
            }
        }
    }
    
    
    @objc func doneTapped() { applyMaskAndSave() }
    
    //-------------------------------------//
    // MARK: SAVE & LOAD METHODS - KEYCHAIN
    
    @objc func saveSecretMessage()
    {
        guard secret.isHidden == false else { return }
        KeychainWrapper.standard.set(secret.text, forKey: SecretKeys.secretMessage)
    }
    
    //-------------------------------------//
    // MARK: NAVIGATION MASKING & UNMASKING METHODS
    
    func hideAuthButton() { authButton.isHidden = true }
    
    
    func revealAuthButton() { authButton.isHidden = false }
    
    
    @objc func applyMaskAndSave()
    {
        self.navigationItem
            .rightBarButtonItem = nil
        
        if secret.isHidden == false { secret.resignFirstResponder(); saveSecretMessage() }
        
        title                   = SecretKeys.maskedTitle
        secret.isHidden         = true
    }
    
    
    func removeMaskAndUnlock()
    {
        secret.isHidden         = false
        self.navigationItem
            .rightBarButtonItem = UIBarButtonItem(title: "Done",
                                                  style: .done,
                                                  target: self,
                                                  action: #selector(doneTapped))
        
        title                   = SecretKeys.unmaskedTitle
        secret.text             = KeychainWrapper.standard.string(forKey: SecretKeys.secretMessage) ?? ""
    }
    
    //-------------------------------------//
    // MARK: APPLICATION NOTIFICATION METHODS
    
    func setUpApplicationNotifications()
    {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(applyMaskAndSave),
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
        
        let selectedRange                       = secret.selectedRange
        secret.scrollRangeToVisible(selectedRange)
    }
}

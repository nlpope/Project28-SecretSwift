//  File: HomeVC.swift
//  Project: Project28-SecretSwift
//  Created by: Noah Pope on 4/2/25.

import UIKit

class HomeVC: UIViewController
{
    @IBOutlet var secret: UITextView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setUpKeyboardNotifications()
    }
    
    
    func setUpKeyboardNotifications()
    {
        let notificationCenter  = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    
    @objc func adjustForKeyboard(notification: Notification)
    {
        guard let keyboardValue     = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        else { return }
    }
}

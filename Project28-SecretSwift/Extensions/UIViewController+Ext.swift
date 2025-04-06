//  File: UIViewController+Ext.swift
//  Project: Project28-SecretSwift
//  Created by: Noah Pope on 4/5/25.

import UIKit

extension UIViewController
{
    func presentSSAlertOnMainThread(title: String, msg: String)
    {
        DispatchQueue.main.async {
            let ac = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            
            self.present(ac, animated: true)
        }
    }
}

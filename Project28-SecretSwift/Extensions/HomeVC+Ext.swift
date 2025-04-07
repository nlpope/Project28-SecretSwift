//  File: HomeVC+Ext.swift
//  Project: Project28-SecretSwift
//  Created by: Noah Pope on 4/5/25.

import UIKit

extension HomeVC
{
    //-------------------------------------//
    // MARK: ERROR HANDLING
    
    func presentSSAlertOnMainThread(errorType: ErrorTypes)
    {
        switch errorType {
        case .mismatchedPassword:
            handle(.mismatchedPassword, title: "Entries do  not match", msg: SSError.mismatchOnCreation.rawValue)
        case .emptyPwdField:
            handle(.emptyPwdField, title: "Blank field detected", msg: SSError.emptyPwdOnCreation.rawValue)
        case .emptyCPwdField:
            handle(.emptyCPwdField, title: "Blank field detected", msg: SSError.emptyCPwdOnCreation.rawValue)
        case .blankPwdPostSet:
            handle(.blankPwdPostSet, title: "No password entered", msg: SSError.blankPwdPostSet.rawValue)
        case .incorrectPassword:
            handle(.incorrectPassword, title: "Incorrect password", msg: SSError.incorrectPostCreation.rawValue)
        case .noBiometry:
            handle(.noBiometry, title: "Biometry unavailable", msg: SSError.noBiometry.rawValue)
        case .authFail:
            handle(.authFail, title: "Could not authenticate", msg: SSError.authFail.rawValue)
        }
    }
    
    
    private func handle(_ err: ErrorTypes, title: String, msg: String)
    {
        DispatchQueue.main.async {
            let ac = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                if err == .mismatchedPassword || err == .emptyPwdField || err == .emptyCPwdField { self?.setPassword() }
                else if err == .blankPwdPostSet || err == .incorrectPassword { self?.enterPassword() }
                else if err == .noBiometry || err == .authFail { self?.enterPassword() }
            })
            
            self.present(ac, animated: true)
        }
    }
}

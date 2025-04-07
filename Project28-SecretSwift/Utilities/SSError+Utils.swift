//  File: SSErrorMessages+Utils.swift
//  Project: Project28-SecretSwift
//  Created by: Noah Pope on 4/5/25.

import Foundation

enum ErrorTypes
{
    case mismatchedPassword,
         emptyPwdField,
         emptyCPwdField,
         blankPwdPostSet,
         incorrectPassword,
         noBiometry,
         authenticationFailure
}

enum SSErrorMessages: String, Error
{
    case mismatchOnCreation     = "Your password and confirmed password do not match"
    case emptyPwdOnCreation     = "Set your password to continue"
    case emptyCPwdOnCreation    = "Confirm your password to continue"
    case incorrectPostCreation  = "The password entered is incorrect"
    case blankPwdPostSet        = "Enter your password to continue"
    
    case noBiometry             = "Your device is not configured for biometric authentication"
    case authenticationFailure  = "You could not be verified; please try again."
}

/**
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
 */

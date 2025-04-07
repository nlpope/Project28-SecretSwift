//  File: SSError+Utils.swift
//  Project: Project28-SecretSwift
//  Created by: Noah Pope on 4/5/25.

import Foundation

enum ErrorTypes
{
    case mismatchedPassword, emptyPwdField, emptyCPwdField, blankPwdPostSet, incorrectPassword,
         noBiometry, authFail
}

enum SSError: String, Error
{
    case mismatchOnCreation     = "Your password and confirmed password do not match"
    case emptyPwdOnCreation     = "Set your password to continue"
    case emptyCPwdOnCreation    = "Confirm your password to continue"
    case incorrectPostCreation  = "The password entered is incorrect"
    case blankPwdPostSet        = "Enter your password to continue"
    
    case noBiometry             = "Your device is not configured for biometric authentication"
    case authFail               = "You could not be verified; please try again."
}

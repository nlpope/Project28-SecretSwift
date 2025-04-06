//  File: SSError+Utils.swift
//  Project: Project28-SecretSwift
//  Created by: Noah Pope on 4/5/25.

import Foundation

enum ErrorTypes { case mismatchedPassword, emptyPwdField, emptyCPwdField, blankPostSet, incorrectPassword }

enum SSError: String, Error
{
    case mismatchOnCreation     = "Your password and confirmed password do not match"
    case emptyPwdOnCreation     = "Set your password to continue"
    case emptyCPwdOnCreation    = "Confirm your password to continue"
    
    case incorrectPostCreation  = "The password entered is incorrect"
    case blankPostCreation      = "Enter your password to continue"
}

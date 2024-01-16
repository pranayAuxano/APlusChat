//
//  Validations.swift
//  Shela
//
//  Created by Ankit on 27/12/18.
//  Copyright © 2018 ankit. All rights reserved.
//

import Foundation

class Validations
{
    static func isValid(email: String) -> Bool
    {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    static func isValidPhone(testStr:String) -> Bool
    {
        let phoneRegEx = "^[6-9]\\d{9}$"
        let phoneNumber = NSPredicate(format:"SELF MATCHES %@", phoneRegEx)
        return phoneNumber.evaluate(with: testStr)
    }
    
    static func isValidUserName(userName : String) -> Bool
    {
        if (userName).isEmpty
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    static func isEmpty(str : String) -> Bool
    {
        if (str).isEmpty
        {
            return true
        }
        else
        {
            return false
        }
    }
}

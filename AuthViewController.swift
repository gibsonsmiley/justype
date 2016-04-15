//
//  AuthViewController.swift
//  justype
//
//  Created by Gibson Smiley on 3/15/16.
//  Copyright © 2016 Gibson Smiley. All rights reserved.
//

import UIKit

class AuthViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var signupChoiceButton: UIButton!
    @IBOutlet weak var signupEmailTextField: UITextField!
    @IBOutlet weak var signupPasswordTextField: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    
    @IBOutlet weak var loginChoiceButton: UIButton!
    @IBOutlet weak var loginEmailTextField: UITextField!
    @IBOutlet weak var loginPasswordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet var toolbar: UIToolbar!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        signupEmailTextField.delegate = self
        signupPasswordTextField.delegate = self
        loginEmailTextField.delegate = self
        loginPasswordTextField.delegate = self
        
        signupEmailTextField.inputAccessoryView = toolbar
        signupPasswordTextField.inputAccessoryView = toolbar
        loginEmailTextField.inputAccessoryView = toolbar
        loginPasswordTextField.inputAccessoryView = toolbar
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("Memory warning on AuthView")
    }

    // MARK: - Buttons
    @IBAction func hideButtonTapped(sender: AnyObject) {
        signupEmailTextField.resignFirstResponder()
        signupPasswordTextField.resignFirstResponder()
        loginEmailTextField.resignFirstResponder()
        loginPasswordTextField.resignFirstResponder()
    }
    
    @IBAction func SignupChoiceButtonTapped(sender: AnyObject) {
        signupEmailTextField.hidden = false
        signupPasswordTextField.hidden = false
        signupButton.hidden = false
        signupChoiceButton.hidden = true
        loginChoiceButton.hidden = true
        cancelButton.hidden = false
    }
    
    @IBAction func signupButtonTapped(sender: AnyObject) {
        self.errorLabel.hidden = true
        signupEmailTextField.resignFirstResponder()
        signupPasswordTextField.resignFirstResponder()
        
        if signupEmailTextField.text?.isEmpty == true || signupPasswordTextField.text?.isEmpty == true {
            errorLabel.hidden = false
            errorLabel.text = "Both a valid email and password are required to sign up."
        } else if signupEmailTextField.text?.containsString("@") == false || signupEmailTextField.text?.containsString(".") == false {
            errorLabel.hidden = false
            errorLabel.text = "A valid email is required to sign up. 'example@example.com'"
        } else {
            UserController.createUser(signupEmailTextField.text!, password: signupPasswordTextField.text!, completion: { (success, user) -> Void in
                if success, let _ = user {
                    NSUserDefaults.standardUserDefaults().setBool(false, forKey: "firstTime")
                    NSNotificationCenter.defaultCenter().postNotificationName("userLoggedOut", object: nil, userInfo: nil)
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    self.errorLabel.hidden = false
                    self.errorLabel.text = "There was an error creating your account. Please try again."
                }
            })
        }
    }
    
    @IBAction func LoginChoiceButtonTapped(sender: AnyObject) {
        loginEmailTextField.hidden = false
        loginPasswordTextField.hidden = false
        loginButton.hidden = false
        signupChoiceButton.hidden = true
        loginChoiceButton.hidden = true
        cancelButton.hidden = false
    }
    
    @IBAction func loginButtonTapped(sender: AnyObject) {
        self.errorLabel.hidden = true
        loginPasswordTextField.resignFirstResponder()
        loginPasswordTextField.resignFirstResponder()
        
        UserController.authenticateUser(loginEmailTextField.text!, password: loginPasswordTextField.text!) { (success, user) -> Void in
            if success, let _ = user {
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: "firstTime")
                NSNotificationCenter.defaultCenter().postNotificationName("userLoggedOut", object: nil, userInfo: nil) // This and notification above might cause some problems.
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                self.errorLabel.text = "There was an error logging in. Please check to see if your email and password are correct and try again."
                self.errorLabel.hidden = false
            }
        }
    }

    @IBAction func cancelButtonTapped(sender: AnyObject) {
        if signupEmailTextField.hidden == false {
            signupEmailTextField.hidden = true
            signupPasswordTextField.hidden = true
            signupButton.hidden = true
            signupChoiceButton.hidden = false
            loginChoiceButton.hidden = false
            cancelButton.hidden = true
            errorLabel.hidden = true
            signupEmailTextField.resignFirstResponder()
            signupPasswordTextField.resignFirstResponder()
            signupEmailTextField.text = ""
            signupPasswordTextField.text = ""
        } else if loginEmailTextField.hidden == false {
            loginEmailTextField.hidden = true
            loginPasswordTextField.hidden = true
            loginButton.hidden = true
            signupChoiceButton.hidden = false
            loginChoiceButton.hidden = false
            cancelButton.hidden = true
            errorLabel.hidden = true
            loginEmailTextField.resignFirstResponder()
            loginPasswordTextField.resignFirstResponder()
            loginEmailTextField.text = ""
            loginPasswordTextField.text = ""
        }
    }
    
    @IBAction func userTappedView(sender: AnyObject) {
        loginEmailTextField.resignFirstResponder()
        loginPasswordTextField.resignFirstResponder()
        signupEmailTextField.resignFirstResponder()
        signupPasswordTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.signupEmailTextField {
            self.signupPasswordTextField.becomeFirstResponder()
        } else if textField == self.loginEmailTextField {
            self.loginPasswordTextField.becomeFirstResponder()
        } else if textField == self.signupPasswordTextField {
            signupButtonTapped(self)
            signupPasswordTextField.resignFirstResponder()
        } else if textField == self.loginPasswordTextField {
            loginButtonTapped(self)
            loginPasswordTextField.resignFirstResponder()
        }
        return true
    }
}

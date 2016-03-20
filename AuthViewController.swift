//
//  AuthViewController.swift
//  justype
//
//  Created by Gibson Smiley on 3/15/16.
//  Copyright © 2016 Gibson Smiley. All rights reserved.
//

import UIKit

class AuthViewController: UIViewController {
    
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
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    // MARK: - Buttons
    
    @IBAction func SignupChoiceButtonTapped(sender: AnyObject) {
        signupEmailTextField.hidden = false
        signupPasswordTextField.hidden = false
        signupButton.hidden = false
        signupChoiceButton.hidden = true
        loginChoiceButton.hidden = true
        cancelButton.hidden = false
    }
    
    @IBAction func signupButtonTapped(sender: AnyObject) {
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
        loginPasswordTextField.resignFirstResponder()
        loginPasswordTextField.resignFirstResponder()
        
        UserController.authenticateUser(loginEmailTextField.text!, password: loginPasswordTextField.text!) { (success, user) -> Void in
            if success, let _ = user {
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
        }
    }
    
    @IBAction func userTappedView(sender: AnyObject) {
        loginEmailTextField.resignFirstResponder()
        loginPasswordTextField.resignFirstResponder()
        signupEmailTextField.resignFirstResponder()
        signupPasswordTextField.resignFirstResponder()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

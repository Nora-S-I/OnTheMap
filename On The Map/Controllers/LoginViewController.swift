//
//  LoginViewController.swift
//  On The Map
//
//  Created by Norah Al Ibrahim on 1/11/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var udacityLogo: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        emailTextField.text = ""
        passwordTextField.text = ""
        
        //subscribe to notification center
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        activityIndicator.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //unsubscribe from notofication center
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func logInButton(_ sender: Any) {
        
        //notify the user to enter user name and password
        if emailTextField.text == "" || passwordTextField.text == "" {
            alert(title: "Notification", message: "Please enter your username and password")
            return
        }
        
        activityIndicator.isHidden = false
        loginButton.isEnabled = false
        
        API.shared.login(email: emailTextField.text!, password: passwordTextField.text!) {
            (accountKey: Int?, sessionId: String?, error: String?) in
            
            guard let accountKey = accountKey, let sessionId = sessionId else {
                DispatchQueue.main.async {
                    self.activityIndicator.isHidden = true
                    self.loginButton.isEnabled = true
                    self.alert(title: "Login Error", message: error!)
                }
                return
            }
            
            self.appDelegate.accountKey = accountKey
            self.appDelegate.sessionId = sessionId
            
            // get the previous location submission of the user, if any
            API.shared.getStudentLocation(accountKey, { (info, error) in
                guard error == nil, info != nil else {
                    return
                }
                self.appDelegate.currentStudentInformation = info
                
            })
            
            // get the user information so that we can use in the location submission process
            API.shared.getPublicUserData("\(accountKey)", { (error) in
                
            })
            
            DispatchQueue.main.async {
                self.activityIndicator.isHidden = true
                self.loginButton.isEnabled = true
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "onMap") as! UITabBarController
                self.present(viewController, animated: true)
            }
        }
    }
    
    @objc func keyboardWillAppear(_ notification: Notification) {
        view.frame.origin.y = -udacityLogo.frame.origin.y + 20
    }
    @objc func keyboardWillDisappear(_ notification: Notification) {
        view.frame.origin.y = 0
    }
}


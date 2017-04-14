
//
//  LoginViewController.swift
//  VideoSharing1
//
//  Created by 1 on 09.04.17.
//  Copyright © 2017 1. All rights reserved.
//

import UIKit
import SwiftValidator
import RealmSwift

let kFeedVideosStoryboardIdentifier = "FeedVideos"

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var usernameErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    let validator = Validator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LoginViewController.hideKeyboard)))
        
        if APIManager.isUserLoggedIn() {
            let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: kFeedVideosStoryboardIdentifier)
            self.navigationController?.pushViewController(nextViewController!, animated: false)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.toolbar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideKeyboard()
        usernameTextField.text = ""
        passwordTextField.text = ""
        navigationController?.toolbar.isHidden = false
    }
    
    @IBAction func loginPressed(_ sender: AnyObject) {
        validationSuccessful()
    }
    
    
    func validationSuccessful() {
        
        APIManager.loginUser(with: usernameTextField.text!, password: passwordTextField.text!) { (error, user) in
            if user != nil {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: kFeedVideosStoryboardIdentifier, sender: self)
                }
            } else {
                let alert = UIAlertController.init(title: "Login error", message: "Try again please", preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: nil))
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func hideKeyboard() {
        view.endEditing(true)
    }
}

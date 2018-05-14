//
//  LoginViewController.swift
//  GeoXplore
//
//  Created by Izabela Brzeczek on 09.04.2018.
//  Copyright © 2018 Izabela Brzeczek. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import NVActivityIndicatorView

class LoginViewController: UIViewController, NVActivityIndicatorViewable, UITextFieldDelegate {
    
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    private let activityIndicatorView =
        NVActivityIndicatorView(frame: UIScreen.main.bounds,
                                type: NVActivityIndicatorType.ballClipRotateMultiple, color: UIColor(red: 113.0/255.0, green: 195.0/255.0, blue: 139.0/255.0, alpha: 1.0))
    
    
    @IBAction func dissmissLoginView(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func loginButton(_ sender: UIButton) {
        dismissKeyboard()
        loginButtonPressed()
        showActivityIndicator()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        [self.loginTextField, self.passwordTextField].forEach {
            $0.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)}
        loginButtonConfiguration(isEnabled: false, alpha: 0.5)
        self.hideKeyboard()
        setupActivityIndicator()
    }
    
    private func setupActivityIndicator() {
        activityIndicatorView.backgroundColor = UIColor(red: 33.0/255.0, green: 19.0/255.0, blue: 40.0/255.0, alpha: 1.0)
        view.addSubview(activityIndicatorView)
    }
    
    private func loginButtonPressed() {
        guard let username = loginTextField.text, let password = passwordTextField.text
            else { return }
        
        RequestManager.sharedInstance.login(username: username, password: password) { (success, token, error) in
            if success {
                let saveAccessToken: Bool = KeychainWrapper.standard.set(token!, forKey: "accessToken")
                print("Acces token save result: \(saveAccessToken)")
                let setLocationViewController = StoryboardManager.setLocationViewController()
                self.present(setLocationViewController, animated: true, completion: nil)
                self.activityIndicatorView.stopAnimating()
            } else {
                self.stopAnimating()
                let alert = UIAlertController(title: "Login failure", message: "Sorry, some error occured. Validate data and try again.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    switch action.style{
                    case .default:
                        print("default")
                    case .cancel:
                        print("cancel")
                    case .destructive:
                        print("destructive")
                    }}))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        guard let username = loginTextField.text,  let password = passwordTextField.text
            else { return }
        
        let validationResult: Bool =
            ![username.matchesRegex(regex: Regex.username.rawValue),
              password.matchesRegex(regex: Regex.password.rawValue)].contains(false)
        
        validationResult ? loginButtonConfiguration(isEnabled: true, alpha: 1.0) : loginButtonConfiguration(isEnabled: false, alpha: 0.5)
    }
    
    private func loginButtonConfiguration(isEnabled state: Bool, alpha: CGFloat) {
        loginButton.isEnabled = state
        loginButton.alpha = alpha
    }
    
    
    private func showActivityIndicator(){
        let size = CGSize(width: 100, height: 100)
        startAnimating(size, message: "Loading", messageFont: UIFont.systemFont(ofSize: 15, weight: .light), type: activityIndicatorView.type, textColor: UIColor(red: 113.0/255.0, green: 195.0/255.0, blue: 139.0/255.0, alpha: 0.7))
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
            NVActivityIndicatorPresenter.sharedInstance.setMessage("Almost there...")
        }
    }
    
}










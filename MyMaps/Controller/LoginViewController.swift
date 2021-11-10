//
//  LoginViewController.swift
//  MyMaps
//
//  Created by Karahanyan Levon on 09.11.2021.
//

import UIKit

class LoginViewController: UIViewController {
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = Colors.whiteColor
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let logoLabel: UILabel = {
        let label = UILabel()
        label.text = "MyMap"
        label.textColor = Colors.mainBlueColor
        label.font = UIFont(name: "Geeza Pro Bold", size: 40)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let loginButton = ExtendedButton(title: "Log in",
                                             backgroundColor: Colors.whiteColor,
                                             titleColor: .black,
                                             isShadow: true,
                                             accessibilityIdentifier: "loginButton")
    private let registrationButton = ExtendedButton(title: "Sign up",
                                                    backgroundColor: Colors.mainBlueColor,
                                                    titleColor: Colors.whiteColor,
                                                    isShadow: false,
                                                    accessibilityIdentifier: "registrationButton")
    
    private let loginStandardTextField = MyMapsStandardTextField(labelText: "Login",
                                                                 accessibilityIdentifier: "loginTF")
    private let passwordStandardTextField = MyMapsStandardTextField(labelText: "Password",
                                                                    isSecured: true,
                                                                    accessibilityIdentifier: "passwordTF")
    private let activityView = UIActivityIndicatorView()
    
    private var isKeyboardShown = false
    
    private let userDataRealm = UserDataRealm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGestureRecognizer()
        setupViews()
        addTargetToButtons()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardObservers()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObservers()
    }
}

// MARK: - Setup views
extension LoginViewController {
    private func setupViews() {
        setupScrollView()
        setupAuthForm()
        setupActivityView()
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupAuthForm() {
        let loginFormStackView = UIStackView(arrangedSubviews: [loginStandardTextField,
                                                                passwordStandardTextField])
        loginFormStackView.axis = .vertical
        loginFormStackView.spacing = 10
        loginFormStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let buttonsStackView = UIStackView(arrangedSubviews: [loginButton, registrationButton])
        buttonsStackView.axis = .vertical
        buttonsStackView.spacing = 20
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(logoLabel)
        scrollView.addSubview(loginFormStackView)
        scrollView.addSubview(buttonsStackView)
        
        NSLayoutConstraint.activate([
            logoLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            logoLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 100),
            
            loginFormStackView.topAnchor.constraint(equalTo: logoLabel.topAnchor, constant: 100),
            loginFormStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            loginFormStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            buttonsStackView.topAnchor.constraint(equalTo: loginFormStackView.bottomAnchor, constant: 50),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupActivityView() {
        activityView.center = view.center
        activityView.color = Colors.mainBlueColor
        activityView.style = .large
        view.addSubview(activityView)
    }
    
    private func presentAlertInfo(title: String, text: String, withOneOkButton: Bool) {
        DispatchQueue.main.async {
            let toVC = AlertInfoViewController(title: title,
                                               text: text,
                                               withOneOkButton: withOneOkButton)
            toVC.modalPresentationStyle = .overCurrentContext
            toVC.modalTransitionStyle = .crossDissolve
            self.present(toVC, animated: true, completion: nil)
        }
    }
}

// MARK: - Setup observers and gestures recognizer
extension LoginViewController {
    private func addTapGestureRecognizer() {
        let hideKeyboardGesture = UITapGestureRecognizer(target: self,
                                                         action: #selector(hideKeyboard))
        scrollView.addGestureRecognizer(hideKeyboardGesture)
    }
    
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillBeShown),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillBeHiden),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillShowNotification,
                                                  object: nil)
        
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillHideNotification,
                                                  object: nil)
    }
    
    @objc private func keyboardWillBeShown(notification: Notification) {
        guard !isKeyboardShown else { return }
        let info = notification.userInfo as NSDictionary?
        let keyboardSize = (info?.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as? NSValue)?.cgRectValue.size
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize?.height ?? 0.0, right: 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        isKeyboardShown = true
    }
    
    @objc private func keyboardWillBeHiden() {
        guard isKeyboardShown else { return }
        
        let contentInsets = UIEdgeInsets.zero
        
        scrollView.contentInset = contentInsets
        isKeyboardShown = false
    }
    
    @objc private func hideKeyboard() {
        scrollView.endEditing(true)
    }
}

// MARK: - Setup targets
extension LoginViewController {
    private func addTargetToButtons() {
        loginButton.addTarget(self,
                              action: #selector(loginButtonTapped),
                              for: .touchUpInside)
        registrationButton.addTarget(self,
                                     action: #selector(registrationButtonTapped),
                                     for: .touchUpInside)
    }
    
    @objc private func loginButtonTapped() {
        guard
            let login = loginStandardTextField.textfield.text,
            let password = passwordStandardTextField.textfield.text,
            loginStandardTextField.textfield.text != "",
            passwordStandardTextField.textfield.text != ""
        else { presentAlertInfo(title: "Warning",
                                text: "Login or password is wrong",
                                withOneOkButton: true)
            return
        }
        
        userDataRealm.getSpecificUserData(for: login) { userData in
            guard
                let userData = userData
            else { presentAlertInfo(title: "Warning",
                                    text: "Login or password is wrong",
                                    withOneOkButton: true)
                return
            }
            if password == userData.password {
                let toVC = MainViewController()
                navigationController?.pushViewController(toVC, animated: true)
            } else {
                presentAlertInfo(title: "Warning",
                                        text: "Login or password is wrong",
                                        withOneOkButton: true)
            }
        }
    }
    
    @objc private func registrationButtonTapped() {
        let toVC = RegistrationViewController()
        navigationController?.pushViewController(toVC, animated: true)
    }
    
    private func startActivityViewAnimating() {
        DispatchQueue.main.async {
            self.activityView.isHidden = false
            self.activityView.startAnimating()
        }
    }
    
    private func stopActivityAnimating() {
        DispatchQueue.main.async {
            self.activityView.isHidden = true
            self.activityView.stopAnimating()
        }
    }
}


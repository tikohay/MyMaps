//
//  RegistrationViewController.swift
//  MyMaps
//
//  Created by Karahanyan Levon on 09.11.2021.
//

import UIKit
import RealmSwift

class RegistrationViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = Colors.whiteColor
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Geeza Pro Bold", size: 40)
        label.text = "Registration"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let registrationButton = ExtendedButton(title: "Registration",
                                              backgroundColor: Colors.mainBlueColor,
                                              titleColor: .white,
                                              accessibilityIdentifier: "registrationButton")
    private let activityView = UIActivityIndicatorView()
    
    private let usernameTextField = MyMapsStandardTextField(labelText: "Name",
                                                            accessibilityIdentifier: "usernameTextField")
    private let passwordTextField = MyMapsStandardTextField(labelText: "Passowrd",
                                                            isSecured: true,
                                                            accessibilityIdentifier: "passwordTextField")
    
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
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObservers()
    }
}

//MARK: - Setup views
extension RegistrationViewController {
    private func setupViews() {
        setupScrollView()
        setupEditorForm()
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
    
    private func setupEditorForm() {
        let stackView = UIStackView(arrangedSubviews: [usernameTextField,
                                                       passwordTextField])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 20
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        registrationButton.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(stackView)
        scrollView.addSubview(registrationButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            
            stackView.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: 150),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            registrationButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 30),
            registrationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            registrationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            registrationButton.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupActivityView() {
        activityView.center = view.center
        activityView.color = Colors.mainBlueColor
        activityView.style = .large
        view.addSubview(activityView)
    }
}

//MARK: - Setup observers and gestures recognizer
extension RegistrationViewController {
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
    
    private func addTapGestureRecognizer() {
        let hideKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        scrollView.addGestureRecognizer(hideKeyboardGesture)
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
extension RegistrationViewController {
    private func addTargetToButtons() {
        registrationButton.addTarget(self, action: #selector(registrationButtonTapped), for: .touchUpInside)
    }
    
    @objc func registrationButtonTapped() {
        guard
            let username = usernameTextField.textfield.text,
              let password = passwordTextField.textfield.text,
              usernameTextField.textfield.text != "",
              passwordTextField.textfield.text != ""
        else {
            self.presentAlertInfo(title: "Warning",
                                        text: "The parameters are entered incorrectly")
            return
        }
        
        userDataRealm.addUserData(login: username, password: password) {
            print(username, password)
        }
    }
    
    private func sendRegistrationData() {
        
    }
    
    private func presentAlertInfo(title: String, text: String) {
        DispatchQueue.main.async {
            let toVC = AlertInfoViewController(title: title,
                                               text: text,
                                               isOnRegistration: true)
            toVC.modalPresentationStyle = .overCurrentContext
            toVC.modalTransitionStyle = .crossDissolve
            self.present(toVC, animated: true, completion: nil)
        }
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
    
    @objc func dismissController() {
        dismiss(animated: true, completion: nil)
    }
}


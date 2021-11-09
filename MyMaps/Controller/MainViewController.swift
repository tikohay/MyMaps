//
//  MainViewController.swift
//  MyMaps
//
//  Created by Karahanyan Levon on 09.11.2021.
//

import UIKit
import SwiftUI

class MainViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello, Nicolas"
        label.tintColor = Colors.mainBlueColor
        label.textAlignment = .left
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let travelAnimation: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.translatesAutoresizingMaskIntoConstraints  = false
        return view
    }()
    
    private let showMapButton = ExtendedButton(title: "Show map",
                                       backgroundColor: Colors.mainBlueColor,
                                       titleColor: Colors.whiteColor)
    private let logoutButton = ExtendedButton(title: "Logout",
                                      backgroundColor: .gray,
                                      titleColor: .white)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        addTargets()
        
        UserDefaults.standard.set(true, forKey: "isLogin")
    }
}

//MARK: - Setup views
private extension MainViewController {
    func setupViews() {
        view.backgroundColor = Colors.whiteColor
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupMainForm()
    }
    
    func setupMainForm() {
        let stackView = UIStackView(arrangedSubviews: [showMapButton,
                                                       logoutButton])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 30
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        showMapButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(titleLabel)
        self.view.addSubview(travelAnimation)
        self.view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            travelAnimation.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            travelAnimation.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            travelAnimation.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            travelAnimation.heightAnchor.constraint(equalToConstant: 250),
            
            stackView.topAnchor.constraint(equalTo: travelAnimation.bottomAnchor, constant: 30),
            stackView.widthAnchor.constraint(equalToConstant: 100),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        travelAnimation.isHidden = true
    }
}


//MARK: - Add targets
private extension MainViewController {
    func addTargets() {
        showMapButton.addTarget(self,
                                action: #selector(showMapButtonTapped),
                                for: .touchUpInside)
        logoutButton.addTarget(self,
                               action: #selector(logoutButtonTapped),
                               for: .touchUpInside)
    }
    
    @objc func showMapButtonTapped() {
        let toVC = MapViewController()
        toVC.modalTransitionStyle = .flipHorizontal
        toVC.modalPresentationStyle = .fullScreen
        present(toVC, animated: true, completion: nil)
    }
    
    @objc func logoutButtonTapped() {
        UserDefaults.standard.set(false, forKey: "isLogin")
        let toVC = Launch()
        toVC.modalTransitionStyle = .crossDissolve
        toVC.modalPresentationStyle = .fullScreen
        present(toVC, animated: true, completion: nil)
    }
}

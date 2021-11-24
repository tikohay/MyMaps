//
//  MainViewController.swift
//  MyMaps
//
//  Created by Karahanyan Levon on 09.11.2021.
//

import UIKit
import SwiftUI
import Lottie
import AVFoundation

class MainViewController: UIViewController {
    
    var userPictureImage = UIImage()
    
    var name: String = "" {
        didSet {
            UserDefaults.standard.set(name, forKey: "name")
        }
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.tintColor = Colors.mainBlueColor
        label.textAlignment = .left
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let travelAnimation: AnimationView = {
        let view = AnimationView()
        let path = Bundle.main.path(forResource: "Animation", ofType: "json") ?? ""
        view.animation = Animation.filepath(path)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let showMapButton = ExtendedButton(title: "Show map",
                                       backgroundColor: Colors.mainBlueColor,
                                       titleColor: Colors.whiteColor)
    private let logoutButton = ExtendedButton(title: "Logout",
                                      backgroundColor: .gray,
                                      titleColor: .white)
    
    private let takeSelfieButton = ExtendedButton(title: "Take selfie",
                                                  backgroundColor: Colors.whiteColor,
                                                  titleColor: .black,
                                                  isShadow: true)
    
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
        if let name = UserDefaults.standard.string(forKey: "name") {
            titleLabel.text = "Hello, \(name)"
        }
        
        let stackView = UIStackView(arrangedSubviews: [showMapButton,
                                                       logoutButton,
                                                       takeSelfieButton])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 20
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(titleLabel)
        self.view.addSubview(travelAnimation)
        self.view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            travelAnimation.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            travelAnimation.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            travelAnimation.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            travelAnimation.heightAnchor.constraint(equalToConstant: 250),
            
            stackView.topAnchor.constraint(equalTo: travelAnimation.bottomAnchor, constant: 30),
            stackView.widthAnchor.constraint(equalToConstant: 100),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
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
        takeSelfieButton.addTarget(self,
                                   action: #selector(takeSelfieButtonTapped),
                                   for: .touchUpInside)
    }
    
    @objc func showMapButtonTapped() {
        travelAnimation.play(completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let toVC = MapViewController()
            toVC.modalTransitionStyle = .flipHorizontal
            toVC.modalPresentationStyle = .fullScreen
            self.travelAnimation.stop()
            self.present(toVC, animated: true, completion: nil)
        }
    }
    
    @objc func logoutButtonTapped() {
        UserDefaults.standard.set(false, forKey: "isLogin")
        let toVC = Launch()
        toVC.modalTransitionStyle = .crossDissolve
        toVC.modalPresentationStyle = .fullScreen
        present(toVC, animated: true, completion: nil)
    }
    
    @objc func takeSelfieButtonTapped() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }
}

extension MainViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) { [weak self] in
            guard let image = self?.extractImage(form: info) else { return }
            self?.userPictureImage = image
        }
    }
    
    private func extractImage(form info: [UIImagePickerController.InfoKey: Any]) -> UIImage? {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            return image
        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            return image
        } else {
            return nil
        }
    }
}

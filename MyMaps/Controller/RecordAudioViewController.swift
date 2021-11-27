//
//  RecordAudioViewController.swift
//  MyMaps
//
//  Created by Karahanyan Levon on 27.11.2021.
//

import UIKit
import Lottie

class RecordAudioViewController: UIViewController {
    
    private let recordAnimation: AnimationView = {
        let view = AnimationView()
        let path = Bundle.main.path(forResource: "audioRecordAnimation", ofType: "json") ?? ""
        view.animation = Animation.filepath(path)
        view.loopMode = .autoReverse
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let recordButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "record.circle"), for: .normal)
        button.tintColor = .red
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let playAudioButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "play.circle"), for: .normal)
        button.tintColor = Colors.mainBlueColor
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var isRecording = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        addTargets()
    }
}

//MARK: - Setup view
private extension RecordAudioViewController {
    func setupViews() {
        view.backgroundColor = Colors.whiteColor
        
        setupRecordAudioForm()
    }
    
    func setupRecordAudioForm() {
        let stackView = UIStackView(arrangedSubviews: [recordButton, playAudioButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 50
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(recordAnimation)
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            recordAnimation.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            recordAnimation.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            recordAnimation.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            recordAnimation.bottomAnchor.constraint(equalTo: recordButton.topAnchor, constant: -50),
            
            recordButton.heightAnchor.constraint(equalToConstant: 80),
            recordButton.widthAnchor.constraint(equalToConstant: 80),
            
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        ])
    }
}

//MARK: - Add targets
private extension RecordAudioViewController {
    func addTargets() {
        recordButton.addTarget(self,
                               action: #selector(recordButtonTapped),
                               for: .touchUpInside)
        playAudioButton.addTarget(self,
                                  action: #selector(playAudioButtonTapped),
                                  for: .touchUpInside)
    }
    
    @objc func recordButtonTapped() {
        isRecording.toggle()
        if isRecording {
            recordButton.setImage(UIImage(systemName: "pause.circle"), for: .normal)
            recordAnimation.play(completion: nil)
            playAudioButton.isEnabled = false
        } else {
            recordButton.setImage(UIImage(systemName: "record.circle"), for: .normal)
            recordAnimation.stop()
            playAudioButton.isEnabled = true
        }
    }
    
    @objc func playAudioButtonTapped() {
        
    }
}

//
//  Launch.swift
//  MyMaps
//
//  Created by Karahanyan Levon on 09.11.2021.
//

import UIKit

class Launch: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.mainBlueColor
//        if UserDefaults.standard.bool(forKey: "isLogin") {
        let toVC = LoginViewController()
        toVC.modalTransitionStyle = .flipHorizontal
        toVC.modalPresentationStyle = .fullScreen
        present(toVC, animated: true, completion: nil)
//        }
    }
}

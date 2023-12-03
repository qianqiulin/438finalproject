//
//  FrequentlyAskedQuestionsViewController.swift
//  WUBET-LOGIN
//
//  Created by McKelvey Student on 12/3/23.
//

import Foundation
import UIKit

class FrequentlyAskedQuestionsViewController:UIViewController {
    
    override func viewDidLoad() {
        setupDarkModeObserver()
    }
    override func viewDidAppear(_ animated: Bool) {
        setupDarkModeObserver()
    }
    
    func setupDarkModeObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeChanged), name: Notification.Name("DarkModeChanged"), object: nil)
        updateDarkMode()
    }
    
    @objc func darkModeChanged() {
        updateDarkMode()
    }
    
    func updateDarkMode() {
        if DarkModeManager.shared.isDarkModeEnabled {
            view.backgroundColor = .darkGray
        } else {
            view.backgroundColor = .white
        }
    }
}

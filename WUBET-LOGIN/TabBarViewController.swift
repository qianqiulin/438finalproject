//
//  TabBarViewController.swift
//  WUBET-LOGIN
//
//  Created by 钱秋霖 on 2023/11/30.
//

import UIKit

class TabBarViewController: UITabBarController {
    var UID:String=""
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

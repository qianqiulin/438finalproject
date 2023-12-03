//
//  AccountInformationViewController.swift
//  WUBET-LOGIN
//
//  Created by McKelvey Student on 12/2/23.
//

import Foundation
import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class AccountInformationViewController:UIViewController{
    
    // Outlets
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var bettingPointsLabel: UILabel!
    @IBOutlet weak var favoriteTeamLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var welcomeLabel: UILabel!
    
    var UID: String = ""
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        if let user = Auth.auth().currentUser {
            UID = user.uid
            loadUserInfo()
        } else {
            print("No user is currently logged in.")
        }
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
    
    func loadUserInfo() {
        let userRef = db.collection("users").document(UID)
        
        userRef.getDocument{document, error in
            if let document = document, document.exists {
                let data = document.data()
                if let username = data?["userName"] as? String {
                    self.welcomeLabel.text = "Welcome, \(username)!"
                } else {
                    self.welcomeLabel.text = "Welcome!"
                }
                if let favoriteTeam = data?["favoriteTeam"] as? String {
                    self.favoriteTeamLabel.text = "\(favoriteTeam)"
                } else {
                    self.favoriteTeamLabel.text = "Not Set"
                }
                
                if let bettingPoints = data?["bettingPoints"] as? Int {
                    self.bettingPointsLabel.text = "\(bettingPoints)"
                } else {
                    self.bettingPointsLabel.text = "Not Set"
                }
            } else {
                print("Document doesn't exist")
            }
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let newUsername = usernameTextField.text, !newUsername.isEmpty else {
            return
        }
        let userRef = db.collection("users").document(UID)
        userRef.updateData(["userName": newUsername]) {error in
            if let error = error {
                print("Error updating username: \(error.localizedDescription)")
            } else {
                print("username updated successfully: \(newUsername)")
                self.loadUserInfo()
                
            }
        }
    }
}

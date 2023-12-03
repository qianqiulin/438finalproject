//
//  CreateAccountViewController.swift
//  WUBET-LOGIN
//
//  Created by 程友鹏 on 11/11/23.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore
class CreateAccountViewController: UIViewController {

    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var userUID:String?
    var db: Firestore!
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
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
    
    @IBAction func signupClicked(_ sender: UIButton) {
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self]firebaseResult, error in
            guard let strongSelf = self else { return }
            if let e = error {
                print("Error creating user: \(e.localizedDescription)")
                strongSelf.errorMessage.text = "Invalid email or password."
            }else if let user = firebaseResult?.user {
                strongSelf.userUID = user.uid
                print("User ID: \(user.uid)") // User's UID

                //DispatchQueue.main.async {
                    //strongSelf.performSegue(withIdentifier: "goToNext", sender: strongSelf)
                //}
                let newData: [String: Any] = [
                    "userName": NSNull(),
                    "bettingPoints": 1000,
                    "favoriteTeam": NSNull()
                ]
                let customDocumentID = self!.userUID
                self!.db.collection("users").document(customDocumentID!).setData(newData) { error in
                    if let error = error {
                        print("Error adding document: \(error)")
                    } else {
                        print("Document added with userUID")
                    }
                }
                let gamebleVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "TabBarController") as! TabBarViewController
                gamebleVC.UID = user.uid
                gamebleVC.modalPresentationStyle = .fullScreen
                self!.present(gamebleVC, animated: true, completion: nil)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToNext" {
            if let nextViewController = segue.destination as? GamblingViewController {
                nextViewController.UID = self.userUID!
            }
        }
    }

}

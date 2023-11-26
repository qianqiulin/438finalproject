//
//  LoginViewController.swift
//  WUBET-LOGIN
//
//  Created by 程友鹏 on 11/11/23.
//

import UIKit
import Firebase
class LoginViewController: UIViewController {

    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var userUID: String?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginClicked(_ sender: UIButton) {
        guard let email = emailTextField.text else { return }
            guard let password = passwordTextField.text else { return }
            
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] firebaseResult, error in
                guard let strongSelf = self else { return }

                if let e = error {
                    print("Error creating user: \(e.localizedDescription)")
                    strongSelf.errorMessage.text = "Invalid email or password."
                } else if let user = firebaseResult?.user {
                    strongSelf.userUID = user.uid
                    print("User ID: \(user.uid)") // User's UID

                    DispatchQueue.main.async {
                        strongSelf.performSegue(withIdentifier: "goToNext", sender: strongSelf)
                    }
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

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
            
            Auth.auth().signIn(withEmail: email, password: password) {  firebaseResult, error in
                if let e = error {
                    print("Error creating user: \(e.localizedDescription)")
                    self.errorMessage.text = "Invalid email or password."
                } else if let user = firebaseResult?.user {
                    print("User ID: \(user.uid)") // User's UID
                    self.userUID=user.uid
                    print(self.userUID!)
                    let gamebleVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "GambleVC") as! GamblingViewController
                    gamebleVC.UID = user.uid
//                    self.navigationController?.pushViewController(gamebleVC, animated: true)
                    self.present(gamebleVC, animated: true)
//                        self.performSegue(withIdentifier: "goToNext", sender: self)
                }
            }
        }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToNext" {
            print("enter1")
                if let nextViewController = segue.destination as? GamblingViewController,
                   let loginViewController = sender as? LoginViewController{
                    print("enter2")
                    print(loginViewController.userUID!)
                    if let uid = loginViewController.userUID {
                        
                        print("User ID to pass: \(uid)")
                        nextViewController.UID = uid
                    }
                }
            }
    }

        
    }

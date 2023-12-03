//
//  ViewController.swift
//  WUBET-LOGIN
//
//  Created by 程友鹏 on 11/11/23.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        setupDarkModeObserver()
        // Do any additional setup after loading the view.
        //getCollection()
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
    
    var db: Firestore!
    func getCollection(){
        db.collection("matchinfo").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                guard let querySnapshot = querySnapshot else {
                    print("No documents found.")
                    return
                }

                for document in querySnapshot.documents {
                    print("\(document.documentID): \(document.data())")
                }
            }
        }
    }
    
    
    

}


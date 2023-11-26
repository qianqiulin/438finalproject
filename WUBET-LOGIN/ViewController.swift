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
        // Do any additional setup after loading the view.
        //getCollection()
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


//
//  BettingDetailViewController.swift
//  WUBET-LOGIN
//
//  Created by 钱秋霖 on 2023/11/24.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
class BettingDetailViewController: UIViewController {
    @IBOutlet weak var totalAmount: UILabel!
    var time:String=""
    var home:String=""
    var away:String=""
    var key:String=""
    var team1=(0.0,"hometeam")
    var team2=(0.0,"awayteam")
    var matchid:String=""
    var UID:String="not getting"
    var db: Firestore!
    var userName=""
    var userPoints=0.0
    @IBOutlet weak var winAmount: UILabel!
    @IBOutlet weak var BetAmount: UITextField!
    @IBOutlet weak var TeamSelector: UISegmentedControl!
    @IBOutlet weak var GameInfo: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        let gameInfoString = "Match Time: \(time), Teams: \(away)(away) vs. \(home)(home). Odds - \(team1.1): \(team1.0), \(team2.1): \(team2.0)"
        GameInfo.numberOfLines=0
        GameInfo.text=gameInfoString
        print(home)
        print(away)
        print(UID)
        let firestoreManager = FirestoreManager()
        firestoreManager.fetchUserData(uid: UID) { [weak self] userData in
            DispatchQueue.main.async {

                if let userData = userData {
                                    print("User Data received: \(userData)")
                                    self?.userName = userData.userName ?? "User"
                                    self?.userPoints = userData.bettingPoints
                    self!.totalAmount.text="Current Amount:\(self!.userPoints)"
                                    // Optional: handle favorite team
                                } else {
                                    print("Failed to fetch user data or data is nil.")
                                }
                
            }
        }
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func textChange(_ sender: Any) {
        if let textFieldText = BetAmount.text, let number = Double(textFieldText) {
            // Successfully parsed the number
            if TeamSelector.selectedSegmentIndex==0{
                let totalwinning=number*team1.0
                winAmount.text="If win you can get:\(totalwinning)"
            }
            else{
                let totalwinning=number*team2.0
                winAmount.text="If win you can get:\(totalwinning)"
            }
            
        } else {
            // Handle the error: The text is not an integer
            winAmount.text="The text is not a valid integer."
        }
    }
    @IBAction func OnceClicked(_ sender: Any) {
        if let textFieldText = BetAmount.text, let number = Double(textFieldText) {
            // Successfully parsed the number
            if TeamSelector.selectedSegmentIndex==0{
                let totalwinning=number*team1.0
                let newData: [String: Any] = [
                    "time": time,
                    "bettingAmount": number,
                    "totalwinning":totalwinning,
                    "selectTeam":home,
                    "otherTeam":away,
                    "matchid":matchid,
                    "UID":self.UID,
                    "status":false
                ]
                db.collection("bethistory").addDocument(data: newData) { error in
                    if let error = error {
                        print("Error adding document: \(error)")
                    } else {
                        print("Document added with auto-generated ID")
                        self.userPoints=self.userPoints-number
                        self.totalAmount.text="Current Balance:\(self.userPoints)"
                        self.winAmount.numberOfLines=0
                        self.winAmount.text="You successfully bet it! If \(self.home) win, you will get \(totalwinning)"
                        let documentRef = self.db.collection("users").document(self.UID)
                        let updatedData: [String: Any] = [
                            "userName": self.userName,
                            "bettingPoints": self.userPoints
                            // Add more fields if needed
                        ]
                        documentRef.setData(updatedData, merge: true) { error in
                            if let error = error {
                                print("Error updating document: \(error.localizedDescription)")
                            } else {
                                print("Document updated successfully")
                            }
                        }

                    }
                }
            }
            else{
                let totalwinning=number*team2.0
                let newData: [String: Any] = [
                    "time": time,
                    "totalwinning":totalwinning,
                    "selectTeam":away,
                    "otherTeam":home,
                    "matchid":matchid,
                    "UID":self.UID,
                    "status":false
                ]
                db.collection("bethistory").addDocument(data: newData) { error in
                    if let error = error {
                        print("Error adding document: \(error)")
                    } else {
                        print("Document added with auto-generated ID")
                        self.userPoints=self.userPoints-number
                        self.totalAmount.text="Current Balance:\(self.userPoints)"
                        self.winAmount.numberOfLines=0
                        self.winAmount.text="You successfully bet it! If \(self.home) win, you will get \(totalwinning)"
                        let documentRef = self.db.collection("users").document(self.UID)
                        let updatedData: [String: Any] = [
                            "userName": self.userName,
                            "bettingPoints": self.userPoints
                            // Add more fields if needed
                        ]
                        documentRef.setData(updatedData, merge: true) { error in
                            if let error = error {
                                print("Error updating document: \(error.localizedDescription)")
                            } else {
                                print("Document updated successfully")
                            }
                        }
                    }
                }
            }
            
        } else {
            // Handle the error: The text is not an integer
            print("The text is not a valid integer.")
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

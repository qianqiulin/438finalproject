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
    var time:String=""
    var home:String=""
    var away:String=""
    var key:String=""
    var team1=(0.0,"hometeam")
    var team2=(0.0,"awayteam")
    var matchid:String=""
    var UID:String="not getting"
    var db: Firestore!
    @IBOutlet weak var winAmount: UILabel!
    @IBOutlet weak var BetAmount: UITextField!
    @IBOutlet weak var TeamSelector: UISegmentedControl!
    @IBOutlet weak var GameInfo: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        let gameInfoString = "Match Time: \(time), Teams: \(away) vs. \(home). Odds - \(team1.1): \(team1.0), \(team2.1): \(team2.0)"
        GameInfo.numberOfLines=0
        GameInfo.text=gameInfoString
        print(home)
        print(away)
        print(UID)
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
                    "totalwinning":totalwinning,
                    "selectTeam":home,
                    "matchid":matchid,
                    "UID":self.UID,
                    "status":false
                ]
                db.collection("bethistory").addDocument(data: newData) { error in
                    if let error = error {
                        print("Error adding document: \(error)")
                    } else {
                        print("Document added with auto-generated ID")
                    }
                }
            }
            else{
                let totalwinning=number*team2.0
                let newData: [String: Any] = [
                    "time": time,
                    "totalwinning":totalwinning,
                    "selectTeam":away,
                    "matchid":matchid,
                    "UID":self.UID,
                    "status":false
                ]
                db.collection("bethistory").addDocument(data: newData) { error in
                    if let error = error {
                        print("Error adding document: \(error)")
                    } else {
                        print("Document added with auto-generated ID")
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

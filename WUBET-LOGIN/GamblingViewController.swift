//
//  GamblingViewController.swift
//  WUBET-LOGIN
//
//  Created by 钱秋霖 on 2023/11/13.
//

import UIKit

import FirebaseCore
import FirebaseFirestore
class GamblingViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate {
    var games:[Game] = []
    let sportsname="basketball_nba"
    let api_key="aca376adaa18a88798937e298ae6a72e"
    let reuseIdentifier = "gameCell"
    var userID:String=""
    var gameinfo:[Gameinfo] = []
    var UID:String=""
    @IBOutlet weak var GameCollectionView: UICollectionView!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return games.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! GameCollectionViewCell
        let guest=games[indexPath.row].away_team
        let home=games[indexPath.row].home_team
        let gamestring="\(guest)\nvs\n\(home)"
        cell.gamename.numberOfLines=0
        cell.gamename.text=gamestring
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dataToSend = SegueData(indexPath: indexPath, UID: self.UID)
            performSegue(withIdentifier: "ToBettingDetail", sender: dataToSend)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        GameCollectionView.dataSource=self
        GameCollectionView.delegate = self
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        // Do any additional setup after loading the view.
        //getCollection()
        print("UID is \(UID)")
        DispatchQueue.global(qos: .userInitiated).async {
            self.fetchUpcomingGames()
            self.addCompletedMatchInfo()
            DispatchQueue.main.async {
                self.GameCollectionView.reloadData()
            }
        }
    }
    func fetchUpcomingGames(){
        let urlString = "https://api.the-odds-api.com/v4/sports/basketball_nba/odds/?apiKey=aca376adaa18a88798937e298ae6a72e&regions=us&markets=h2h"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let apiResults = try decoder.decode([Game].self, from: data)
                self.games = apiResults
        } catch {
            print("Error fetching: " + urlString)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToBettingDetail"{
            if let BetDetailVC = segue.destination as? BettingDetailViewController,
               let data = sender as? SegueData {
                let indexPath=data.indexPath
                print("Passing UID\(data.UID)")
                BetDetailVC.UID=data.UID
                BetDetailVC.matchid=games[indexPath.row].id
                BetDetailVC.home=games[indexPath.row].home_team
                BetDetailVC.away=games[indexPath.row].away_team
                BetDetailVC.time=games[indexPath.row].commence_time
                BetDetailVC.key=games[indexPath.row].bookmakers[0].markets[0].key
                BetDetailVC.team1.1=games[indexPath.row].bookmakers[0].markets[0].outcomes[0].name
                BetDetailVC.team1.0=games[indexPath.row].bookmakers[0].markets[0].outcomes[0].price
                BetDetailVC.team2.1=games[indexPath.row].bookmakers[0].markets[0].outcomes[1].name
                BetDetailVC.team2.0=games[indexPath.row].bookmakers[0].markets[0].outcomes[1].price
                
            }
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
    func addCompletedMatchInfo() {
        let urlString = "https://api.the-odds-api.com/v4/sports/basketball_nba/scores/?daysFrom=3&apiKey=aca376adaa18a88798937e298ae6a72e"

        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let apiResults = try decoder.decode([Gameinfo].self, from: data)
            self.gameinfo = apiResults
        } catch {
            print("Error fetching: " + urlString)
            return
        }

        for game in gameinfo {
            if game.completed {
                let newData: [String: Any] = [
                    "time": game.commence_time,
                    "home": game.home_team,
                    "away": game.away_team,
                    "home_score": game.scores![0].score,
                    "away_score": game.scores![1].score
                    // Add other fields as necessary
                ]

                let documentID = game.id
                let documentRef = db.collection("matchinfo").document(documentID)
                
                // Check if the document already exists
                documentRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        //print("Document with ID \(documentID) already exists. Write operation cancelled.")
                    } else {
                        // Document does not exist, proceed with write
                        documentRef.setData(newData) { error in
                            if let error = error {
                                print("Error writing document: \(error)")
                            } else {
                                //print("Document successfully written with ID \(documentID)")
                            }
                        }
                    }
                }
            }
        }
    }


}
extension GamblingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = 300.0
        let cellHeight = 300.0

        return CGSize(width: cellWidth, height: cellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 3.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 3.0
    }
}

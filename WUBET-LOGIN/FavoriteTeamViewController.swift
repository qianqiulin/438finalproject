//
//  FavoriteTeamViewController.swift
//  WUBET-LOGIN
//
//  Created by McKelvey Student on 12/2/23.
//

import Foundation
import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class FavoriteTeamViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate{
    
    // All Teams
    let nbaTeams = [
        "Atlanta Hawks",
        "Boston Celtics",
        "Brooklyn Nets",
        "Charlotte Hornets",
        "Chicago Bulls",
        "Cleveland Cavaliers",
        "Dallas Mavericks",
        "Denver Nuggets",
        "Detroit Pistons",
        "Golden State Warriors",
        "Houston Rockets",
        "Indiana Pacers",
        "Los Angeles Clippers",
        "Los Angeles Lakers",
        "Memphis Grizzlies",
        "Miami Heat",
        "Milwaukee Bucks",
        "Minnesota Timberwolves",
        "New Orleans Pelicans",
        "New York Knicks",
        "Oklahoma City Thunder",
        "Orlando Magic",
        "Philadelphia 76ers",
        "Phoenix Suns",
        "Portland Trail Blazers",
        "Sacramento Kings",
        "San Antonio Spurs",
        "Toronto Raptors",
        "Utah Jazz",
        "Washington Wizards"
    ]
    var UID:String=""
    var db: Firestore!
    
    // Collection View
    @IBOutlet weak var TeamsCollectionView: UICollectionView!
    
    
    // Protocol
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nbaTeams.count
    }
    
    // Protocol
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NBATeamCell", for: indexPath) as? NBATeamCell else {
                    fatalError("Unable to dequeue NBATeamCell")
                }
        let teamName = nbaTeams[indexPath.item]
        cell.configure(with: teamName)
        cell.favoriteButton.tag = indexPath.item
        cell.favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped(_:)), for: .touchUpInside)
        
        return cell
    }
    
    @objc func favoriteButtonTapped(_ sender: UIButton) {
        let selectedTeam = nbaTeams[sender.tag]
        saveFavoriteTeam(team: selectedTeam)
    }
    
    func saveFavoriteTeam(team:String){
        let userRef = db.collection("users").document(UID)
        userRef.updateData(["favoriteTeam": team]) {error in
            if let error = error{
                print("Error saving favorite team: \(error.localizedDescription)")
            } else {
                print("Favorite team saved successfully: \(team)")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TeamsCollectionView.dataSource=self
        TeamsCollectionView.delegate=self
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        
        db = Firestore.firestore()
        if let user = Auth.auth().currentUser {
            UID = user.uid
        } else {
            print("No user is currently logged in.")
        }
        print("UID is \(UID)")
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
    
    
}

//
//  GamblingViewController.swift
//  WUBET-LOGIN
//
//  Created by 钱秋霖 on 2023/11/13.
//

import UIKit

class GamblingViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate {
    var games:[Game] = []
    let sportsname="basketball_nba"
    let api_key="aca376adaa18a88798937e298ae6a72e"
    let reuseIdentifier = "gameCell"
    
    
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
        print(gamestring)
        return cell
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        GameCollectionView.dataSource=self
        GameCollectionView.delegate = self
        DispatchQueue.global(qos: .userInitiated).async {
            self.fetchUpcomingGames()
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

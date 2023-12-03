
import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
class GamblingViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate {
    @IBOutlet weak var UserAmountText: UILabel!
    var games:[Game] = []
    let sportsname="basketball_nba"
    @IBOutlet weak var userGreetingText: UILabel!
    let api_key="aca376adaa18a88798937e298ae6a72e"
    let reuseIdentifier = "gameCell"
    var userID:String=""
    var gameinfo:[Gameinfo] = []
    var UID:String=""
    var userName=""
    var userPoints=0.0
    let nbaTeamAbbreviations = [
        "Atlanta Hawks": "ATL",
        "Boston Celtics": "BOS",
        "Brooklyn Nets": "BKN",
        "Charlotte Hornets": "CHA",
        "Chicago Bulls": "CHI",
        "Cleveland Cavaliers": "CLE",
        "Dallas Mavericks": "DAL",
        "Denver Nuggets": "DEN",
        "Detroit Pistons": "DET",
        "Golden State Warriors": "GSW",
        "Houston Rockets": "HOU",
        "Indiana Pacers": "IND",
        "Los Angeles Clippers": "LAC",
        "Los Angeles Lakers": "LAL",
        "Memphis Grizzlies": "MEM",
        "Miami Heat": "MIA",
        "Milwaukee Bucks": "MIL",
        "Minnesota Timberwolves": "MIN",
        "New Orleans Pelicans": "NOP",
        "New York Knicks": "NYK",
        "Oklahoma City Thunder": "OKC",
        "Orlando Magic": "ORL",
        "Philadelphia 76ers": "PHI",
        "Phoenix Suns": "PHX",
        "Portland Trail Blazers": "POR",
        "Sacramento Kings": "SAC",
        "San Antonio Spurs": "SAS",
        "Toronto Raptors": "TOR",
        "Utah Jazz": "UTA",
        "Washington Wizards": "WAS"
    ]
    @IBOutlet weak var GameCollectionView: UICollectionView!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return games.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! GameCollectionViewCell
        let guest=getTeamAbbreviation(for: games[indexPath.row].away_team)
        let home=getTeamAbbreviation(for: games[indexPath.row].home_team)
        let matchtime=convertToUserFriendlyDate(games[indexPath.row].commence_time)
        let gamestring="\(guest)  vs  \(home)"
        cell.gamename.text=gamestring
        cell.homeImage.image=UIImage(named: guest)
        cell.GuestImage.image=UIImage(named: home)
        cell.timeText.text=matchtime
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
        if let user = Auth.auth().currentUser {
            UID = user.uid
            // Use the UID to fetch user-specific data
        } else {
            print("No user is currently logged in.")
            // Handle the case where there is no logged-in user
        }
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
//        let firestoreManager = FirestoreManager()
//        firestoreManager.fetchUserData(uid: UID) { [weak self] userData in
//            DispatchQueue.main.async {
//
//                if let userData = userData {
//                                    print("User Data received: \(userData)")
//                                    self?.userName = userData.userName ?? "User"
//                    self?.userPoints = userData.bettingPoints
//                                    // Optional: handle favorite team
//                                } else {
//                                    print("Failed to fetch user data or data is nil.")
//                                }
//                
//            }
//        }
//        UserAmountText.text="Current Amount:\(self.userPoints)"
//        userGreetingText.text="Hello \(self.userName)"
        
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
    func getTeamAbbreviation(for teamName: String) -> String {
        return nbaTeamAbbreviations[teamName] ?? teamName
    }
    func convertToUserFriendlyDate(_ isoDateString: String) -> String {
        let isoDateFormatter = ISO8601DateFormatter()
        isoDateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        let userFriendlyDateFormatter = DateFormatter()
        userFriendlyDateFormatter.dateStyle = .medium
        userFriendlyDateFormatter.timeStyle = .short
        userFriendlyDateFormatter.timeZone = TimeZone.current

        if let date = isoDateFormatter.date(from: isoDateString) {
            return userFriendlyDateFormatter.string(from: date)
        } else {
            return "Invalid Date"
       
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
//extension GamblingViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let cellWidth = 300.0
//        let cellHeight = 300.0
//
//        return CGSize(width: cellWidth, height: cellHeight)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 3.0
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 3.0
//    }
//}

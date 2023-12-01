import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tokensLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    
    // MARK: - Properties
    var spinner: UIActivityIndicatorView!
    var betHistories = [BetHistory]()
    var matchInfos = [String: MatchInfo]()
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
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        spinner = UIActivityIndicatorView(style: .medium)
           spinner.center = self.view.center
           spinner.hidesWhenStopped = true
           view.addSubview(spinner)

           // Start the spinner
           spinner.startAnimating()
        // Set up the profile image view to be circular
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
        

        var userUID = ""
        if let user = Auth.auth().currentUser {
            userUID = user.uid
            // Use the UID to fetch user-specific data
        } else {
            print("No user is currently logged in.")
            // Handle the case where there is no logged-in user
        }
        let firestoreManager = FirestoreManager()
        firestoreManager.fetchUserData(uid: userUID) { [weak self] userData in
            DispatchQueue.main.async {
                self?.spinner.stopAnimating()

                if let userData = userData {
                                    print("User Data received: \(userData)")
                                    self?.nameLabel.text = userData.userName ?? "User"
                                    self?.tokensLabel.text = "Points: \(userData.bettingPoints)"
                                    // Optional: handle favorite team
                                } else {
                                    print("Failed to fetch user data or data is nil.")
                                }
            }
        }
        firestoreManager.fetchBetHistory(forUID: userUID) { [weak self] histories in
            self?.betHistories = histories
            
            // Extract match IDs from the fetched bet histories
            let matchIDs = histories.map { $0.matchid }
            print("Fetched MatchInfos matchIDs: \(matchIDs)")
            
            firestoreManager.fetchMatchInfos(matchIDs: matchIDs) { [weak self] matchInfosArray in
                print("Fetched MatchInfos Array: \(matchInfosArray)")
                
                // Filter out any MatchInfo objects that don't have a matchid set
                let validMatchInfos = matchInfosArray.compactMap { matchInfo -> (String, MatchInfo)? in
                    guard let matchid = matchInfo.matchid else { return nil }
                    return (matchid, matchInfo)
                }
                
                self?.matchInfos = Dictionary(uniqueKeysWithValues: validMatchInfos)
                print("MatchInfos Dictionary: \(self?.matchInfos ?? [:])")
                
                DispatchQueue.main.async {
                    self?.spinner.stopAnimating()
                    self?.tableView.reloadData()
                }
            }
        }
        // Set up the table view
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return betHistories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GameTableViewCell", for: indexPath) as? GameTableViewCell else {
            fatalError("The dequeued cell is not an instance of GameTableViewCell.")
        }
        
        let betHistory = betHistories[indexPath.row]
        if let matchInfo = matchInfos[betHistory.matchid] {
            // Format the date
            print("Fetched BetHistory: \(matchInfo)")
            
            // Configure the cell
            let awayTeamAbbreviation = getTeamAbbreviation(for: matchInfo.away)
            let homeTeamAbbreviation = getTeamAbbreviation(for: matchInfo.home)
            let matchDateString = convertToUserFriendlyDate(matchInfo.time)
            
            cell.configure(withGame: (name: "\(awayTeamAbbreviation) vs \(homeTeamAbbreviation)",
                                      date: matchDateString,
                                      details: "Status: \(betHistory.status)",
                                      profit: betHistory.totalwinning,
                                      imageName: "nba"))
        }
        
        return cell
    }
    
    func getTeamAbbreviation(for teamName: String) -> String {
        return nbaTeamAbbreviations[teamName] ?? teamName
    }
    func convertToUserFriendlyDate(_ isoDateString: String) -> String {
        let isoDateFormatter = ISO8601DateFormatter()
        
        let userFriendlyDateFormatter = DateFormatter()
        userFriendlyDateFormatter.dateStyle = .medium
        userFriendlyDateFormatter.timeStyle = .short
        
        if let date = isoDateFormatter.date(from: isoDateString) {
            return userFriendlyDateFormatter.string(from: date)
        } else {
            return "Invalid Date"
        }
    }
    
    
}

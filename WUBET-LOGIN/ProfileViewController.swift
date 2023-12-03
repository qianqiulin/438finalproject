import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tokensLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    
    // MARK: - Properties
    var firestoreManager = FirestoreManager()
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
        // Initialize the spinner
        spinner = UIActivityIndicatorView(style: .medium)
        spinner.center = self.view.center
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)

        // Start the spinner
        spinner.startAnimating()

        // Set up the profile image view to be circular
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true

        // Set up pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl

        // Fetch data
        fetchData {
            self.spinner.stopAnimating()
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
        let matchFinished = matchInfos[betHistory.matchid] != nil
        let userBetChoice = getTeamAbbreviation(for: betHistory.selectTeam)
        let opposingTeam = getTeamAbbreviation(for: betHistory.otherTeam)
        let matchDate = convertToUserFriendlyDate(betHistory.time)
        if matchFinished && !betHistory.status {
               updateUserBettingPoints(forBetHistory: betHistory)
           }

        let details: String
        let profitText: String
        let profitColor: UIColor
        var matchupName: String

        if matchFinished, let matchInfo = matchInfos[betHistory.matchid] {
            let userWon = determineIfUserWon(betHistory: betHistory, matchInfo: matchInfo)
            profitColor = userWon ? .green : .red
            profitText = userWon ? String(format: "+%.2f", betHistory.totalwinning) :  String(format: "-%.2f", betHistory.bettingAmount)
            details = "Bet: \(userBetChoice) - Score: \(matchInfo.away_score) - \(matchInfo.home_score)"
            matchupName = "\(getTeamAbbreviation(for: matchInfo.away)) vs \(getTeamAbbreviation(for: matchInfo.home))"
        } else {
            profitColor = .gray
            profitText = String(format: "+%.2f", betHistory.totalwinning)
            details = "Bet: \(userBetChoice) - In Progress"
            matchupName = "\(userBetChoice) vs \(opposingTeam)"
        }

        cell.configure(withGame: (name: matchupName,
                                  date: matchDate,
                                  details: details,
                                  profit: profitText,
                                  profitColor: profitColor,
                                  imageName: "nba"))

        return cell
    }
    
    func isMatchFinished(matchTime: String) -> Bool {
        let isoDateFormatter = ISO8601DateFormatter()
        isoDateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Parse the date as UTC

        guard let matchDateUTC = isoDateFormatter.date(from: matchTime) else { return false }

        // Convert the current time to UTC before comparison
        let currentTimeUTC = Date().addingTimeInterval(TimeInterval(-TimeZone.current.secondsFromGMT()))

        return matchDateUTC < currentTimeUTC
    }
    
    func determineIfUserWon(betHistory: BetHistory, matchInfo: MatchInfo) -> Bool {
        guard let awayScore = Int(matchInfo.away_score),
              let homeScore = Int(matchInfo.home_score) else {
            return false
        }

        let winningTeam = awayScore > homeScore ? matchInfo.away : matchInfo.home
        return betHistory.selectTeam == winningTeam
    }
    
    @objc private func refreshData(_ sender: UIRefreshControl) {
        fetchData {
            sender.endRefreshing()
        }
    }
    
    @IBAction func addMoneyButtonTapped(_ sender: UIButton) {
           showAddMoneyPopup()
       }
    
    func showAddMoneyPopup() {
            let alertController = UIAlertController(title: "Add Points", message: "Enter the amount to add", preferredStyle: .alert)

            alertController.addTextField { textField in
                textField.placeholder = "Amount"
                textField.keyboardType = .numberPad
            }

        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self, weak alertController] _ in
            guard let textField = alertController?.textFields?.first,
                  let amountString = textField.text,
                  let amount = Double(amountString), amount > 0 else {
                         self?.showAlert(title: "Invalid Input", message: "Please enter a positive number.")
                         return
                     }

                     guard let userUID = Auth.auth().currentUser?.uid else { return }

            self?.firestoreManager.updateUserBettingPoints(uid: userUID, newAmount: amount) { success in
                DispatchQueue.main.async {
                    if success {
                        self?.showAlert(title: "Success", message: "Amount added successfully")
                    } else {
                        self?.showAlert(title: "Error", message: "Failed to add amount")
                    }
                }
            }
        }

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

            alertController.addAction(addAction)
            alertController.addAction(cancelAction)

            self.present(alertController, animated: true)
        }
    
    func showAlert(title: String, message: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData {
            self.tableView.reloadData()
        }
    }
    
    private func fetchData(completion: @escaping () -> Void) {
        guard let userUID = Auth.auth().currentUser?.uid else {
            print("No user is currently logged in.")
            completion()
            return
        }

        self.firestoreManager.fetchUserData(uid: userUID) { [weak self] userData in
            DispatchQueue.main.async {
                if let userData = userData {
                    let displayName = userData.userName?.isEmpty == false ? userData.userName! : "User"
                    self?.nameLabel.text = displayName
                    self?.tokensLabel.text = "Points: \(String(format: "%.2f", userData.bettingPoints))"
                }
            }
        }

        self.firestoreManager.fetchBetHistory(forUID: userUID) { [weak self] histories in
            self?.betHistories = histories

            let matchIDs = histories.map { $0.matchid }
            self?.firestoreManager.fetchMatchInfos(matchIDs: matchIDs) { [weak self] matchInfosArray in
                let validMatchInfos = matchInfosArray.compactMap { matchInfo -> (String, MatchInfo)? in
                    guard let matchid = matchInfo.matchid else { return nil }
                    return (matchid, matchInfo)
                }

                self?.matchInfos = Dictionary(uniqueKeysWithValues: validMatchInfos)
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    completion()
                }
            }
        }
    }
    
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
    func updateUserBettingPoints(forBetHistory betHistory: BetHistory) {
        guard let userUID = Auth.auth().currentUser?.uid else {
            print("No user is currently logged in.")
            return
        }
        
        firestoreManager.updateBettingPoints(forUser: userUID, withBetHistory: betHistory, matchInfos: matchInfos) {
            // Handle completion, such as reloading data or updating UI
            print("Betting points and bet status updated.")
        }
        
    }
}

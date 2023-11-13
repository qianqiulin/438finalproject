import UIKit

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tokensLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    // For the demo, we'll use a mock array
    var games = [
        ("Game 1", "2023-11-13", "Win", 100.0, "gameImageName1"),
    ]
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the profile image view to be circular
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
        
        // Load profile data (mock data for the demo)
        nameLabel.text = "John Doe"
        tokensLabel.text = "Tokens: 1200"
        
        // Set up the table view
        tableView.delegate = self
        tableView.dataSource = self
    }
    
     //MARK: - UITableViewDataSource
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return games.count
        }
    
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "GameTableViewCell", for: indexPath) as? GameTableViewCell else {
                fatalError("The dequeued cell is not an instance of HistoryCell.")
            }
    
            let game = games[indexPath.row]
           cell.configure(withGame: (name: game.0, date: game.1, details: game.2, profit: game.3, imageName: game.4))
    
            return cell
        }
    }

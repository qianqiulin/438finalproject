import UIKit

class GameTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var gameImageView: UIImageView!
    @IBOutlet weak var gameNameLabel: UILabel!
    @IBOutlet weak var gameDateLabel: UILabel!
    @IBOutlet weak var gameDetailsLabel: UILabel!
    @IBOutlet weak var gameProfitLabel: UILabel!
    
    // MARK: - Configuration
    func configure(withGame game: (name: String, date: String, details: String, profit: Double, imageName: String)) {
        gameNameLabel.text = game.name
        gameDateLabel.text = game.date
        gameDetailsLabel.text = game.details
        gameProfitLabel.text = String(format: "$%.2f", game.profit)
        
        // Set the game image
        gameImageView.image = UIImage(named: game.imageName)
    }
    
    // MARK: - Initialization
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    // MARK: - Selection
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

import Foundation
import UIKit

class SettingsViewController: UIViewController{
    
    // Dark Mode
    //@IBAction func darkmode(_ sender:UISwitch){
    //    if sender.isOn{
    //        overrideUserInterfaceStyle = .dark
    //    }
    //    else{
    //        overrideUserInterfaceStyle = .light
    //    }
    //}
    
    
    @IBOutlet weak var darkModeSwitch: UISwitch!
    
    // How to Play Page
    @IBAction func howtoplay(_ sender: UIButton){
        performSegue(withIdentifier:"how_to_play", sender: self)
    }
    
    // Frequently Asked Questions
    @IBAction func frequentlyaskedquestions(_ sender: UIButton){
        performSegue(withIdentifier:"frequently_asked_questions", sender: self)
    }
    
    // Favorite Team
    @IBAction func favoriteteam(_ sender: UIButton){
        performSegue(withIdentifier:"favorite_team", sender: self)
    }
    
    // Profile Page
    @IBAction func profile(_ sender: UIButton){
        performSegue(withIdentifier:"profile", sender: self)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDarkModeSwitch()
    }
    
    func setupDarkModeSwitch() {
        darkModeSwitch.addTarget(self, action: #selector(darkModeSwitchChanged), for: .valueChanged)
        darkModeSwitch.isOn = DarkModeManager.shared.isDarkModeEnabled
        updateDarkMode()
    }
    
    @objc func darkModeSwitchChanged() {
        DarkModeManager.shared.isDarkModeEnabled = darkModeSwitch.isOn
        updateDarkMode()
    }
    
    func updateDarkMode() {
        if DarkModeManager.shared.isDarkModeEnabled {
            overrideUserInterfaceStyle = .dark
        } else {
            overrideUserInterfaceStyle = .light
        }
    }
}

//
//  BettingDetailViewController.swift
//  WUBET-LOGIN
//
//  Created by 钱秋霖 on 2023/11/24.
//

import UIKit

class BettingDetailViewController: UIViewController {
    var time:String=""
    var home:String=""
    var away:String=""
    var key:String=""
    var team1=(0.0,"awayteam")
    var team2=(0.0,"hometeam")
    var id:String=""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(time)
        print(home)
        print(away)
        print(key)
        print(team1)
        print(team2)
        // Do any additional setup after loading the view.
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

//
//  SmallTeamCell.swift
//  WUBET-LOGIN
//
//  Created by McKelvey Student on 12/2/23.
//

import Foundation
import UIKit

class NBATeamCell: UICollectionViewCell{
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    
    func configure(with teamname: String){
        teamNameLabel.text = teamname
    }
}

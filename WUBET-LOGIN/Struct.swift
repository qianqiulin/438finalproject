//
//  Struct.swift
//  WUBET-LOGIN
//
//  Created by 钱秋霖 on 2023/11/13.
//

import Foundation
import UIKit
struct Game: Decodable {
    let id: String
    let sport_key: String
    let sport_title: String
    let commence_time: String
    let home_team: String
    let away_team: String
    let bookmakers: [Bookmaker]
}

struct Bookmaker: Decodable {
    let key: String
    let title: String
    let last_update: String
    let markets: [Market]
}

struct Market: Decodable {
    let key: String
    let last_update: String
    let outcomes: [Outcome]
}

struct Outcome: Decodable {
    let name: String
    let price: Double
}

struct Gameinfo: Decodable {
    let id: String
    let sport_key: String
    let sport_title: String
    let commence_time: String
    let completed: Bool
    let home_team: String
    let away_team: String
    let scores: [Score]?
    let last_update: String?
}

struct Score: Decodable {
    let name: String
    let score: String
}


struct SegueData {
    var indexPath: IndexPath
    var UID: String
}

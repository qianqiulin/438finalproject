import FirebaseFirestore

class FirestoreManager {
    
    private let db = Firestore.firestore()
    
    // Fetch BetHistory for a specific UID
    func fetchBetHistory(forUID uid: String, completion: @escaping ([BetHistory]) -> Void) {
        db.collection("bethistory").whereField("UID", isEqualTo: uid).getDocuments { snapshot, error in
            if let error = error {
                print("Error getting bet history documents: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No bet history documents found for UID: \(uid)")
                completion([])
                return
            }
            
            let betHistory = documents.compactMap { queryDocumentSnapshot -> BetHistory? in
                do {
                    return try queryDocumentSnapshot.data(as: BetHistory.self)
                } catch {
                    print("Error decoding document: \(queryDocumentSnapshot.documentID), Error: \(error)")
                    return nil
                }
            }
            completion(betHistory)
        }
    }
    
    // Fetch MatchInfo based on a list of match IDs
    func fetchMatchInfos(matchIDs: [String], completion: @escaping ([MatchInfo]) -> Void) {
        var matchInfos: [MatchInfo] = []
        let group = DispatchGroup()
        
        for matchID in matchIDs {
            group.enter()
            db.collection("matchinfo").document(matchID).getDocument { document, error in
                if let document = document, document.exists {
                    var matchInfo = try? document.data(as: MatchInfo.self)
                    matchInfo?.matchid = document.documentID
                    if let matchInfo = matchInfo {
                        matchInfos.append(matchInfo)
                    }
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(matchInfos)
        }
    }
    
    func fetchUserData(uid: String, completion: @escaping (User?) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { (document, error) in
            if let document = document, document.exists {
                let userData = User(documentData: document.data() ?? [:])
                completion(userData)
            } else {
                print("Document does not exist or error: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
            }
        }
    }
    
    func updateBettingPoints(forUser uid: String, withBetHistory betHistory: BetHistory, matchInfos: [String: MatchInfo], completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        
        // Fetch the user data first
        fetchUserData(uid: uid) { [weak self] userData in
            guard var userData = userData else {
                print("User data not found")
                completion()
                return
            }
            
            // Prepare the batch
            let batch = db.batch()
            
            // Reference to the user document in the 'users' collection
            let userRef = db.collection("users").document(uid)
            
            // Determine if the user won the bet
            if let matchInfo = matchInfos[betHistory.matchid],
               self?.determineIfUserWon(betHistory: betHistory, matchInfo: matchInfo) == true {
                userData.bettingPoints += betHistory.totalwinning // Update points
                batch.updateData(["bettingPoints": userData.bettingPoints], forDocument: userRef)
            }
            
            // Query the 'bethistory' collection for the specific bet
            db.collection("bethistory")
                .whereField("UID", isEqualTo: uid)
                .whereField("matchid", isEqualTo: betHistory.matchid)
                .getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("Error getting documents: \(error)")
                        completion()
                        return
                    }
                    
                    guard let document = querySnapshot?.documents.first else {
                        print("No matching bet history document found")
                        completion()
                        return
                    }
                    
                    // Reference to the specific betHistory document
                    let betHistoryRef = document.reference
                    batch.updateData(["status": true], forDocument: betHistoryRef)
                    
                    // Commit the batch
                    batch.commit { err in
                        if let err = err {
                            print("Error writing batch: \(err)")
                        } else {
                            print("Batch write succeeded.")
                        }
                        completion()
                    }
                }
        }
    }
    
    
    // Helper method to determine if the user won the bet
    func determineIfUserWon(betHistory: BetHistory, matchInfo: MatchInfo) -> Bool {
        guard let awayScore = Int(matchInfo.away_score),
              let homeScore = Int(matchInfo.home_score) else {
            return false
        }
        
        let winningTeam = awayScore > homeScore ? matchInfo.away : matchInfo.home
        return betHistory.selectTeam == winningTeam
    }
    
    func updateUserBettingPoints(uid: String, newAmount: Double, completion: @escaping (Bool) -> Void) {
            let userRef = Firestore.firestore().collection("users").document(uid)
            
            userRef.getDocument { (document, error) in
                if let document = document, var userData = document.data() {
                    let currentPoints = userData["bettingPoints"] as? Double ?? 0
                    userData["bettingPoints"] = currentPoints + newAmount
                    
                    userRef.updateData(userData) { error in
                        if let error = error {
                            print("Error updating betting points: \(error)")
                            completion(false)
                        } else {
                            print("Betting points successfully updated.")
                            completion(true)
                        }
                    }
                } else {
                    print("Document does not exist or error fetching document: \(error?.localizedDescription ?? "Unknown error")")
                    completion(false)
                }
            }
        }
}
struct BetHistory: Codable {
    var matchid: String
    var UID: String
    var selectTeam: String
    var otherTeam: String
    var status: Bool
    var time: String
    var totalwinning: Double
    var bettingAmount: Double
}

struct MatchInfo: Codable {
    var matchid: String?
    var away: String
    var away_score: String
    var home: String
    var home_score: String
    var time: String
}
struct User {
    var userName: String?
    var bettingPoints: Double
    var favoriteTeam: String?

    init(documentData: [String: Any]) {
        self.userName = documentData["userName"] as? String
        self.bettingPoints = documentData["bettingPoints"] as? Double ?? 0.00
        self.favoriteTeam = documentData["favoriteTeam"] as? String
    }
}

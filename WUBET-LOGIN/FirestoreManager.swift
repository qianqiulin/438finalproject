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
}

struct BetHistory: Codable {
    var matchid: String
    var UID: String
    var selectTeam: String
    var status: Bool
    var time: String
    var totalwinning: Double
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

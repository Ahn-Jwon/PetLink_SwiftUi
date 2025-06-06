
import Foundation
import FirebaseFirestore


struct UserService {
    @MainActor
    static func fetchUser(withUid uid: String) async throws -> User {
        let snapshot = try await Firestore.firestore().collection(COLLERCTION_USER).document(uid).getDocument()
        return try snapshot.data(as: User.self)
    }
    
    
    @MainActor
    static func onDislike(user1: User, user2: User) {
        Firestore.firestore().collection(COLLERCTION_USER).document(user1.id)
            .updateData(["swipesLeft": FieldValue.arrayUnion([user2.id])])
    }
    
    
}

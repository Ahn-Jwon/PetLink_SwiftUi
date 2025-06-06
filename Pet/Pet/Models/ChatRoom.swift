import Foundation
import Firebase
import FirebaseFirestore


struct ChatRoom: Identifiable, Codable {
    let id: String
    let users: [String]            // [내 uid, 상대 uid]
    let usernames: [String]?       // [내 이름, 상대 이름] (2명 기준)
    let profileImageUrl: [String]?// [내 프로필 URL, 상대 프로필 URL] (추가)
    let lastMessage: String?
    let timestamp: Date
}

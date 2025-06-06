
import Foundation
import Firebase
import FirebaseFirestore

///```
struct Message: Identifiable, Codable {
    let id: String
    let senderId: String
    let senderName: String   // 발신자 이름
    let senderProfileUrl: String // 발신자 프로필 이미지 URL
    let text: String
    let timestamp: Date
}

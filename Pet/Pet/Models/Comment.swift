import Foundation
import FirebaseFirestore

struct Comment: Identifiable, Codable {
    @DocumentID var id: String?
    var boardId: String  // 댓글이 속한 게시글 ID
    var userId: String   // 작성자 ID
    var userName: String // 작성자 이름
    var content: String  // 댓글 내용
    var timestamp: Timestamp  // 작성 시간

    var formattedDate: String {
        timestamp.dateValue().formatted(.dateTime)
    }
}


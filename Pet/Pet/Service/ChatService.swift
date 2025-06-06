import Foundation
import FirebaseFirestore
import FirebaseAuth

class ChatService {
    private let db = Firestore.firestore()
    
    // MARK: - Chat Room Methods
    
    // MARK: 사용자별 채팅방 목록을 가져옴
    func fetchUserChatRooms(userId: String) async throws -> [ChatRoom] {
        let chatListRef = db.collection("chatList").document(userId)
        let snapshot = try await chatListRef.getDocument()
        guard let data = snapshot.data(),
              let chatRoomIds = data["chatRoomIds"] as? [String] else {
            return []
        }
        var chatRooms: [ChatRoom] = []
        let chatRoomsRef = db.collection("chatRooms")
        for chatRoomId in chatRoomIds {
            let chatRoomSnapshot = try await chatRoomsRef.document(chatRoomId).getDocument()
            if let chatRoom = try? chatRoomSnapshot.data(as: ChatRoom.self) {
                chatRooms.append(chatRoom)
            }
        }
        return chatRooms
    }
    
    // MARK: 사용자간 채팅방 생성
    func createChatRoom(userId: String, otherUserId: String, usernames: [String]) async throws -> ChatRoom {
        let chatRoomsRef = db.collection("chatRooms")
        let newChatRoomRef = chatRoomsRef.document()
        
        // 현재 사용자와 상대방의 프로필 URL을 Firestore에서 가져옴
        let userDoc = try await db.collection("user").document(userId).getDocument()
        let partnerDoc = try await db.collection("user").document(otherUserId).getDocument()
        
        let userProfileUrl = userDoc.data()?["profileImageUrl"] as? String ?? ""
        let partnerProfileUrl = partnerDoc.data()?["profileImageUrl"] as? String ?? ""
        
        let chatRoomData: [String: Any] = [
            "id": newChatRoomRef.documentID,
            "users": [userId, otherUserId],
            "usernames": usernames,
            "profileImageUrl": [userProfileUrl, partnerProfileUrl], // 프로필 URL 추가
            "lastMessage": "",
            "timestamp": Timestamp()
        ]
        
        try await newChatRoomRef.setData(chatRoomData)
        return try await newChatRoomRef.getDocument(as: ChatRoom.self)
    }

    
    // MARK: 사용자가 특정 채팅방에 참여할 수 있도록 chatList에 채팅방 ID를 추가
    func joinChatRoom(userId: String, chatRoomId: String) async throws {
        let chatListRef = db.collection("chatList").document(userId)
        let documentSnapshot = try await chatListRef.getDocument()
        if !documentSnapshot.exists {
            try await chatListRef.setData([:])
        }
        let data: [String: Any] = [
            "chatRoomIds": FieldValue.arrayUnion([chatRoomId])
        ]
        try await chatListRef.setData(data, merge: true)
    }
    
    // MARK: 두 사용자 간의 기존 채팅방이 있는지 확인
    func fetchExistingChatRoom(userId: String, otherUserId: String) async throws -> ChatRoom? {
        let chatRoomsRef = db.collection("chatRooms")
        let querySnapshot = try await chatRoomsRef
            .whereField("users", arrayContains: userId)
            .getDocuments()
        
        for document in querySnapshot.documents {
            if let chatRoom = try? document.data(as: ChatRoom.self),
               chatRoom.users.contains(otherUserId) {
                return chatRoom
            }
        }
        return nil
    }
    
    // MARK: - Message Methods
    // 지정한 채팅방에 메시지를 전송하고, 마지막 메시지 정보를 업데이트
    func sendMessage(chatRoomId: String, text: String) async throws {
        // 현재 사용자 uid 확인
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "로그인 필요"])
        }
        
        // 현재 사용자 가져오기
        guard let currentUser = Auth.auth().currentUser else {
            throw NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "로그인 필요"])
        }
        
        // Firestore에서 사용자 정보 조회
        let userDocRef = Firestore.firestore().collection("user").document(uid)
        let userSnapshot = try await userDocRef.getDocument()
        
        // 사용자 이름 및 프로필 이미지 URL 가져오기
        let username = userSnapshot.data()?["name"] as? String ?? "익명 사용자"
        let profileImageUrl = userSnapshot.data()?["profileImageUrl"] as? String ?? ""
        
        let currentUserId = currentUser.uid
        let messagesRef = db.collection("chatRooms").document(chatRoomId).collection("messages")
        
        // 수정된 메시지 생성 (senderProfileUrl 포함)
        let newMessage = Message(
            id: UUID().uuidString,
            senderId: currentUserId,
            senderName: username,
            senderProfileUrl: profileImageUrl,
            text: text,
            timestamp: Date()
        )
        
        // Firestore에 메시지 저장
        try await messagesRef.document(newMessage.id).setData([
            "id": newMessage.id,
            "senderId": newMessage.senderId,
            "senderName": username,
            "senderProfileUrl": profileImageUrl,
            "text": newMessage.text,
            "timestamp": Timestamp(date: newMessage.timestamp)
        ])
        
        // 채팅방의 마지막 메시지 업데이트
        let chatRoomRef = db.collection("chatRooms").document(chatRoomId)
        try await chatRoomRef.updateData([
            "lastMessage": newMessage.text,
            "timestamp": Timestamp(date: newMessage.timestamp)
        ])
    }

    // MARK: 특정 채팅방의 메시지들을 가져옴
    func fetchMessages(chatRoomId: String) async throws -> [Message] {
        let messagesRef = db.collection("chatRooms").document(chatRoomId).collection("messages")
        let snapshot = try await messagesRef
            .order(by: "timestamp", descending: false)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: Message.self)
        }
    }
}

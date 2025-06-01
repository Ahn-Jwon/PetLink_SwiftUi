import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

@MainActor
class ChatViewModel: ObservableObject {
    @Published var chatRooms: [ChatRoom] = []
    @Published var messages: [Message] = []
    @Published var chatNotificationCount: Int = 0  // 채팅 알림 개수
    
    private let chatService = ChatService()
    private var listener: ListenerRegistration?
    private let db = Firestore.firestore()
    
    // MARK: - Chat Room Operations
    
    /// 사용자의 채팅방 목록을 불러옴
    func loadUserChatRooms(for userId: String) async {
        do {
            let rooms = try await chatService.fetchUserChatRooms(userId: userId)
            self.chatRooms = rooms
        } catch {
            print("채팅방 목록 불러오기 실패: \(error)")
        }
    }
    
    /// 두 사용자 간의 기존 채팅방이 있으면 리턴하고, 없으면 새로 생성합니다.
    func getOrCreateChatRoom(userId: String, otherUserId: String, usernames: [String]) async throws -> ChatRoom {
        if let existingRoom = try await chatService.fetchExistingChatRoom(userId: userId, otherUserId: otherUserId) {
            return existingRoom
        } else {
            return try await chatService.createChatRoom(userId: userId, otherUserId: otherUserId, usernames: usernames)
        }
    }
    
    /// 특정 채팅방에 참여
    func joinChatRoom(userId: String, chatRoomId: String) async {
        do {
            try await chatService.joinChatRoom(userId: userId, chatRoomId: chatRoomId)
        } catch {
            print("채팅방 참여 실패: \(error)")
        }
    }
    
    // MARK: - Message Operations
    
    /// 채팅방의 기존 메시지를 한 번 불러옴
    func loadMessages(chatRoomId: String) async {
        do {
            let msgs = try await chatService.fetchMessages(chatRoomId: chatRoomId)
            self.messages = msgs
        } catch {
            print("메시지 불러오기 실패: \(error)")
        }
    }
    
    /// 채팅방의 메시지를 실시간으로 리스닝
    func listenToMessages(chatRoomId: String) {
        // 기존 리스너 제거
        listener?.remove()
        let messagesRef = db.collection("chatRooms").document(chatRoomId).collection("messages")
        listener = messagesRef.order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("메시지 리스닝 에러: \(error)")
                    return
                }
                guard let snapshot = snapshot else { return }
                let updatedMessages = snapshot.documents.compactMap { doc in
                    try? doc.data(as: Message.self)
                }
                self?.messages = updatedMessages
                // 새 메시지가 도착하면, 본인이 보낸 메시지가 아닐 경우 알림 카운트 증가 및 로컬 알림 전송
                                if let lastMessage = updatedMessages.last,
                                   lastMessage.senderId != Auth.auth().currentUser?.uid {
                                    self?.chatNotificationCount += 1
                                    self?.scheduleLocalNotification(title: "새 메시지", body: lastMessage.text)
                                }
                            }
                    }
    
    /// 실시간 리스너를 제거
    func removeListener() {
        listener?.remove()
        listener = nil
    }
    
    /// 채팅방에 메시지를 전송
    func sendMessage(chatRoomId: String, text: String) async {
        do {
            try await chatService.sendMessage(chatRoomId: chatRoomId, text: text)
        } catch {
            print("메시지 전송 실패: \(error)")
        }
    }
    
    // MARK: - 로컬 알림 스케줄링
    func scheduleLocalNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("알림 예약 에러: \(error)")
            }
        }
    }
}

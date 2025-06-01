//
//  UserService.swift
//  Pet
//
//  Created by 안재원 on 2/5/25.
//

import Foundation
import FirebaseFirestore

///```
///유저 인증 서비스 (사용자 서비스) 사용자 가져오기
///이것을 이용해서 인증서비스에서 실제로 사용자를 검색할 수 있다.
///firebase와 통신을 수행하는건 일반 API를 URL 연결하는 것 과 비슷하다.
///백엔드와 통신하는 곳
///```
struct UserService {
    @MainActor
    static func fetchUser(withUid uid: String) async throws -> User {  //  async throws -> User : 유저를 반환한다.
        let snapshot = try await Firestore.firestore().collection(COLLERCTION_USER).document(uid).getDocument()
        return try snapshot.data(as: User.self)
    }
    
    
    ///```
    ///사용자 유형의 사용자를 기반으로 스와이프 카드 사용자를 가져온다.
    ///필터를 걸어서 사용자의 스와이프 카드 사용자를 가져오는 것
    ///비동기식
    ///```

    
    ///```
    ///싫어요 기능에 대한 서비스
    ///user1은 나 자신이고, user2는 싫어하는 사용자
    ///왼쪽으로 스와이프 하면 싫어하는 사용자로 추가
    ///```
    @MainActor
    static func onDislike(user1: User, user2: User) {
        Firestore.firestore().collection(COLLERCTION_USER).document(user1.id)
            .updateData(["swipesLeft": FieldValue.arrayUnion([user2.id])])
    }
    
    
    ///```
    ///좋아요 기능에 대한 서비스
    ///일치하는 항목이 있으면 chat유형의 개체를 만들어 다른 개체에 배치
    ///그리고 id를 검색하여 채팅방을 만들기
    ///```
//    @MainActor
//    static func onLike(user1: User, user2: User, onMatch: () -> ()) {
//        let match = user2.swipesRight.contains(user1.id)
//        let u1 = Firestore.firestore().collection(COLLERCTION_USER).document(user1.id)
//        let u2 = Firestore.firestore().collection(COLLERCTION_USER).document(user2.id)
//        if !match {
//            u1.updateData(["swipesRight": FieldValue.arrayUnion([user2.id])])
//        } else {
//            onMatch()
//            u2.updateData(["swipesRight": FieldValue.arrayRemove([user1.id])])                      // 이미 존재하는 데이터는 삭제한다.
//            u1.updateData(["matches": FieldValue.arrayUnion([user2.id])])
//            u2.updateData(["matches": FieldValue.arrayUnion([user1.id])])
//            
//            let chatKey = Firestore.firestore().collection(COLLERCTION_CHAT).document().documentID  // id를 검색하면 채팅 데이타 채팅과 같다고 말할 수 있다.
//            let chatData = Chat(id: chatKey, user1: user1, user2: user2)
//            guard let encodedChat = try? Firestore.Encoder().encode(chatData) else { return }
//            Firestore.firestore().collection(COLLERCTION_CHAT).document(chatKey).setData(encodedChat)
//        }
//    }
}

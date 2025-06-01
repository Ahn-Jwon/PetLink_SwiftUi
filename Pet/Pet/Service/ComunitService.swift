//
//  ComunitService.swift
//  Pet
//
//  Created by 안재원 on 3/14/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

import PhotosUI

class CommunityService: ObservableObject {
    
    private let db = Firestore.firestore()
    
    @MainActor
    // 게시글 생성
    func createPost(username: String, title: String, content: String, image: UIImage?, location: CLLocationCoordinate2D?) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "로그인 필요"])
        }
        
        // Firestore에서 사용자 정보 조회
        let userDocRef = db.collection("user").document(uid)
        let userSnapshot = try await userDocRef.getDocument()
        let username = userSnapshot.data()?["name"] as? String ?? "익명 사용자"

        // 이미지 업로드 (Firebase Storage 사용)
        var imageUrl: String? = nil
        if let image = image {
            imageUrl = try await ImageUploader.uploadImage(image: image)
        }

        // 현재 위치 주소 변환 (역지오코딩)
        let address = try await getAddress(from: location)

        // Firestore에 저장할 데이터 준비
        let postData: [String: Any] = [
            "userId": uid,
            "username": username,
            "title": title,
            "content": content,
            "imageUrl": imageUrl ?? "",
            "latitude": location?.latitude ?? 0.0,
            "longitude": location?.longitude ?? 0.0,
            "address": address, // 위치 주소 추가
            "timestamp": Timestamp()
        ]
        
        // Firestore에 저장
        let docRef = db.collection(COLLERCTION_COMMUNITY).document()
        try await docRef.setData(postData)
    }
    
    // Firestore에서 게시글 목록 가져오기
    func fetchPosts() async throws -> [Community] {
        let snapshot = try await db.collection(COLLERCTION_COMMUNITY)
            .order(by: "timestamp", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            let data = document.data()
            return Community(
                id: document.documentID,
                username: data["username"] as? String ?? "",
                userId: data["userId"] as? String ?? "",
                title: data["title"] as? String ?? "",
                content: data["content"] as? String ?? "",
                imageUrl: data["imageUrl"] as? String,
                latitude: data["latitude"] as? Double,
                longitude: data["longitude"] as? Double,
                address: data["address"] as? String, // 주소 정보 추가
                timestamp: data["timestamp"] as? Timestamp ?? Timestamp()
            )
        }
    }
    // AIzaSyDgkxrepywZneifmPOh7Nzq-q0-HcN8WJk
    // 구글 역지오코딩 API 사용하여 위치 좌표를 주소로 변환
    private func getAddress(from location: CLLocationCoordinate2D?) async throws -> String {
        guard let location = location else { return "위치 정보 없음" }
        let apiKey = "AIzaSyDgkxrepywZneifmPOh7Nzq-q0-HcN8WJk" // 🔹 본인의 API 키 입력
        let urlString = "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(location.latitude),\(location.longitude)&key=\(apiKey)"
        
        guard let url = URL(string: urlString) else { return "주소 변환 실패" }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        if let results = json?["results"] as? [[String: Any]],
           let firstResult = results.first,
           let addressComponents = firstResult["address_components"] as? [[String: Any]] {

            var city = ""
            var district = ""

            for component in addressComponents {
                if let types = component["types"] as? [String] {
                    if types.contains("locality") { // 🔹 도시명 (예: Hachioji)
                        city = component["long_name"] as? String ?? ""
                    } else if types.contains("sublocality") { // 🔹 지역명 (예: Katakuramachi)
                        district = component["long_name"] as? String ?? ""
                    }
                }
            }

            return "\(district), \(city)" // 🔹 예: "Katakuramachi, Hachioji"
        }
        
        return "주소 정보 없음"
    }
    
    /// 🔹 댓글 가져오기
    func fetchComments(for boardId: String) async throws -> [Comment] {
        let snapshot = try await db.collection("comments")
            .whereField("boardId", isEqualTo: boardId)
            .order(by: "timestamp", descending: false)
            .getDocuments()
        return snapshot.documents.compactMap { doc in
            let data = doc.data()
            return Comment(
                id: doc.documentID,
                boardId: data["boardId"] as? String ?? "",
                userId: data["userId"] as? String ?? "",
                userName: data["userName"] as? String ?? "익명",
                content: data["content"] as? String ?? "",
                timestamp: (data["timestamp"] as? Timestamp) ?? Timestamp()
            )
        }
    }
    
    /// 🔹 댓글 추가하기
    func addComment(to boardId: String, userId: String, userName: String, content: String) async throws {
        let newComment = [
            "boardId": boardId,
            "userId": userId,
            "userName": userName,
            "content": content,
            "timestamp": Timestamp()
        ] as [String: Any]
        
        try await db.collection("comments").addDocument(data: newComment)
    }
    
    
    
    //  오늘 날짜의 게시글만 가져오기
    func fetchTodayPosts() async throws -> [Community] {
        let today = Date()
        let calendar = Calendar.current
        
        //  오늘 날짜의 시작과 끝 (00:00 ~ 23:59)
        let startOfDay = calendar.startOfDay(for: today)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let snapshot = try await db.collection(COLLERCTION_COMMUNITY)
            .whereField("timestamp", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("timestamp", isLessThan: Timestamp(date: endOfDay))
            .order(by: "timestamp", descending: true) // 최신 글 순서
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            let data = document.data()
            return Community(
                id: document.documentID,
                username: data["username"] as? String ?? "",
                userId: data["userId"] as? String ?? "",
                title: data["title"] as? String ?? "",
                content: data["content"] as? String ?? "",
                imageUrl: data["imageUrl"] as? String,
                latitude: data["latitude"] as? Double,
                longitude: data["longitude"] as? Double,
                timestamp: data["timestamp"] as? Timestamp ?? Timestamp()
            )
        }
    }
    
    //  오늘 날짜 게시글 개수 가져오기
    func fetchTodayPostCount() async throws -> Int {
        let today = Date()
        let calendar = Calendar.current
        
        //  오늘 날짜의 시작과 끝 (00:00 ~ 23:59)
        let startOfDay = calendar.startOfDay(for: today)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let querySnapshot = try await db.collection(COLLERCTION_COMMUNITY)
            .whereField("timestamp", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("timestamp", isLessThan: Timestamp(date: endOfDay))
            .getDocuments()
        
        return querySnapshot.documents.count  // ✅ 게시글 개수 반환
    }
    
    
    @MainActor
    //  UPDATE (게시글 수정)
    func updatePost(postId: String, title: String?, content: String?) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { throw NSError(domain: "AuthError", code: -1, userInfo: nil) }
        
        var updateData: [String: Any] = [:]
        if let title = title { updateData["title"] = title }
        if let content = content { updateData["content"] = content }
        
        let docRef = db.collection("community").document(postId)
        let docSnapshot = try await docRef.getDocument()
        
        if let data = docSnapshot.data(), let ownerId = data["userId"] as? String, ownerId == uid {
            try await docRef.updateData(updateData)
        } else {
            throw NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "게시글 수정 권한 없음"])
        }
    }
    
    //  DELETE (게시글 삭제)
    @MainActor
    func deletePost(postId: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let docRef = db.collection("community").document(postId)
        let docSnapshot = try await docRef.getDocument()
        
        if let data = docSnapshot.data(), let ownerId = data["userId"] as? String, ownerId == uid {
            try await docRef.delete()
        } else {
            throw NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "게시글 삭제 권한 없음"])
            
        }
    }
}



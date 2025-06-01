//
//  CommunityViewModel.swift
//  Pet
//
//  Created by 안재원 on 3/14/25.
//


import Foundation
import SwiftUI
import Combine
import CoreLocation
import FirebaseCore

class CommunityViewModel: ObservableObject {
    
    private let communitydService = CommunityService()
    @Published var comments: [Comment] = []
    @Published var posts: [Community] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var todayPostCount: Int = 0  //  오늘 게시글 개수 저장
    
    
    
    // 전체 게시글 목록 가져오기
    @MainActor
    func fetchPosts() async {
        isLoading = true
        errorMessage = nil
        do {
            posts = try await communitydService.fetchPosts()
            print("이건가?")
        } catch {
            errorMessage = "게시글 목록 가져오기 실패: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    // 오늘 날짜 게시글만 가져오기
    @MainActor
    func fetchTodayPosts() async {
        isLoading = true
        errorMessage = nil
        do {
            posts = try await communitydService.fetchTodayPosts()
        } catch {
            errorMessage = "게시글 목록 가져오기 실패: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    //  오늘 등록된 게시글 개수 가져오기
    @MainActor
    func fetchTodayPostCount() async {
        do {
            let count = try await communitydService.fetchTodayPostCount()
            self.todayPostCount = count // ✅ UI 업데이트
        } catch {
            print("Error fetching today's post count: \(error)")
        }
    }
    
    
    // 게시글 삭제
    @MainActor
    func deletePost(postId: String) async -> Bool {
        isLoading = true
        defer { isLoading = false } // isLoading을 항상 false로 설정

        do {
            try await communitydService.deletePost(postId: postId)
            await fetchPosts()  // 게시글 목록을 갱신
            print("게시글 삭제 성공")
            return true
        } catch {
            errorMessage = "게시글 삭제 실패: \(error.localizedDescription)"
            print("게시글 삭제 실패")
            return false
        }
    }

    
    /// 🔹 댓글 가져오기
    func loadComments(for boardId: String) {
        Task {
            do {
                let fetchedComments = try await communitydService.fetchComments(for: boardId)
                DispatchQueue.main.async {
                    self.comments = fetchedComments
                }
            } catch {
                print("댓글 불러오기 실패: \(error.localizedDescription)")
            }
        }
    }
    
    /// 🔹 댓글 추가하기
    func addComment(to boardId: String, userId: String, userName: String, content: String) {
        Task {
            do {
                try await communitydService.addComment(to: boardId, userId: userId, userName: userName, content: content)
                await loadComments(for: boardId)  // 댓글 추가 후 다시 불러오기
            } catch {
                print("댓글 추가 실패: \(error.localizedDescription)")
            }
        }
    }
}



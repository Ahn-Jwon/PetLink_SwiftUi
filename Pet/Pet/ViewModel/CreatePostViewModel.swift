
import Foundation
import UIKit
import CoreLocation

class CreatePostViewModel: ObservableObject {
    private let boardService = BoardService()
    
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    // MARK: 게시글 작성
    @MainActor
    func createPost(username: String, title: String, content: String, image: UIImage?, location: CLLocationCoordinate2D?) async {
        isLoading = true
        errorMessage = nil
        do {
            try await boardService.createPost(username: username, title: title, content: content, image: image, location: location)
        } catch {
            errorMessage = "게시글 작성 실패: \(error.localizedDescription)"
        }
        isLoading = false
    }
}


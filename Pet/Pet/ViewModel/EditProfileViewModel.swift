//
//  EditProfileViewModel.swift
//  Pet
//
//  Created by 안재원 on 2/5/25.
//

import Foundation
import PhotosUI     // 이미지를 가져오기 위해
import SwiftUI
import Firebase



class EditProfileViewModel: ObservableObject {
    @Published var user: User
    @Published var selectedImage: PhotosPickerItem? {
        didSet {
            Task {
                await loadImageFromItem(item: selectedImage)
            }
        }
    }
    @Published var profileImage: Image?
    private var uiImage: UIImage?
    
    // 이름, 성별, 나이등에 대한 매개변수
    // 편집기능에 사용될 매개변수들
    @Published var name: String
    @Published var profileImageUrl: String
    @Published var bio: String
    @Published var age: Int
    @Published var gender = PetGender.unspecifide
    @Published var preference = PetGender.unspecifide
    @Published var interests: Set<String> = []
    
    // 편집기능 초기화
    // 기본값은 User의 정보
    init(user: User) {
        self.user = user
        self.name = user.name
        self.bio = user.bio ?? ""
        self.age = user.age ?? 18
        self.gender = PetGender.fromString(str: user.gender)
        self.preference = PetGender.fromString(str: user.preference)
        self.profileImageUrl = user.profileImageUrl ?? ""
        self.interests = Set(user.interests)
    }
    
    ///```
    ///현재 이미지 불러오기
    ///```
    @MainActor
    func loadImageFromItem(item: PhotosPickerItem?) async {
        guard let item = item else {return }
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        guard let uiImage = UIImage(data: data) else { return }
        self.uiImage = uiImage                                  // 로컬에 이미지 저장
        self.profileImage = Image(uiImage : uiImage)            // 프로필이미지 인스턴스 화 -> ViewModel로 전달됨.
    }
    
    ///```
    ///프로필 수정 업데이트
    ///```
    @MainActor
    func updateUserData() async throws {
        var data = [String: Any]()
        
        if let uiImage = uiImage {
            if let imageUrl = try? await ImageUploader.uploadImage(image: uiImage) {
                data["profileImageUrl"] = imageUrl
            } else {
                print("Image upload returned nil") //왜 닐값이 뜨지?
            }
        }

        data["bio"] = bio
        data["age"] = age
        data["gender"] = gender.rawValue
        data["preference"] = preference.rawValue
        data["interests"] = Array(interests)
        
        try await Firestore.firestore().collection("user").document(user.id).updateData(data)
        try await AuthService.shared.fetchUser()
    }
    
}


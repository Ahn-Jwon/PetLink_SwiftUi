//
//  AuthViewModel.swift
//  Pet
//
//  Created by 안재원 on 2/5/25.
//

import SwiftUI
import PhotosUI
import Foundation
import Combine //두개의 변수를 결헙하기 위해

///```
///회원가입 및 로그인 ViewModel (Auth)
///```
@MainActor // 메인스레드에서 실행하도록 만든 것
class AuthViewModel: ObservableObject {
    
    private var auth = AuthService.shared                                        // 이것을 통해 Firebase인증과 통신할 수 있다.
    @Published var email = ""                                                    // Email
    @Published var password = ""                                                 // Password
    @Published var name = ""                                                     // name
    @Published var age = 18                                                      // age
    @Published var gender: PetGender = .unspecifide                           // 성별
    @Published var preference: PetGender = .unspecifide                       // 관심항목
    @Published var bio = ""                                                      // 자기 소개 글
    @Published var interests: Set<String> = []                                   // 관심사를 문자열로
    
    @Published var isLoading = AuthService.shared.isLoading
    private var cancellables = Set<AnyCancellable>()
    @Published var errorEvent = AuthService.shared.errorEnent                   // error 이벤트
    @Published var currentUser = AuthService.shared.currentUser                 // 현재 사용자 세션
    
    @Published var signupFlowActive = AuthService.shared.signupFlowActive
    
    @Published var selectedImage: PhotosPickerItem? {                           // SelectImage 선택한 이미지가 기능을 수행하도록
        didSet {                                                                // 선택한 이미지를 설정하면 이것이 실행된다.
            Task {
                await auth.loadImageFromItem(item: selectedImage)
            }
        }
    }
    @Published var profileImage = AuthService.shared.profileImage               // ProfileImage
    
    
    init() {
//        auth.signout()
        setupSubscribers() // 구독자를 설정하고 정의해야하는 초기화작업
    }
    
    
    ///```
    ///인증 서비스에 로드되는 것을 받고 자체 로컬에 동기화
    ///```
    func setupSubscribers() {
        auth.$isLoading.sink { [weak self] isLoading in
            self?.isLoading = isLoading
        }
        .store(in: &cancellables)
        
        auth.$errorEnent.sink { [weak self] errorEvent in                    // 에러 이벤트 동기화 시키기
            self?.errorEvent = errorEvent
        }
        .store(in: &cancellables)
                
        auth.$currentUser.sink { [weak self] currentUser in                 // 로그인한 사용자의 세션을 로컬에 동기화 시키기
            self?.currentUser = currentUser
        }
        .store(in: &cancellables)
        
        auth.$signupFlowActive.sink { [weak self] signupFlowActive in       // 가입 흐름 (스와이프로 이동할지 말지 결정)
            self?.signupFlowActive = signupFlowActive
        }
        .store(in: &cancellables)
        
        auth.$profileImage.sink { [weak self] profileImage in       //      profileImage 인증
            self?.profileImage = profileImage
        }
        .store(in: &cancellables)
    }
    
    
    ///```
    ///회원가입 ViewModel Function
    ///서비스와 ViewModel을 연결하였다.
    ///비동기처리를 위해 async throws 사용
    ///```
    func register(onComplete: () -> ()) async throws {
        await auth.register(withEmail: email, name: name, password: password, onComplete: onComplete)
        email = ""
        password = ""
        name = ""
    }
    
    
    ///```
    ///로그인 ViewModel Function
    ///서비스와 ViewModel을 연결하였다.
    ///비동기처리를 위해 async throws 사용
    ///```
    func login() async throws {
        await auth.login(withemail: email, password: password)
        email = ""
        password = ""
    }
    
    
    func skipRegisterationFlow() {
        signupFlowActive = false
    }
    
    
    ///```
    ///이미지 업로드 서비스와 ViewModel연결
    ///```
    func uploadUserImage() async throws {
        await auth.uploadUserImage()
    }
    
    
    ///```
    /// completRegistrationFlow 서비스와 연결
    ///```
    func completRegistrationFlow() async throws {
        await auth.completRegistrationFlow(age: age, bio: bio, gender: gender, preference: preference, interests: interests)
        // 이것이 실행되면 빈 문자열로 재설정
        // 재설정 이유는 로그아웃했다가 다른 사용자로 다시 로그인 하면 초기화 하기 위함
        email = ""
        password = ""
        name = ""
        age = 18
        gender = .unspecifide
        preference = .unspecifide
        bio = ""
        interests = []
        selectedImage = nil
        profileImage = nil
    }
}

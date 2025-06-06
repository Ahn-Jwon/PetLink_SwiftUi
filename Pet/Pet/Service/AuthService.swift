import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth
import SwiftUI
import PhotosUI

class AuthService: ObservableObject  {
    
    static let shared = AuthService()
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorEnent = PetError(content: "", display: false)
    @Published var signupFlowActive = false
    @Published var profileImage: Image?
    private var uiImage: UIImage?
    
    init() {
        Task {
            try await fetchUser()
        }
    }
    
    
    
    // MARK: 회원가입 (인증) Service
    
    @MainActor
    func register(withEmail email: String, name: String, password: String, onComplete: () -> ()) async {
        isLoading = true // Loading 시작
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            
            // 사용자생성
            let uid = result.user.uid
            let user = User(id: uid, email: email, name: name)
            
            guard let encodedUser = try? Firestore.Encoder().encode(user) else {
                isLoading = false
                return
            }
            try? await Firestore.firestore().collection(COLLERCTION_USER).document(user.id).setData(encodedUser)
            self.currentUser = user
            signupFlowActive = true
            onComplete()
        } catch {
            print("DEBUG: Failer to register user with error \(error.localizedDescription)") // error 처리
            errorEnent = PetError(content: error.localizedDescription)
            signout() // 로그아웃
        }
            isLoading = false // Loading 마감
    }
    
    
    
    
    // MARK: 로그아웃 Service
    
    func signout() {
        userSession = nil
        currentUser = nil
        try? Auth.auth().signOut()
    }
    
    //MARK: 회원탈퇴 Service
    func deleteAccountAndUserData(completion: @escaping (Bool) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(false) // 사용자 정보 없음 → 실패 처리
            return
        }
        
        let uid = user.uid

        // 1. Firebase Auth에서 계정 삭제 시도
        user.delete { error in
            if let error = error {
                print("계정 삭제 실패: \(error.localizedDescription)")
                completion(false) // 실패 시 false 반환
            } else {
                print("계정이 성공적으로 삭제되었습니다.")
                
                // 2. Firestore에서 사용자 데이터 삭제
                let db = Firestore.firestore()
                db.collection("users").document(uid).delete { error in
                    if let error = error {
                        print("사용자 데이터 삭제 실패: \(error.localizedDescription)")
                    } else {
                        print("사용자 데이터가 성공적으로 삭제되었습니다.")
                    }
                    completion(true) // 성공 시 true 반환
                }
            }
        }
    }


    
    
  
    // MARK: 로그인 Service
    // MARK: Main에서 실행하도록 지정
  
    @MainActor
    func login(withemail email: String, password: String) async {
        isLoading = true
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            try await fetchUser()
        } catch { // Ligin 에러일 경우 메세지를 띄우고 로그아웃(sign) Function이 실행된다.
            print("DEBUG: Failed to login user with error \(error.localizedDescription)")
            errorEnent = PetError(content: error.localizedDescription)
            signout()
        }
        isLoading = false // 끝나면 로딩 종료
    }
    
    

    // MARK: 유저 검색 Service
    // MARK: 애플리케이션이 처음 실행할때 이 사용자 가져오기를 실행하고 검색
    @MainActor
    func fetchUser() async throws {
        userSession = Auth.auth().currentUser
        guard let uid = self.userSession?.uid else { return }
        currentUser = try await UserService.fetchUser(withUid: uid)
    }
    
    
 
    // MARK: UI Image를 인스턴스화하고 프로필로 설정
    @MainActor
    func loadImageFromItem(item: PhotosPickerItem?) async {
        guard let item = item else {return }
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        guard let uiImage = UIImage(data: data) else { return }
        self.uiImage = uiImage                                  // 로컬에 이미지 저장
        self.profileImage = Image(uiImage : uiImage)            // 프로필이미지 인스턴스 화 -> ViewModel로 전달됨.
    }
    
    
    
    // MARK: Image 저장하기 * 프로필 이미지 *
    @MainActor
    func uploadUserImage() async {
        guard let currentUser = currentUser else { return }
        
        //사용자가 있는지 확인하고 UI이미지가 UI이미지와 같도록
        do {
            if let uiImage = uiImage {
                let imageUrl = try? await ImageUploader.uploadImage(image: uiImage)
                let data = [
                    "profileImageUrl": imageUrl
                ]
                try await Firestore.firestore()
                    .collection(COLLERCTION_USER).document(currentUser.id).updateData(data)
            }
        } catch {
            print("DEBUG: Failed to upload image with error \(error.localizedDescription)")
            errorEnent = PetError(content: error.localizedDescription)
        }
    }
    
    
    
    // MARK: 개인 카테고리 저장 인증
    // 메인쓰레드에서 실행해야 하기때문에 @MainActor
    // 비동기 함수
    @MainActor
    func completRegistrationFlow(age: Int, bio: String, gender: PetGender, preference: PetGender, interests: Set<String>) async {
        //현재 사용자가 현재 사용자와 동일하도록 보호하고 그렇지 않으면 반환한다.
        //따라서 현재 사용자가 있으면 isloading플래그를 true로 설정
        guard let currentUser = currentUser else { return }
        isLoading = true
        
        do {
            let data = [
                "age": age,
                "bio": bio,
                "gender": gender.rawValue,
                "preference": preference.rawValue,
                "interests": Array(interests)
            ] as [String: Any]
            
            try await Firestore.firestore().collection(COLLERCTION_USER).document(currentUser.id).updateData(data)
            
            try await fetchUser()
        } catch {
            print("DEBUG: Failde to set data with error \(error.localizedDescription)")
            errorEnent = PetError(content: error.localizedDescription)
        }
        
        isLoading = false
        signupFlowActive = false
        profileImage = nil
        uiImage = nil
    }
}


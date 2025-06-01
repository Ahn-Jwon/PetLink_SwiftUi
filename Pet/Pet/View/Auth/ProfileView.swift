//
//  ProfileView.swift
//  Pet
//
//  Created by 안재원 on 2/5/25.
//

import SwiftUI

import SwiftUI
import Kingfisher

struct ProfileView: View {
    var user: User              // 현재사용자인지, 스와이프 카드 사용자 여부 체크
    var editMode = false       // 편집모드
    let numberOfPages = 3 // 보여줄 페이지 수
    @State private var currentIndex = 0 // 현재 페이지 인덱스 추적
    @Environment(\.dismiss) private var dismiss  // dismiss 환경 변수 추가 이전페이지 돌아가기
    @State private var showEditProfile = false  // true일때 상단에 오버레이를 펼친다.
    @State private var isLoggedOut = false
    
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .center) {
                    ZStack(alignment: .top) {
                        if let imageUrl = user.profileImageUrl { // 사용자의 프로필에 이미지가 있을 경우.
                            KFImage(URL(string: imageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.width, height: 250)
                                .clipShape(Circle()) // 원형으로 자르기
                        } else {
                            Image(systemName: "person.fill")
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.size.width, height: 450)
                                .background(.gray)
                                .foregroundStyle(.white)
                                .clipped()
                        }
                        //                    
                        //                    if editMode {
                        //                        Image(systemName: "pencil")
                        //                            .resizable()
                        //                            .padding()
                        //                            .background(.black)
                        //                            .foregroundStyle(.white)
                        //                            .frame(width: 70, height: 70)
                        //                            .containerShape(Circle())
                        //                            .offset(x: -30, y: 10)
                        //                            .onTapGesture {
                        //                                showEditProfile.toggle()
                        //                            }
                        //                    }
                    }
                    HStack {
//                        Text("Name :")
                        Text(user.name)
                            .font(.largeTitle)
                            .bold()
                        if let age = user.age {
                            Text(String(age))
                                .font(.title)
                        }
                        if user.gender.lowercased() == "man" {
                            // 남자 아이콘
                            Text("♂")
                                .font(.largeTitle)
                                .foregroundColor(.blue)
                        } else if user.gender.lowercased() == "woman" {
                            // 여자 아이콘
                            Text("♀")
                                .font(.largeTitle)
                                .foregroundColor(.pink)
                        } else {
                            // 알 수 없는 경우 기본 아이콘
                            Image(systemName: "questionmark")
                                .font(.largeTitle)
                        }
                        Spacer()
                    }
                    .padding()
                    
                    Divider()
                    HStack{
                        Text("About me")
                            .font(.title)
                            .padding()
                        Spacer()
                    }
                    if let bio = user.bio {
                        Text(bio)
                            .padding()
                    }
                    
                    Divider()
                    HStack {
                        Text("Interests")
                            .font(.title)
                            .padding()
                        Spacer()    
                    }
                    let gridItems: [GridItem] = [
                        .init(.flexible(), spacing: 1),
                        .init(.flexible(), spacing: 1),
                        .init(.flexible(), spacing: 1)
                    ]
                    
                    LazyVGrid(columns: gridItems, spacing: 10) {
                        ForEach(user.interests, id:\.self) { item in
                            Text("#\(item)")
                                .padding(8)
                                .foregroundStyle(.blue)
                                .background(.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                    .padding()
                    
                    VStack {
                        if editMode {
                            Button {
                                showEditProfile.toggle()
                            } label: {
                                Text("EditProfile")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .frame(width: 360, height: 44)
                                    .background(.blue)
                                    .cornerRadius(10)
                                    .foregroundStyle(.white)
                            }.buttonStyle(PlainButtonStyle()) // 🔹 기본 버튼 스타일 제거 (회색 배경 방지)
                        }
                        
                        Button {
                            AuthService.shared.deleteAccountAndUserData { success in
                                if success {
                                    isLoggedOut = true
                                }
                            }
                        } label: {
                            Text("Account Delete")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .frame(width: 360, height: 44)
                                .background(.red)
                                .cornerRadius(10)
                                .foregroundStyle(.white)
                        }.buttonStyle(PlainButtonStyle()) // 🔹 기본 버튼 스타일 제거 (회색 배경 방지)
                        
                        Button {
                            AuthService.shared.signout()
                        } label: {
                            Text("Sihn out")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .frame(width: 360, height: 44)
                                .background(.black)
                                .cornerRadius(10)
                                .foregroundStyle(.white)
                        }.buttonStyle(PlainButtonStyle()) // 🔹 기본 버튼 스타일 제거 (회색 배경 방지)
                        //                        Spacer()
                    }
                    .padding()
                }
            }
            //        .ignoresSafeArea(edges: [.bottom])
            //        .ignoresSafeArea()
            .fullScreenCover(isPresented: $showEditProfile) {
                EditProfileView(user: user)
            }
            .navigationDestination(isPresented: $isLoggedOut) {
                            LoginView() // 탈퇴 후 로그인 화면으로 이동
                        }
        }
    }
}


//extension ProfileView {
//    var ImageS: some View {
//        TabView(selection: $currentIndex) {
//            ForEach(0..<numberOfPages, id: \.self) { index in
//                if let profileImageUrl = user.profileImageUrl,
//                   let url = URL(string: profileImageUrl) {
//                    KFImage(url)
//                        .resizable()
//                        .scaledToFill()
//                        .frame(width: UIScreen.main.bounds.width, height: 350)
//                        .clipped()
//                        .tag(index)
//                } else {
//                    Image(systemName: "person.fill")
//                        .resizable()
//                        .scaledToFill()
//                        .frame(width: UIScreen.main.bounds.width, height: 350)
//                        .background(Color.gray)
//                        .foregroundColor(.white)
//                        .clipped()
//                        .tag(index)
//                }
//            }
//        }
//        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
//        .frame(height: 350)
//    }
//}



#Preview {
    ProfileView(user: User.mockUsers[0], editMode: true)
//    ProfileView(user: User.mockUsers[1])
}





//                            Image(systemName: "pencil")
//                                .resizable()
//                                .padding()
//                                .background(.black)
//                                .foregroundStyle(.white)
//                                .frame(width: 40, height: 70)
//                                .containerShape(Circle())
//                                .offset(x: 60, y:-5)
//                                .onTapGesture {
//                                    showEditProfile.toggle()
//                                }

//
//  MainView.swift
//  Pet
//
//  Created by 안재원 on 1/27/25.
//

import SwiftUI
import PhotosUI
import CoreLocation
import Kingfisher

struct MainView: View {
    var user: User              // 현재사용자인지 사용자 여부 체크
    @StateObject private var viewModel = BoardViewModel()  // ViewModel 사용
    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2) // 2열
    @StateObject private var lc = LocationManager()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {
                    ZStack(alignment: .top) { // 🔹 ZStack에 상단 정렬 추가
                        ImageSliderView()
                    }
                    HStack {
                        Spacer()
                        if let imageUrl = user.profileImageUrl { // 사용자의 프로필에 이미지가 있을 경우.
                            KFImage(URL(string: imageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50) // 원하는 크기로 조정
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
                        VStack {
                            NavigationLink(destination: ProfileView(user: user)) {
                                Text("\(user.name) Hello!")
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                                    .bold()
                            }
                            .buttonStyle(PlainButtonStyle())
//                            Text("\(user.name) Hello!")
//                                .foregroundStyle(colorScheme == .dark ? .white : .black)
//                                .bold()
                        }
                        Image(systemName: "bell.fill")
                            .font(.title2)
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                            .bold()
                    }
                    .padding()
                    HStack(spacing: 30) {
                        Spacer()
                        VStack {
                            NavigationLink(destination: CommunityView()) {
                                Image(colorScheme == .dark ? "mate_darkmode" : "Mate")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 70)
                                    .clipped()
                                    .cornerRadius(10)
                                    .padding(.horizontal)
//                                    .padding(.bottom, 3)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12) // 네모 박스 (둥근 모서리)
                                            .fill(Color.gray.opacity(0.1)) // 배경색 적용
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                            Text("Comunity")
                                .font(.caption)
                        }
                        VStack {
                            NavigationLink(destination: PetHospitalListView()) {
                                Image(colorScheme == .dark ? "hospital_darkmode" : "hospital")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 70)
                                    .clipped()
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12) // 네모 박스 (둥근 모서리)
                                            .fill(Color.gray.opacity(0.1)) // 배경색 적용
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                            Text("Hospital")
                                .font(.caption)
                        }
                        VStack {
                            NavigationLink(destination: BoardView()) {
                                Image(colorScheme == .dark ? "search_darkmode" : "search")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 70)
                                    .clipped()
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12) // 네모 박스 (둥근 모서리)
                                            .fill(Color.gray.opacity(0.1)) // 배경색 적용
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                            Text("Search")
                                .font(.caption)
                        }
                         Spacer()
                    }
                    Divider()
                    VStack{
                        Text("家族を探すペット")
                            .font(.subheadline)
                            .bold()
                    }
                    VStack {
                        Text("Today")
                            .bold()
                        Text("\(viewModel.todayPostCount)")
                    }
                    
                    LazyVGrid(columns: columns) {
                        ForEach(viewModel.posts) { item in
                            NavigationLink(destination: BoardDetailView(board: item)) { // 🔹 NavigationLink 적용
                                VStack(spacing: 0) {
                                    if let imageUrl = item.imageUrl, !imageUrl.isEmpty {
                                        KFImage(URL(string: imageUrl))
                                            .resizable()
                                            .frame(width: 150, height: 150)
                                            .clipped()
                                    }
                                        Text(item.address ?? "위치 없음")
                                            .font(.system(size: 10))
                                            .foregroundColor(.black)
                                            .padding(.horizontal)
                                        Spacer()
                                    
                                }
//                                .padding()
                            }
                            .buttonStyle(PlainButtonStyle()) // 🔹 기본 버튼 스타일 제거 (회색 배경 방지)
                        }
                    }
                }
                .onAppear {
                    Task {
                        await viewModel.fetchTodayPosts() // 오늘 날짜 데이터 목록
                        await viewModel.fetchTodayPostCount() // 오늘날짜 데이터 개수 가져오기
                    }
                }
            }
//            .ignoresSafeArea()
        }
    }
}












//                        if (viewModel.todayPostCount == 0) {
//                            Text("今日は家族を失ったペットがいません\n🐱🐶❤️")
//                                .font(.title2)
//                                .fontWeight(.semibold)
//                                .foregroundColor(.black)
//                                .multilineTextAlignment(.center)
//                                .padding()
//                        } else {
//                            Text("\(viewModel.todayPostCount)")
//                        }




//        .onAppear {
//            // 프로필 이미지 URL이 비어 있을 경우 Firestore 등에서 가져오는 로직
//            if editviewModel.profileImageUrl.isEmpty {
//                editviewModel.profileImageUrl
//            }
//        }
// 이건 추후에 프로필이미지를 배경 인덱스로 쓸것인지 코드
//extension MainView {
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



struct ImageSliderView: View {
    let images = ["Main01", "Main02", "Main03"] // 에셋에 저장된 이미지 리스트
    @State private var currentIndex = 0 // 현재 페이지 인덱스 추적
    
    var body: some View {
        VStack {
            TabView(selection: $currentIndex) {
                ForEach(0..<images.count, id: \.self) { index in
                    Image(images[index])
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width, height: 350)
                        .clipped()
                        .tag(index) // 페이지 인덱스 설정
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always)) // 페이지 인디케이터 활성화
            .frame(height: 350)
            
            // 페이지 인디케이터 (동그란 점 스타일)
//            HStack(spacing: 8) {
//                ForEach(0..<images.count, id: \.self) { index in
//                    Circle()
//                        .fill(index == currentIndex ? Color.primary : Color.gray.opacity(0.5))
//                        .frame(width: 8, height: 8)
//                }
//            }
//            .padding(.top, 8)
        }
    }
}





#Preview {
    MainView(user: User.mockUsers[0])
}

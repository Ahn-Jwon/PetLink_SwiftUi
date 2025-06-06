
import SwiftUI
import PhotosUI
import CoreLocation
import Kingfisher
  
struct CommunityView: View {

    @State  var searchText = ""
    @StateObject  var viewModel = CommunityViewModel() // ViewModel 사용
    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 1) // 2열 그리드
    @StateObject  var lc = LocationManager()
    @Environment(\.colorScheme) var colorScheme
    
    
    var filteredPosts: [Community] {
           if searchText.isEmpty {
               return viewModel.posts
           } else {
               return viewModel.posts.filter { post in
                   if let address = lc.currentAddress {
                    return address.contains(searchText)
                   }
                   return false
               }
           }
       }
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    self.Textfiled
                    Spacer()
                        }
                    }
                    .padding(.horizontal)
                    .padding()
            HStack {
                Text("主人を探してください")
                    .font(.system(size: 11))
                    .bold()
                    .padding(.horizontal)
                    .foregroundStyle(.gray)
                Spacer()
            }
                        Divider()
                        .frame(height: 1)
                        .background(Color.black)
                        .padding(.horizontal)
            HStack {
                Spacer()
                //
            }
            .padding(.horizontal)
                            ScrollView {
                                self.Board
                            }
                            .padding(.horizontal, 5)
            NavigationLink(destination: CommunityCreatePostView()) {
                Image(systemName: "plus")
                    .font(.title2)
                    .padding(10)
                    .bold()
                    .foregroundStyle(.black)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 8)) // 사각형 + 모서리 둥글게
            }
                    .onAppear {
                                Task {
                                    await viewModel.fetchPosts()
                                }
                            }
                        }
                    }
                }


extension CommunityView {
    var Textfiled: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("地域名で検索します", text: $searchText)
                .foregroundColor(.primary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
        )
    }
    
    var Board: some View {
        LazyVGrid(columns: columns) {
            ForEach(filteredPosts) { item in
                ZStack { // 컨테이너로 감싸서 NavigationLink와 분리
                    NavigationLink(destination: CommunityDetailView(community: item)) {
                        HStack(spacing: 0) {
                            VStack {
                                Spacer()
                                HStack {
                                    Text(item.title)
                                        .font(.headline)
                                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                                        .padding(.horizontal)
//                                    Text("댓글 수: \(viewModel.commentCount)") // 이렇게 사용하면 정상 작동
                                    Spacer()
                                }
                                Spacer()
                                HStack {
                                    Text(item.username)
                                        .font(.system(size: 13))
                                        .foregroundColor(.blue)
                                        .padding(.horizontal)
                                    if let timestamp = item.timestamp {
                                        Text(timestamp.dateValue().formatted(.dateTime))
                                            .font(.system(size: 11))
                                            .foregroundColor(.gray)
                                            .padding(.horizontal)
                                        Spacer()
                                    }
                                    Text(item.address ?? "X")
                                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                                        .font(.system(size: 10))
                                        .padding(.horizontal)
                                    Spacer()
                                    Image(systemName: "arrow.right")
                                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                                        .font(.system(size: 10))
                                }
                                Divider()
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .contextMenu {
                    Button("Edit") {
                        // 수정 기능 추가 가능
                    }
                }
            }
        }
        
    }
}


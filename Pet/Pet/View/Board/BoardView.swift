import SwiftUI
import PhotosUI
import CoreLocation
import Kingfisher
  
struct BoardView: View {
    @State  var searchText = ""
    @StateObject  var viewModel = BoardViewModel()
    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 1) 
    @StateObject  var lc = LocationManager()
    @Environment(\.colorScheme) var colorScheme
    
    
    var filteredPosts: [Board] {
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
            NavigationLink(destination: CreatePostView()) {
                Image(systemName: "plus")
                    .font(.title2)
                    .padding(10)
                    .bold()
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
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


extension BoardView {
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
                    NavigationLink(destination: BoardDetailView(board: item)) {
                        HStack(spacing: 0) {
                            if let imageUrl = item.imageUrl, !imageUrl.isEmpty {
                                KFImage(URL(string: imageUrl))
                                    .resizable()
                                    .frame(width: 100,height: 100)
                                    .clipped()
                            }
                            VStack {
                                Spacer()
                                HStack {
                                    Text(item.title)
                                        .font(.headline)
                                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                                        .padding(.horizontal)
                                    Spacer()
                                }
                                Spacer()
                                HStack {
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
                                }
                                HStack {
                                    Text("Read more")
                                        .foregroundColor(.gray)
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
                        .padding()
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


#Preview {
    BoardView()
}

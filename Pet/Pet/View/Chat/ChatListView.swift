import SwiftUI
import FirebaseAuth
import PhotosUI     // 이미지를 가져오기 위해
import Kingfisher


struct ChatListView: View {
    @StateObject var viewModel = ChatViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            self.info
//            .background(Color.white)
            .scrollContentBackground(.hidden) //  iOS 16 이상에서 List 배경 없애기
            .navigationTitle("")
            .onAppear {
                if let userId = authViewModel.currentUser?.id {
                    Task {
                        await viewModel.loadUserChatRooms(for: userId)
                    }
                }
            }
        }
        .background(colorScheme == .dark ? Color.black : Color.white)
    }
}

extension ChatListView {
    var info: some View {
        List(viewModel.chatRooms) { room in
            NavigationLink(destination: ChatRoomView(viewModel: viewModel, chatRoomId: room.id)) {
                HStack(spacing: 12) {
                    // 상대방 프로필 이미지 표시
                    if let currentUserId = authViewModel.currentUser?.id,
                       let profileImages = room.profileImageUrl,
                       let index = room.users.firstIndex(where: { $0 == currentUserId }),
                       profileImages.count == room.users.count {
                        
                        // 현재 사용자가 0번이면 파트너는 1번, 아니면 0번
                        let partnerProfileImageUrl = index == 0 ? profileImages[1] : profileImages[0]
                        
                        if let url = URL(string: partnerProfileImageUrl),
                           !partnerProfileImageUrl.isEmpty {
                            KFImage(url)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.fill")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                        }
                    } else {
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        // 상대방 username 표시
                        if let currentUserId = authViewModel.currentUser?.id,
                           let usernames = room.usernames,
                           let index = room.users.firstIndex(where: { $0 == currentUserId }),
                           usernames.count == room.users.count {
                            
                            let partnerUsername = (index == 0 ? usernames[1] : usernames[0])
                            Text(partnerUsername)
                                .font(.headline)
                        } else {
                            Text("알 수 없음")
                                .font(.headline)
                        }
                        
                        // 마지막 메시지와 시간 표시
                        HStack {
                            Text(room.lastMessage ?? "메시지가 없습니다.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Text(room.timestamp, style: .time)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }
}

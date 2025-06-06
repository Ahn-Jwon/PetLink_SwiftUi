
import SwiftUI
import Kingfisher
import FirebaseAuth

struct CommunityDetailView: View {
    let community: Community
    @StateObject var viewModel = BoardViewModel()
    @StateObject var chatviewModel = ChatViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State var newComment = ""
    @StateObject var lc = LocationManager()
    @Environment(\.colorScheme) var colorScheme

    
    // 내비게이션 방식으로 채팅방 이동을 위한 상태 변수
    @State private var isChatRoomActive: Bool = false
    @State private var currentChatRoomId: String?
    @State private var isCreatingChatRoom: Bool = false
    @State private var isDeleted = false
    
    @ViewBuilder
        var chatRoomDestination: some View {
            if let chatRoomId = currentChatRoomId {
                ChatRoomView(viewModel: chatviewModel, chatRoomId: chatRoomId)
            } else {
                Text("채팅방을 찾을 수 없습니다.")
            }
        }

    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    HStack {
                        Image(systemName: "dog.fill") // 사용자 아이콘 추가
                            .foregroundColor(.black)
                        Text(community.username)
                            .font(.body)
                            .foregroundColor(.gray)
                        Spacer()
                            .padding()
                    }
                    VStack(alignment: .leading, spacing: 10) {
                        if let imageUrl = community.imageUrl, !imageUrl.isEmpty {
                            KFImage(URL(string: imageUrl))
                                .resizable()
                                .scaledToFit()
                        }
                        HStack{
                            Text(community.address ?? "X")
                            
                            if let timestamp = community.timestamp {
                                Text(timestamp.dateValue().formatted(.dateTime))
                                    .font(.system(size: 11))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                                Spacer()
                            }
                        }.padding(.horizontal)
                        HStack {
                            self.boardTitle
                            Spacer()
                            self.Chatbutton //채팅 버튼 (내비게이션 링크로 전환)
                            NavigationLink(destination: chatRoomDestination,
                                           isActive: $isChatRoomActive,
                                           label: { EmptyView() })
                        
                        }
                        .padding(.horizontal)
                        .buttonStyle(PlainButtonStyle())
                        Divider()
                        self.boardConent
                        HStack {
                            Spacer()
                            self.DeleteAccountButton
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal)
                        Divider()
                        // 댓글 목록 등 나머지 뷰 내용...
                        Text("comment")
                            .font(.system(size: 12))
                            .padding(.top, 5)
                            .padding(.horizontal)
                            .foregroundColor(.gray)
                        ForEach(viewModel.comments) { comment in
                            VStack {
                                HStack {
                                    Text(comment.userName)
                                        .font(.subheadline)
                                        .bold()
                                    Text(comment.content)
                                        .font(.system(size: 16))
                                        .foregroundColor(.primary)
                                }
                                Text(comment.formattedDate)
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                    .padding(.leading, 15)
                            }
                            .padding(.horizontal)
                            .cornerRadius(8)
                        }
                    }
                }
                // 댓글 입력 필드
                HStack {
                    TextField("comment...", text: $newComment)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    Button(action: {
                        guard let boardId = community.id,
                              let user = authViewModel.currentUser else { return }
                        viewModel.addComment(
                            to: boardId,
                            userId: user.id,
                            userName: user.name,
                            content: newComment
                        )
                        newComment = ""
                    }) {
                        Text("OK")
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color.black)
                            .cornerRadius(8)
                    }
                    .disabled(newComment.isEmpty)
                    .buttonStyle(PlainButtonStyle())
                }
                .padding()
            }
            .onAppear {
                if let boardId = community.id {
                    viewModel.loadComments(for: boardId)
                }
            }

            .navigationDestination(isPresented: $isDeleted) {
                BoardView() // 게시글 삭제 후 BoardView로 이동
            }
            .navigationTitle("게시글 상세")
            .navigationTitle("게시글 상세")
        }
    }
}



extension CommunityDetailView {
    var boardTitle: some View {
        Text(community.title)
            .font(.title)
            .bold()
    }
    
    var boardConent: some View {
        Text(community.content)
            .font(.system(size: 16))
            .frame(width: 300, height: 300, alignment: .topLeading) // 상단 왼쪽 정렬
            .multilineTextAlignment(.leading) // 여러 줄일 경우 왼쪽 정렬 유지
            .foregroundStyle(colorScheme == .dark ? .white : .black)
            .padding(.horizontal)
    }
    
    var Chatbutton: some View {
        Button(action: {
            Task {
                isCreatingChatRoom = true
                do {
                    guard let currentUserId = Auth.auth().currentUser?.uid else { return }
                    // board.userId를 채팅 상대 id로 사용
                    let otherUserId = community.userId
                    let currentUserName = authViewModel.currentUser?.name ?? "Unknown"
                    let otherUserName = community.username
                    let usernames = [currentUserName, otherUserName]
                    print("채팅방 확인 시작")
                    
                    // 프로필 이미지 URL도 배열로 전달 (각각의 값이 nil일 경우 빈 문자열로 대체)
                    let currentUserProfileUrl = authViewModel.currentUser?.profileImageUrl ?? ""
                    // 기존 채팅방이 있으면 반환하고, 없으면 새로 생성
                    let chatRoom = try await chatviewModel.getOrCreateChatRoom(
                        userId: currentUserId,
                        otherUserId: otherUserId,
                        usernames: usernames
                    )
                    print("채팅방 획득: \(chatRoom.id)")
                    
                    // 양쪽 사용자의 chatList에 채팅방을 추가
                    try await chatviewModel.joinChatRoom(userId: currentUserId, chatRoomId: chatRoom.id)
                    print("현재 사용자 채팅방 참여 완료")
                    try await chatviewModel.joinChatRoom(userId: otherUserId, chatRoomId: chatRoom.id)
                    print("상대방 채팅방 참여 완료")
                    
                    DispatchQueue.main.async {
                        currentChatRoomId = chatRoom.id
                        isChatRoomActive = true
                        isCreatingChatRoom = false
                        print("UI 업데이트 완료: 채팅방 이동")
                        print("isChatRoomActive: \(isChatRoomActive), currentChatRoomId: \(String(describing: currentChatRoomId))")
                    }
                } catch {
                    print("채팅방 생성/검색 오류: \(error.localizedDescription)")
                    isCreatingChatRoom = false
                }
            }
        }) {
            Image(systemName: "message.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
                .foregroundStyle(colorScheme == .dark ? .white : .black)
        }
    }
    
    var DeleteAccountButton: some View {
        Group {
            if community.userId == authViewModel.currentUser?.id {
                Button(action: {
                    Task {
                        if let postId = community.id {
                            let success = await viewModel.deletePost(postId: postId)
                            if success {
                                DispatchQueue.main.async {
                                    isDeleted = true // 삭제 후 BoardView로 이동
                                }
                            }
                        }
                    }
                }) {
                    Image(systemName: "trash")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundColor(.red)
                }
            } else {
                EmptyView()
            }
        }
    }
}



#Preview {
    BoardView()
}

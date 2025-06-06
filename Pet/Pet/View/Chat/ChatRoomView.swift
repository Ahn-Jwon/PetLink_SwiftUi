
import SwiftUI

import SwiftUI
import FirebaseAuth
import PhotosUI     // 이미지를 가져오기 위해
import Kingfisher

struct ChatRoomView: View {
    @ObservedObject var viewModel: ChatViewModel
    let chatRoomId: String
    @EnvironmentObject var eviewModel: EditProfileViewModel // 환경객체
    
    @State private var messageText: String = ""
    
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(viewModel.messages) { message in
                        chat(for: message)
                    }
                }
                .padding()
            }
            // 메시지 입력 필드
            HStack {
                TextField("Message..", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minHeight: 30)
                Button("SEND") {
                    guard !messageText.isEmpty else { return }
                    Task {
                        try await viewModel.sendMessage(chatRoomId: chatRoomId, text: messageText)
                        messageText = ""
                    }
                }
            }
            .padding()
        }
        .navigationTitle("")
        .onAppear {
            Task {
                // 기존 메시지 불러오기
                await viewModel.loadMessages(chatRoomId: chatRoomId)
                // 실시간 리스너 등록
                viewModel.listenToMessages(chatRoomId: chatRoomId)
            }
        }
        .onDisappear {
            viewModel.removeListener()
        }
    }
}
 
extension ChatRoomView {
        
    func chat(for message: Message) -> some View {
        VStack(alignment: message.senderId == Auth.auth().currentUser?.uid ? .trailing : .leading, spacing: 4) {
            Text(message.senderName)
                .font(.caption)
                .foregroundColor(.gray)
            Text(message.timestamp.formatted(.dateTime.hour().minute()))
                .font(.caption)
                .foregroundColor(.gray)
            
            HStack(alignment: .bottom, spacing: 8) {
                if message.senderId == Auth.auth().currentUser?.uid {
                    Spacer()
                    Text(message.text)
                        .padding()
                        .background(Color.blue.opacity(0.7))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                    
                    // 본인 메시지의 프로필 이미지 표시
                    if let url = URL(string: message.senderProfileUrl), !message.senderProfileUrl.isEmpty {
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
                    // 타인 메시지의 프로필 이미지 표시
                    if let url = URL(string: message.senderProfileUrl), !message.senderProfileUrl.isEmpty {
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
                    
                    Text(message.text)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    Spacer()
                }
            }
        }
    }
}



struct ProfileImageView: View {
    let profileImageUrl: URL?
    let profileImage: Image?
    let imageSize: CGFloat
    
    var body: some View {
        if let profileImage = profileImage {
            profileImage
                .resizable()
                .frame(width: imageSize, height: imageSize)
                .clipShape(Circle())
        } else {
            RoundImageView(imageUrl: profileImageUrl?.absoluteString, imageSize: .small)
        }
    }
}

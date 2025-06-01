//
//  CreatePostView.swift
//  Pet
//
//  Created by 안재원 on 2/8/25.
//

import SwiftUI
import PhotosUI
import CoreLocation
import Kingfisher
import SwiftUI
import PhotosUI

struct CreatePostView: View {
    @StateObject private var viewModel = CreatePostViewModel()
    @StateObject private var locationManager = LocationManager()
    
    @State private var username = ""
    @State private var title = ""
    @State private var content = ""
    @State private var selectedImage: UIImage?
    @State private var selectedItem: PhotosPickerItem?
    
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        ScrollView {
            VStack {
                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipped()
                }
                
                TextField("Title", text: $title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextEditor(text: $content)
                    .frame(height: 200)
                    .padding()
                    .border(Color.gray, width: 0.5)
                
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Image(systemName: "camera")
                        .font(.title)
                        .foregroundColor(.black)
                }
                .onChange(of: selectedItem) { newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            selectedImage = image
                        }
                    }
                }
                
                Button(action: {
                    Task {
                        await viewModel.createPost(
                            username: username,
                            title: title,
                            content: content,
                            image: selectedImage,
                            location: locationManager.currentLocation
                        )
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Text("게시글 작성")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("게시글 작성")
        }
    }
}


#Preview {
    CreatePostView()
}

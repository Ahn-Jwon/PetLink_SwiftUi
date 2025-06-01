//
//  ImageUploder.swift
//  Pet
//
//  Created by 안재원 on 2/5/25.
//  이미지를 저장하느 코드는 상용코드이기때문헤 이해할 필요 없이 그냥 긁어와서 쓰자


import Foundation
import UIKit
import Firebase
import FirebaseStorage
 
struct ImageUploader {
    
    static func uploadImage(image: UIImage) async throws -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.2) else { return nil }
        let filename = NSUUID().uuidString
        let ref = Storage.storage().reference(withPath: "/images/\(filename)")
 
        let _ = try await ref.putDataAsync(imageData)
        let url = try await ref.downloadURL()
        return url.absoluteString
    }
}
	

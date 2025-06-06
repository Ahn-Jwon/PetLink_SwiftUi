
import SwiftUI
import Kingfisher   // 이미지 일부를 일분 백엔드 URL을 검색하기 때문이다.

enum ImageSize: CGFloat {
    case small = 36
    case medium = 48
    case large = 64
    case xlarge = 128
}

struct RoundImageView: View {
    let imageUrl: String?
    var imageSize: ImageSize = .small
    
    var body: some View {
        if let imageUrl = imageUrl {
            KFImage(URL(string: imageUrl))
                .resizable()
                .scaledToFill()
                .frame(width: imageSize.rawValue, height: imageSize.rawValue)
                .clipShape(Circle())
        } else {
            Image(systemName: "person")
                .resizable()
                .scaledToFit()
                .frame(width: imageSize.rawValue, height: imageSize.rawValue)
                .foregroundStyle(.white)
                .clipShape(Circle())
        }
    }
}


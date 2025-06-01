//
//  PetInterests.swift
//  Pet
//
//  Created by 안재원 on 2/5/25.
//

import Foundation

///```
///관심분야 지정 즉 카테고리
///```
enum PetInterests: String, CaseIterable {
    case squeakyToys     // 삑삑이 장난감
    case ballFetch       // 공 던지고 가져오기
    case catnip          // 캣닢(고양이)
    case scratchPosts    // 스크래처(고양이)
    case chewToys        // 씹는 장난감(강아지)
    case grooming        // 미용/그루밍(반려동물이 좋아하는 빗질 등)
    case napping         // 낮잠/휴식
    case exploring       // 주변 탐색(산책, 새로운 공간 살피기 등)
    case cuddling        // 껴안기/스킨십
    case treatTime       // 간식/맛있는 음식
    case puzzleToys      // 퍼즐 장난감
    case birdWatching    // 새 구경(창밖 보기 등)
    case runningAround   // 뛰어다니기
    case waterPlay       // 물놀이(물장난, 수영 등)
    case socializing     // 다른 동물이나 사람과 교류
}

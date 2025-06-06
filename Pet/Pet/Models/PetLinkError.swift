
import Foundation

///```
///Error 메시지 Model
///Error메세지는 Firebase API에서 제공되므로
///코드에서 내용을 만들필요는 없다 호출만 하면됨
///```
struct PetError {
    var content: String //에러 메시지
    var display = true  // 표시할지 말지 여부
}



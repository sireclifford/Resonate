import Foundation
import SwiftUI
import Combine

final class HymnDetailViewModel: ObservableObject {
    let hymn: Hymn
    
    @Published var fontSize: CGFloat = 18
    
    init(hymn: Hymn){
        self.hymn = hymn
    }
    
    func increaseFont(){
        fontSize = min(fontSize + 2, 28)
    }
    
    func decreaseFont(){
        fontSize = max(fontSize - 2, 14)
    }
}

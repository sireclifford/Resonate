import SwiftUI
struct HistoricalContextSection: View {
    
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            Text("Historical Context")
                .font(.custom("CormorantGaramond-SemiBold", size: 20))
            
            Text(text)
                .font(.custom("Avenir", size: 16))
                .lineSpacing(6)
        }
    }
}

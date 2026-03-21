import SwiftUI
struct HistoricalContextSection: View {
    
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            Text("Historical Context")
                .font(PremiumTheme.scaledSystem(size: 20, weight: .semibold, design: .serif))
            
            Text(text)
                .font(PremiumTheme.scaledSystem(size: 16, weight: .medium))
                .lineSpacing(6)
        }
    }
}

import SwiftUI

struct TheologicalThemeSection: View {
    
    let theme: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            Text("Theological Theme")
                .font(.custom("CormorantGaramond-SemiBold", size: 20))
            
            Text(theme)
                .font(.custom("Avenir", size: 15))
                .foregroundColor(.secondary)
        }
    }
}

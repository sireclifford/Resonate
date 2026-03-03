import SwiftUI

struct HymnCardBackground: View {
    
    let seed: Int
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        LinearGradient(
                        colors: palette,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .opacity(0.15)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var palette: [Color] {
        
        let baseHue = Double((seed * 37) % 360) / 360.0
        
        let hue1 = baseHue
        let hue2 = (baseHue + 0.12).truncatingRemainder(dividingBy: 1.0)
        
        let opacity = colorScheme == .dark ? 0.35 : 0.55
        
        return [
            Color(hue: hue1, saturation: 0.6, brightness: 0.9).opacity(opacity),
            Color(hue: hue2, saturation: 0.7, brightness: 0.85).opacity(opacity)
        ]
    }
}

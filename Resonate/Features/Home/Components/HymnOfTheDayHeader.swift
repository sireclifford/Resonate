import SwiftUI

struct HymnOfTheDayHeader: View {
    
    let index: HymnIndex
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // Header Label
            Text("Hymn of the Day")
                .font(.josefin(size: 14, weight: .semibold))
                .foregroundStyle(Color("BrandAccent"))
                .textCase(.uppercase)
            
            // Hymn Title
            Text("Hymn \(index.id)")
                .font(.josefin(size: 20, weight: .semibold))
            
            Text(index.title)
                .font(.josefin(size: 16))
                .foregroundStyle(.secondary)
                .lineLimit(2)
            
            // Call To Action
            HStack(spacing: 6) {
                Text("Open Now")
                    .font(.josefin(size: 14, weight: .medium))
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundStyle(Color("BrandAccent"))
            .padding(.top, 4)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ZStack {
                // Soft gold gradient base
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color("BrandAccent").opacity(0.08),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Glass layer
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color("BrandAccent")
                    .opacity(colorScheme == .dark ? 0.5 : 0.2),
                lineWidth: 1)
        )
        .shadow(
            color: colorScheme == .dark
                    ? Color("BrandAccent").opacity(0.15)
                    : Color.black.opacity(0.05),
                radius: colorScheme == .dark ? 20 : 8,
                x: 0,
                y: 10
        )
    }
}

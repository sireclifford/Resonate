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
            
            // Hymn Number
            Text("Hymn \(index.id)")
                .font(.josefin(size: 20, weight: .semibold))
            
            // Hymn Title
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
                // Soft gradient under glass
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color("BrandAccent").opacity(colorScheme == .dark ? 0.18 : 0.10),
                                Color("BrandAccent").opacity(colorScheme == .dark ? 0.05 : 0.03)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Glass layer
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        colorScheme == .dark
                        ? AnyShapeStyle(.ultraThinMaterial)
                        : AnyShapeStyle(Color("BrandAccent").opacity(0.06))
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color("BrandAccent").opacity(0.5), lineWidth: 1)
        )
        .shadow(
            color: Color("BrandAccent").opacity(colorScheme == .dark ? 0.22 : 0.0),
            radius: 18,
            x: 0,
            y: 0
        )
        .shadow(
            color: Color.black.opacity(colorScheme == .dark ? 0.35 : 0.08),
            radius: colorScheme == .dark ? 20 : 6,
            x: 0,
            y: 8
        )
    }
}

import SwiftUI

struct CategoryCardView: View {
    let category: HymnCategory
    let count: Int

    var body: some View {
        ZStack {
            // Soft background icon
            Image(systemName: "sparkles")
                .font(.system(size: 60, weight: .regular))
                .foregroundColor(Color("BrandAccent").opacity(0.06))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(12)

            VStack(alignment: .leading, spacing: 6) {
                Text(category.title)
                    .font(.josefin(size: 17, weight: .semibold))

                Text("\(count) Hymns")
                    .font(.josefin(size: 12))
                    .foregroundColor(.secondary.opacity(0.75))
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color("BrandAccent").opacity(0.15), lineWidth: 1)
        )
        .shadow(
            color: Color.black.opacity(0.05),
            radius: 8,
            y: 4
        )
    }
}

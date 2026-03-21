import SwiftUI

struct ScriptureSection: View {
    
    let references: [ScriptureReference]
    let versionId: Int
    
    @State private var expandedReference: ScriptureReference?
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        StorySectionContainer(title: "Scripture References") {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(references.enumerated()), id: \.offset) { _, reference in
                    VStack(alignment: .leading, spacing: 10) {
                        Button {
                            withAnimation(.easeInOut) {
                                expandedReference = expandedReference == reference ? nil : reference
                            }
                        } label: {
                            HStack {
                                Text(reference.displayName)
                                    .font(PremiumTheme.scaledSystem(size: 16, weight: .semibold, design: .serif))
                                    .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))
                                
                                Spacer()
                                
                                Image(systemName: expandedReference == reference ? "chevron.up" : "chevron.down")
                                    .font(PremiumTheme.scaledSystem(size: 12, weight: .semibold))
                                    .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(PremiumTheme.subtleFill(for: colorScheme))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(PremiumTheme.border(for: colorScheme), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        
                        if expandedReference == reference {
                            ScriptureView(
                                reference: reference,
                                bibleID: versionId
                            )
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(PremiumTheme.subtleFill(for: colorScheme))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(PremiumTheme.border(for: colorScheme), lineWidth: 1)
                            )
                        }
                    }
                }
            }
        }
    }
}

import SwiftUI

struct ScriptureSection: View {
    
    let references: [ScriptureReference]
    let versionId: Int
    
    @State private var expandedReference: ScriptureReference?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            Text("Scripture References")
                .font(.custom("CormorantGaramond-SemiBold", size: 20))
            
            ForEach(Array(references.enumerated()), id: \.offset) { _, reference in
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    Button {
                        withAnimation(.easeInOut) {
                            expandedReference = expandedReference == reference ? nil : reference
                        }
                    } label: {
                        Text(reference.displayName)
                            .font(.custom("Avenir", size: 15))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: expandedReference == reference ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    
                    if expandedReference == reference {
                        ScriptureView(
                            reference: reference,
                            bibleID: versionId
                        )
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.secondarySystemBackground))
                        )
                    }
                }
            }
        }
    }
}

import SwiftUI

struct VerseView: View {
    
    let title: String
    let lines: [String]
    let fontSize: ReaderFontSize
    let fontFamily: ReaderFontFamily
    let lineSpacing: ReaderLineSpacing
    let showVerseNumbers: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            if showVerseNumbers {
                Text(title)
                    .font(fontFamily.font(ofSize: 14))
                    .foregroundColor(.secondary)
            }
            
            Text(lines.joined(separator: "\n"))
                .font(fontFamily.font(ofSize: fontSize.value))
                .lineSpacing(lineSpacing.value)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
}

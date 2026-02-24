import SwiftUI

struct CreditsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                
                // MARK: App Identity
                VStack(spacing: 12) {
                    
                    Image(systemName: "checkmark.seal.text.page")
                        .font(.system(size: 48))
                        .foregroundStyle(.primary)
                    
                    Text("Resonate")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Seventh-day Adventist Hymnal Companion")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Text(" \(Bundle.main.appVersion)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
                
                // MARK: Development
                section(
                    title: "Development",
                    icon: "hammer.fill",
                    content: """
                    Designed and developed by Clifford Owusu.
                    
                    Resonate is built to provide structured hymn access,
                    tune playback, scripture integration, and historical context
                    in a modern, searchable format.
                    """
                )
                
                Divider()
                
                // MARK: Hymn Stories
                section(
                    title: "Hymn Stories & Historical Content",
                    icon: "doc.text.magnifyingglass",
                    content: """
                    Historical commentary and companion material sourced from:
                    Hymns for Worship – SDA Hymnal Companion.
                    
                    https://hymnsforworship.org
                    
                    Content used with attribution as permitted by the publisher.
                    """
                )
                
                Divider()
                
                // MARK: Music Attribution
                section(
                    title: "Music & Tune Information",
                    icon: "music.note",
                    content: """
                    Tune names, composers, metrical structures,
                    and historical metadata derived from
                    public hymnological archives and
                    denominational hymn records.
                    
                    Audio playback within the app uses locally bundled files
                    for testing purposes.
                    """
                )
                
                Divider()
                
                // MARK: Scripture
                section(
                    title: "Scripture References",
                    icon: "book.fill",
                    content: """
                    Scripture references follow standard Protestant canon
                    notation using USFM identifiers for internal indexing.
                    
                    Biblical text display depends on selected translation
                    within the app.
                    """
                )
                
                Divider()
                
                // MARK: Legal
                section(
                    title: "Legal & Disclaimer",
                    icon: "shield.lefthalf.filled",
                    content: """
                    Resonate is an independent project and is not officially
                    affiliated with the General Conference of Seventh-day Adventists.
                    
                    All hymn texts, tune names, and referenced materials remain
                    the property of their respective copyright holders.
                    
                    Where applicable, copyrights are acknowledged
                    within individual hymn metadata.
                    """
                )
                
                Divider()
                
                // MARK: Acknowledgments
                section(
                    title: "Acknowledgments",
                    icon: "heart.fill",
                    content: """
                    Special thanks to early testers, worship leaders, and contributors who provided technical, theological, and usability feedback during development.
                    """
                )
            }
            .padding()
        }
        .navigationTitle("Credits")
    }


    private func section(title: String, icon: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(.secondary)
                
                Text(title)
                    .font(.headline)
            }
            
            Text(content)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

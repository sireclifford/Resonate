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
                VStack(alignment: .leading, spacing: 16) {
                    
                    HStack(spacing: 8) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .foregroundStyle(.secondary)
                        
                        Text("Hymn Stories & Historical Content")
                            .font(.headline)
                    }
                    
                    Text("""
                    Historical commentary and companion material sourced from:
                    Hymns for Worship – SDA Hymnal Companion.
                    """)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    
                    linkPill(icon: "globe", title: "Hymns for Worship Website", urlString: "https://hymnsforworship.org", color: .blue)
                    
                    linkPill(icon: "f.circle.fill", title: "Facebook", urlString: "https://www.facebook.com/hymnsforworship", color: Color(red: 59/255, green: 89/255, blue: 152/255))
                    
                    linkPill(icon: "camera.circle.fill", title: "Instagram", urlString: "https://www.instagram.com/hymns4worship/", color: .pink)
                    
                    linkPill(icon: "play.circle.fill", title: "YouTube", urlString: "https://www.youtube.com/@HymnsForWorship", color: .red)
                    
                    Text("Content used with attribution as permitted by the publisher.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
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
                VStack(alignment: .leading, spacing: 12) {
                    
                    HStack(spacing: 8) {
                        Image(systemName: "book.fill")
                            .foregroundStyle(.secondary)
                        
                        Text("Scripture References")
                            .font(.headline)
                    }
                    
                    Text("""
                    Scripture references follow standard Protestant canon
                    notation using USFM identifiers for internal indexing.
                    
                    Bible API powered by YouVersion.
                    """)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    
                    linkPill(icon: "globe", title: "YouVersion Website", urlString: "https://www.youversion.com", color: .blue)
                    
                    linkPill(icon: "camera.circle", title: "Instagram", urlString: "https://www.instagram.com/youversion/", color: .pink)
                    
                    linkPill(icon: "f.circle", title: "Facebook", urlString: "https://www.facebook.com/YouVersion", color: Color(red: 59/255, green: 89/255, blue: 152/255))
                    
                    linkPill(icon: "play.circle", title: "YouTube", urlString: "https://www.youtube.com/@youversion", color: .red)
                    
                    linkPill(icon: "music.note", title: "TikTok", urlString: "https://www.tiktok.com/@youversion?lang=en", color: .black)
                    
                    Text("Biblical text display depends on selected translation within the app.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
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
    
    
    private func linkPill(icon: String, title: String, urlString: String, color: Color) -> some View {
        if let url = URL(string: urlString) {
            return AnyView(
                Link(destination: url) {
                    HStack(spacing: 10) {
                        Image(systemName: icon)
                            .foregroundStyle(color)
                        
                        Text(title)
                            .foregroundStyle(color)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 14)
                    .background(
                        Capsule()
                            .fill(color.opacity(0.15))
                    )
                    .overlay(
                        Capsule()
                            .stroke(color.opacity(0.4), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            )
        } else {
            return AnyView(EmptyView())
        }
    }
}

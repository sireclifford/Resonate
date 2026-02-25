import SwiftUI

struct MiniPlayerView: View {
    
    @EnvironmentObject private var environment: AppEnvironment
    @ObservedObject private var audio: AudioPlaybackService
    
    init(environment: AppEnvironment) {
        _audio = ObservedObject(wrappedValue: environment.audioPlaybackService)
    }
    
    var body: some View {
        if let id = audio.currentHymnID,
           let hymn = environment.hymnService.index.first(where: { $0.id == id }) {
            
            HStack(spacing: 14) {
                
                // Album style thumbnail
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.ultraThinMaterial)
                        .frame(width: 48, height: 48)
                    
                    Text("\(hymn.id)")
                        .font(.headline)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(hymn.title)
                        .font(.system(size: 15, weight: .semibold))
                        .lineLimit(1)
                    
                    Text(hymn.category.title)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button {
                    audio.togglePlayback(
                        for: id,
                        tuneService: environment.tuneService
                    )
                    if let id = environment.audioPlaybackService.currentHymnID {
                        environment.analyticsService.miniPlayerToggled(id: id)
                    }
                } label: {
                    Image(systemName: audio.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 18, weight: .bold))
                        .frame(width: 40, height: 40)
                }
                
                Button {
                    audio.stop()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14))
                        .frame(width: 30, height: 30)
                }
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(Color.white.opacity(0.25), lineWidth: 0.5)
                    )
                    .opacity(0.9)
            )
            .shadow(color: .black.opacity(0.15), radius: 20, y: 8)
            //            .padding(.horizontal)
            .padding(.bottom, 6)
            .onTapGesture {
                    environment.analyticsService.miniPlayerTapped(id: id)
            }
        }
    }
}

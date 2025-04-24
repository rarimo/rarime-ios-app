import AVKit
import SwiftUI

struct LoopVideoPlayer: View {
    let url: URL

    @State private var player: AVPlayer

    init(url: URL) {
        self.url = url
        self._player = State(initialValue: AVPlayer(url: url))
    }

    var body: some View {
        VideoPlayer(player: player)
            .disabled(true)
            .onAppear {
                player.play()
                player.volume = 0
                NotificationCenter.default.addObserver(
                    forName: .AVPlayerItemDidPlayToEndTime,
                    object: nil,
                    queue: .main
                ) { _ in
                    player.seek(to: .zero)
                    player.play()
                }
            }
            .onDisappear {
                player.pause()
            }
    }
}

#Preview {
    LoopVideoPlayer(url: Videos.readNfc)
}

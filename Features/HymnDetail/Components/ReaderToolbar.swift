import SwiftUI

struct ReaderToolbar: View {

    let onDecreaseFont: () -> Void
    let onIncreaseFont: () -> Void

    var body: some View {
        HStack(spacing: 20) {

            Button(action: onDecreaseFont) {
                Image(systemName: "textformat.size.smaller")
            }

            Button(action: onIncreaseFont) {
                Image(systemName: "textformat.size.larger")
            }
        }
        .font(.josefin(size: 15))
    }
}



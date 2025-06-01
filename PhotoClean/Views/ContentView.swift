import SwiftUI
import Photos

struct ContentView: View {

    @State var assetsToDelete: [PHAsset?] = []
    @State var cards: [Card] = []
    
    var body: some View {
        VStack {
            ScrollView {
                ZStack {
                    ForEach(0..<cards.count, id: \.self) { i in
                        if cards[i].asset != nil {
                            DecisionView(card: $cards[i],
                                         assetsToDelete: $assetsToDelete)
                        } else {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 300, height: 300)
                                .overlay(Text("No Image").foregroundColor(.gray))
                        }
                    }
                }
            }
            Button("Click!", action: {
                    let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
                    print("Photo Library Authorization Status: \(status)")
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.deleteAssets(assetsToDelete.compactMap { $0 } as NSArray)
                }) { success, error in
                    if success {
                        print("Asset deleted successfully.")
                    } else if let error = error {
                        print("Error deleting asset: \(error)")
                    }
                }
            })
        }
        .onAppear {
            requestPhotoAccessAndFetchRecent()
        }
    }

    func requestPhotoAccessAndFetchRecent() {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                if status != .authorized && status != .limited {
                    return
                }

                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                fetchOptions.fetchLimit = 20
                let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)

                for i in 0..<fetchResult.count {
                    let asset = fetchResult[i]
                    let imageManager = PHImageManager.default()
                    let targetSize = CGSize(width: 300, height: 300)
                    let requestOptions = PHImageRequestOptions()
                    requestOptions.isSynchronous = true
                    requestOptions.deliveryMode = .highQualityFormat

                    imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: requestOptions) { image, _ in
                        if image != nil {
                            DispatchQueue.main.async {
                                self.cards.insert(PhotoCard(decision: .UNDECIDED, asset: asset, image: image), at: 0)
                            }
                        }
                    }
                }
            }
    }
}

struct DecisionView: View {
    @Binding var card: Card
    @Binding var assetsToDelete: [PHAsset?]
    @State private var offset: CGSize = .zero

    var body: some View {
            VStack {
                if let photoCard = card as? PhotoCard, let image = photoCard.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 300, height: 300)
                        .clipped()
                        .cornerRadius(16)
                        .shadow(radius: 8)
                }
            }
            .offset(x: offset.width, y: 0)
            .rotationEffect(.degrees(Double(offset.width / 20)))
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        offset = gesture.translation
                    }
                    .onEnded { _ in
                        if offset.width > 100 {
                            likeCard()
                        } else if offset.width < -100 {
                            dislikeCard()
                        } else if offset.height < -50 {
                            laterCard()
                        } else {
                            offset = .zero
                        }
                    }
            )
        }
    
    func likeCard() {
        withAnimation {
            offset.width = 500
        }
        card.decision = .KEEP
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            removeCard()
        }
    }
    
    func laterCard() {
        withAnimation {
            offset.width = -400
        }
        card.decision = .LATER
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            removeCard()
        }
    }
    
    func dislikeCard() {
        withAnimation {
            offset.width = -500
        }
        card.decision = .DELETE
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            removeCard()
        }
    }
    
    func removeCard() {
        if (card.decision == .DELETE) {
            assetsToDelete.append(card.asset)
        }
    }
}

#Preview {
    ContentView()
}

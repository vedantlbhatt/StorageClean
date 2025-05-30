import SwiftUI
import Photos

struct ContentView: View {
    @State private var recentImages: [UIImage?] = []
    @State private var recentImagesAssets: [PHAsset?] = []
    @State private var idx: Int = 0
    @State var assetsToDelete: [PHAsset?] = []

    var body: some View {
        VStack {
            ScrollView {
                ZStack {
                    ForEach(0..<recentImages.count, id: \.self) { i in
                        if recentImages[i] != nil {
                            DecisionView(image: $recentImages[i],
                                         imageAsset: $recentImagesAssets[i],
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
                    PHAssetChangeRequest.deleteAssets(assetsToDelete as NSArray)
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
                fetchOptions.fetchLimit = 7
                let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)

                for i in 0..<fetchResult.count {
                    let asset = fetchResult[i]
                    self.recentImagesAssets.insert(asset, at: 0)
                    let imageManager = PHImageManager.default()
                    let targetSize = CGSize(width: 300, height: 300)
                    let requestOptions = PHImageRequestOptions()
                    requestOptions.isSynchronous = true
                    requestOptions.deliveryMode = .highQualityFormat

                    imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: requestOptions) { image, _ in
                        if image != nil {
                            DispatchQueue.main.async {
                                self.recentImages.insert(image, at: 0)
                                print("\(i)")
                                print(asset.creationDate ?? "pos")
                            }
                        }
                    }
                }
            }
    }
}

struct DecisionView: View {
    @Binding var image: UIImage?
    @Binding var imageAsset: PHAsset?
    @Binding var assetsToDelete: [PHAsset?]
    @State var show: Bool = true

    var body: some View {
        
        if show {
            VStack {
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: 100, height: 100)
                Text("\(imageAsset?.creationDate ?? Date())")
                    .font(.largeTitle)
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 300, height: 300)
                        .clipped()
                        .cornerRadius(16)
                        .shadow(radius: 8)
                }
            }
            .onTapGesture {
                show.toggle()
                assetsToDelete.append(imageAsset)
            }
        }
    }
}

#Preview {
    ContentView()
}

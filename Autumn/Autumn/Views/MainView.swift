import SwiftUI
import VisionKit

struct MainView: View {
    @State private var showScanner = false
    @State private var scannedImages: [UIImage] = []
    
    var body: some View {
        NavigationView {
            VStack {
                if scannedImages.isEmpty {
                    ContentUnavailableView(
                        "没有扫描文档",
                        systemImage: "doc.text.viewfinder",
                        description: Text("点击下方按钮开始扫描")
                    )
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 20) {
                            ForEach(scannedImages.indices, id: \.self) { index in
                                Image(uiImage: scannedImages[index])
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)
                                    .cornerRadius(10)
                            }
                        }
                        .padding()
                    }
                }
                
                Button(action: {
                    showScanner = true
                }) {
                    Label("扫描文档", systemImage: "doc.viewfinder")
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("文档扫描")
            .sheet(isPresented: $showScanner) {
                ScannerView(scannedImages: $scannedImages)
            }
        }
    }
}

struct ScannerView: UIViewControllerRepresentable {
    @Binding var scannedImages: [UIImage]
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scannerViewController = VNDocumentCameraViewController()
        scannerViewController.delegate = context.coordinator
        return scannerViewController
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let parent: ScannerView
        
        init(_ parent: ScannerView) {
            self.parent = parent
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            for pageIndex in 0..<scan.pageCount {
                let image = scan.imageOfPage(at: pageIndex)
                parent.scannedImages.append(image)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            print("扫描失败: \(error.localizedDescription)")
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    MainView()
}
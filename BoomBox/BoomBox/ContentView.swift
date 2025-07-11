//
//  ContentView.swift
//  BoomBox
//
//  Created by Dimitri SMITH on 11/07/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appModel: AppModel

    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                Text("🎉 BoomBox")
                    .font(.largeTitle.bold())

                Button(action: {
                    appModel.captureMode = .photo
                    appModel.navigateToCapture = true
                }) {
                    Text("📸 Prendre une photo")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                Button(action: {
                    appModel.captureMode = .video
                    appModel.navigateToCapture = true
                }) {
                    Text("🎥 Prendre une vidéo")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding()
            .fullScreenCover(isPresented: $appModel.navigateToCapture) {
                CameraViewControllerWrapper()
            }
        }
    }
}

class AppModel: ObservableObject {
    enum CaptureMode {
        case photo, video
    }

    @Published var captureMode: CaptureMode = .photo
    @Published var navigateToCapture: Bool = false
}

struct CameraViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CameraViewController {
        return CameraViewController()
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}

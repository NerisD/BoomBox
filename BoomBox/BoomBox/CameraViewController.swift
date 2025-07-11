//
//  CameraViewController.swift
//  BoomBox
//
//  Created by Dimitri SMITH on 11/07/2025.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    // Mode photo ou vidéo
    var isVideoMode: Bool = false

    convenience init(isVideoMode: Bool) {
        self.init()
        self.isVideoMode = isVideoMode
    }
    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var captureOutput = AVCapturePhotoOutput()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupCamera()
    }

    private func setupCamera() {
        session.beginConfiguration()
        session.sessionPreset = .photo

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: camera),
              session.canAddInput(input) else {
            return
        }
        session.addInput(input)

        if session.canAddOutput(captureOutput) {
            session.addOutput(captureOutput)
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.videoGravity = .resizeAspectFill
        let previewContainer = UIView()
        previewContainer.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(previewContainer, at: 0)

        NSLayoutConstraint.activate([
            previewContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            previewContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            previewContainer.topAnchor.constraint(equalTo: view.topAnchor),
            previewContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        previewLayer?.frame = view.bounds
        if let layer = previewLayer {
            previewContainer.layer.addSublayer(layer)
        }

        session.commitConfiguration()
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
        
        _ = AVCapturePhotoOutput().isStillImageStabilizationSupported

        addCaptureButton()
        addPhotoboothOverlay()
        addBackButton()
    }

    private func addCaptureButton() {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 35
        button.backgroundColor = .red
        view.addSubview(button)

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            button.widthAnchor.constraint(equalToConstant: 70),
            button.heightAnchor.constraint(equalToConstant: 70)
        ])

        button.addTarget(self, action: #selector(captureAction), for: .touchUpInside)
    }

    @objc private func captureAction() {
        if isVideoMode {
            startBoomerangVideoCapture()
        } else {
            capturePhoto()
        }
    }

    private func capturePhoto() {
        guard session.isRunning else { return }
        let settings = AVCapturePhotoSettings()
        settings.isAutoStillImageStabilizationEnabled = true
        captureOutput.capturePhoto(with: settings, delegate: self)
    }

    private func startBoomerangVideoCapture() {
        print("Début de la capture vidéo Boomerang")
        // À implémenter
    }

    private func addPhotoboothOverlay() {
        guard let overlayImage = UIImage(named: "photobooth_overlay") else { return }
        let overlayView = UIImageView(image: overlayImage)
        overlayView.contentMode = .scaleAspectFit
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.isUserInteractionEnabled = false
        view.addSubview(overlayView)

        NSLayoutConstraint.activate([
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        view.bringSubviewToFront(overlayView)
    }
    private func addBackButton() {
        let backButton = UIButton(type: .system)
        backButton.setTitle("Retour", for: .normal)
        backButton.setTitleColor(.white, for: .normal)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)
        view.addSubview(backButton)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16)
        ])
    }

    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        print("Photo capturée")
        guard let data = photo.fileDataRepresentation(),
              let baseImage = UIImage(data: data),
              let overlayImage = UIImage(named: "photobooth_overlay") else { return }

        UIGraphicsBeginImageContextWithOptions(baseImage.size, false, baseImage.scale)
        baseImage.draw(in: CGRect(origin: .zero, size: baseImage.size))
        overlayImage.draw(in: CGRect(origin: .zero, size: baseImage.size), blendMode: .normal, alpha: 1.0)
        let combinedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let finalImage = combinedImage else { return }
        let previewVC = PhotoPreviewViewController()
        previewVC.configure(with: finalImage)
        present(previewVC, animated: true, completion: nil)
    }
}


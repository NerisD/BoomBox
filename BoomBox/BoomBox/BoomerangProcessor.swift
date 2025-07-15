
//
//  BoomerangProcessor.swift
//  BoomBox
//
//  Created by Dimitri SMITH on 15/07/2025.
//

import UIKit
import AVFoundation

class BoomerangProcessor {
    static let shared = BoomerangProcessor()

    private init() {}

    func createBoomerang(from images: [UIImage], completion: @escaping (URL?) -> Void) {
        guard !images.isEmpty else {
            completion(nil)
            return
        }

        let frameRate: Int32 = 15
        let size = images[0].size
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("boomerangVideo.mov")
        try? FileManager.default.removeItem(at: outputURL)

        guard let writer = try? AVAssetWriter(outputURL: outputURL, fileType: .mov) else {
            completion(nil)
            return
        }

        let settings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: size.width,
            AVVideoHeightKey: size.height
        ]

        let input = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32ARGB),
            kCVPixelBufferWidthKey as String: Int(size.width),
            kCVPixelBufferHeightKey as String: Int(size.height)
        ])

        guard writer.canAdd(input) else {
            completion(nil)
            return
        }
        writer.add(input)
        writer.startWriting()
        writer.startSession(atSourceTime: .zero)

        let imagesForBoomerang = images + images.reversed()
        var frameCount: Int64 = 0
        let frameDuration = CMTime(value: 1, timescale: frameRate)

        input.requestMediaDataWhenReady(on: DispatchQueue(label: "boomerang.queue")) {
            while input.isReadyForMoreMediaData && frameCount < Int64(imagesForBoomerang.count) {
                let image = imagesForBoomerang[Int(frameCount)]
                guard let buffer = self.pixelBuffer(from: image, size: size) else { continue }

                let presentationTime = CMTimeMultiply(frameDuration, multiplier: Int32(frameCount))
                adaptor.append(buffer, withPresentationTime: presentationTime)

                frameCount += 1
            }

            input.markAsFinished()
            writer.finishWriting {
                DispatchQueue.main.async {
                    completion(writer.status == .completed ? outputURL : nil)
                }
            }
        }
    }

    private func pixelBuffer(from image: UIImage, size: CGSize) -> CVPixelBuffer? {
        var buffer: CVPixelBuffer?
        let options: [CFString: Any] = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true
        ]

        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(size.width), Int(size.height), kCVPixelFormatType_32ARGB, options as CFDictionary, &buffer)
        guard status == kCVReturnSuccess, let pixelBuffer = buffer else { return nil }

        CVPixelBufferLockBaseAddress(pixelBuffer, [])
        let context = CGContext(
            data: CVPixelBufferGetBaseAddress(pixelBuffer),
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        )

        if let cgImage = image.cgImage {
            context?.draw(cgImage, in: CGRect(origin: .zero, size: size))
        }

        CVPixelBufferUnlockBaseAddress(pixelBuffer, [])
        return pixelBuffer
    }
}




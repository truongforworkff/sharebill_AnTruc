import Flutter
import UIKit
import Vision
import ImageIO

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "ChungReceiptOCR")!
    let channel = FlutterMethodChannel(name: "chung/receipt_ocr", binaryMessenger: registrar.messenger())
    channel.setMethodCallHandler { call, result in
      guard call.method == "readText" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard let image = call.arguments as? FlutterStandardTypedData,
            !image.data.isEmpty, image.data.count <= 2 * 1024 * 1024 else {
        result(FlutterError(code: "invalid_image", message: "Invalid bill image", details: nil))
        return
      }
      DispatchQueue.global(qos: .userInitiated).async {
        do {
          let request = VNRecognizeTextRequest()
          request.recognitionLevel = .accurate
          request.usesLanguageCorrection = false
          let languages = try request.supportedRecognitionLanguages()
          request.recognitionLanguages = languages.contains("vi-VN") ? ["vi-VN", "en-US"] : ["en-US"]
          guard let photo = UIImage(data: image.data), let cgImage = photo.cgImage else {
            throw NSError(domain: "ChungReceiptOCR", code: 1)
          }
          let orientation: CGImagePropertyOrientation
          switch photo.imageOrientation {
          case .up: orientation = .up
          case .down: orientation = .down
          case .left: orientation = .left
          case .right: orientation = .right
          case .upMirrored: orientation = .upMirrored
          case .downMirrored: orientation = .downMirrored
          case .leftMirrored: orientation = .leftMirrored
          case .rightMirrored: orientation = .rightMirrored
          @unknown default: orientation = .up
          }
          let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])
          try handler.perform([request])
          let text = (request.results ?? []).compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
          DispatchQueue.main.async { result(text) }
        } catch {
          DispatchQueue.main.async {
            result(FlutterError(code: "ocr_failed", message: "Cannot read bill", details: nil))
          }
        }
      }
    }
  }
}

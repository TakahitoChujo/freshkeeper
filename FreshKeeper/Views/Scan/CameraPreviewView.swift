import SwiftUI
@preconcurrency import AVFoundation
import Vision
import os.log

private let logger = Logger(subsystem: "com.freshkeeper", category: "Camera")

struct CameraPreviewView: UIViewControllerRepresentable {
    let onBarcodeDetected: @Sendable (String) -> Void
    let onTextDetected: @Sendable (String) -> Void

    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.onBarcodeDetected = onBarcodeDetected
        controller.onTextDetected = onTextDetected
        return controller
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}

final class CameraViewController: UIViewController {
    nonisolated(unsafe) var onBarcodeDetected: (@Sendable (String) -> Void)?
    nonisolated(unsafe) var onTextDetected: (@Sendable (String) -> Void)?

    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private let metadataOutput = AVCaptureMetadataOutput()
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private let sessionQueue = DispatchQueue(label: "camera.session")
    private var _delegateHandler: CameraDelegateHandler?

    override func viewDidLoad() {
        super.viewDidLoad()
        checkPermissionAndSetup()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sessionQueue.async { [weak self] in
            guard let self, !self.captureSession.isRunning else { return }
            self.captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sessionQueue.async { [weak self] in
            self?.captureSession.stopRunning()
        }
    }

    // MARK: - Permission Check

    private func checkPermissionAndSetup() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async { self?.setupCamera() }
                } else {
                    logger.warning("Camera permission denied by user")
                }
            }
        case .denied, .restricted:
            logger.warning("Camera permission denied or restricted")
        @unknown default:
            break
        }
    }

    // MARK: - Camera Setup

    private func setupCamera() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            logger.error("No back camera available")
            return
        }
        guard let input = try? AVCaptureDeviceInput(device: device) else {
            logger.error("Failed to create camera input")
            return
        }

        let delegateHandler = CameraDelegateHandler(controller: self)
        _delegateHandler = delegateHandler

        sessionQueue.async { [weak self] in
            guard let self else { return }

            self.captureSession.beginConfiguration()
            self.captureSession.sessionPreset = .high

            if self.captureSession.canAddInput(input) {
                self.captureSession.addInput(input)
            }

            // Barcode detection
            if self.captureSession.canAddOutput(self.metadataOutput) {
                self.captureSession.addOutput(self.metadataOutput)
                self.metadataOutput.setMetadataObjectsDelegate(delegateHandler, queue: .main)
                self.metadataOutput.metadataObjectTypes = [.ean8, .ean13, .upce, .qr]
            }

            // OCR via video output
            if self.captureSession.canAddOutput(self.videoDataOutput) {
                self.captureSession.addOutput(self.videoDataOutput)
                self.videoDataOutput.setSampleBufferDelegate(delegateHandler, queue: self.sessionQueue)
            }

            self.captureSession.commitConfiguration()

            DispatchQueue.main.async {
                let layer = AVCaptureVideoPreviewLayer(session: self.captureSession)
                layer.videoGravity = .resizeAspectFill
                self.view.layer.addSublayer(layer)
                layer.frame = self.view.bounds
                self.previewLayer = layer
            }
        }
    }
}

// MARK: - Delegate Handler (runs on sessionQueue)

private final class CameraDelegateHandler: NSObject, AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, @unchecked Sendable {
    private weak var controller: CameraViewController?
    private var lastTextRecognitionTime: Date = .distantPast
    private static let maxOCRTextLength = 1000

    init(controller: CameraViewController) {
        self.controller = controller
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let stringValue = metadataObject.stringValue,
              stringValue.count <= 128 else { return }
        controller?.onBarcodeDetected?(stringValue)
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let now = Date()
        guard now.timeIntervalSince(lastTextRecognitionTime) > 0.5 else { return }
        lastTextRecognitionTime = now

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let onTextDetected = controller?.onTextDetected
        let maxLength = Self.maxOCRTextLength

        let request = VNRecognizeTextRequest { request, error in
            if let error {
                logger.error("OCR failed: \(error.localizedDescription)")
                return
            }
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            let text = observations
                .compactMap { $0.topCandidates(1).first?.string }
                .joined(separator: " ")

            // Truncate to prevent ReDoS on long OCR text
            let safeText = text.count > maxLength ? String(text.prefix(maxLength)) : text

            if !safeText.isEmpty {
                DispatchQueue.main.async {
                    onTextDetected?(safeText)
                }
            }
        }
        request.recognitionLanguages = ["ja", "en"]
        request.recognitionLevel = .accurate

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        do {
            try handler.perform([request])
        } catch {
            logger.error("Vision request failed: \(error.localizedDescription)")
        }
    }
}

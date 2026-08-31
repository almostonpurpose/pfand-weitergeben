import SwiftUI
import PhotosUI
import Vision
import UIKit
import AVFoundation

struct PhotoEstimateView: View {
    @Binding var bottleCount: Int
    @Binding var estimatedDeposit: Double

    @State private var photoItem: PhotosPickerItem?
    @State private var previewImage: UIImage?
    @State private var showingCamera = false
    @State private var showingUnavailable = false
    @State private var isProcessing = false
    @State private var resultMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if let previewImage {
                Image(uiImage: previewImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .accessibilityLabel(Text("Ausgewähltes Foto für die Pfandschätzung"))
            }

            HStack(spacing: 10) {
                Button {
                    openCamera()
                } label: {
                    Label("Foto aufnehmen", systemImage: "camera")
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.green)

                PhotosPicker(selection: $photoItem, matching: .images) {
                    Label("Foto wählen", systemImage: "photo.on.rectangle")
                }
                .buttonStyle(.bordered)
            }

            if isProcessing {
                HStack {
                    ProgressView()
                    Text("Foto wird nur auf diesem Gerät geprüft …")
                }
                .font(.subheadline)
            }

            if let resultMessage {
                Label(resultMessage, systemImage: "wand.and.stars")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.green)
            }

            Label("Grobe Schätzung – kann falsch sein. Bitte Flaschen und Pfandwert selbst zählen und bestätigen.", systemImage: "exclamationmark.triangle")
                .font(.footnote)
                .foregroundStyle(AppTheme.secondaryInk)

            Label("Das Foto bleibt auf deinem Gerät und wird nicht hochgeladen.", systemImage: "lock.shield")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .onChange(of: photoItem) { _, item in
            guard let item else { return }
            Task {
                guard let data = try? await item.loadTransferable(type: Data.self),
                      let image = UIImage(data: data) else {
                    resultMessage = L10n.string("camera.photo_unavailable")
                    return
                }
                previewImage = image
            }
        }
        .onChange(of: previewImage) { _, image in
            if let image { analyse(image) }
        }
        .sheet(isPresented: $showingCamera) {
            CameraPicker(image: $previewImage)
                .ignoresSafeArea()
        }
        .alert("Kamera nicht verfügbar", isPresented: $showingUnavailable) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Du kannst stattdessen ein Foto auswählen oder Anzahl und Pfandwert direkt eingeben.")
        }
    }

    @MainActor
    private func analyse(_ image: UIImage) {
        isProcessing = true
        let result = PhotoEstimateService.estimate(from: image, fallback: bottleCount)
        bottleCount = result.count
        estimatedDeposit = Double(result.count) * 0.25
        resultMessage = result.usedFallback
            ? L10n.string("camera.fallback_result", result.count, L10n.currency(estimatedDeposit))
            : L10n.string("camera.rough_result", result.count, L10n.currency(estimatedDeposit))
        isProcessing = false
    }

    @MainActor
    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showingUnavailable = true
            return
        }
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            showingCamera = true
        case .notDetermined:
            Task {
                let granted = await AVCaptureDevice.requestAccess(for: .video)
                showingCamera = granted
                showingUnavailable = !granted
            }
        case .denied, .restricted:
            showingUnavailable = true
        @unknown default:
            showingUnavailable = true
        }
    }
}

struct PhotoEstimateResult: Equatable {
    let count: Int
    let usedFallback: Bool
}

enum PhotoEstimateService {
    static func estimate(from image: UIImage, fallback: Int) -> PhotoEstimateResult {
        guard let cgImage = image.cgImage else {
            return PhotoEstimateResult(count: min(max(1, fallback), 200), usedFallback: true)
        }

        let request = VNDetectContoursRequest()
        request.maximumImageDimension = 512
        request.contrastAdjustment = 1.2
        request.detectsDarkOnLight = true

        do {
            try VNImageRequestHandler(cgImage: cgImage, orientation: .up).perform([request])
            guard let observation = request.results?.first else {
                return PhotoEstimateResult(count: min(max(1, fallback), 200), usedFallback: true)
            }
            let contours = flatten(observation.topLevelContours)
            let candidates = contours.filter { contour in
                let box = contour.normalizedPath.boundingBox
                guard box.width > 0.035, box.height > 0.09, box.width < 0.5, box.height < 0.95 else { return false }
                let ratio = box.height / max(box.width, 0.001)
                return ratio > 1.25 && ratio < 7 && box.width * box.height > 0.008
            }
            let count = min(max(candidates.count, 1), 60)
            return PhotoEstimateResult(count: count, usedFallback: candidates.isEmpty)
        } catch {
            return PhotoEstimateResult(count: min(max(1, fallback), 200), usedFallback: true)
        }
    }

    private static func flatten(_ contours: [VNContour]) -> [VNContour] {
        contours + contours.flatMap { flatten($0.childContours) }
    }
}

private struct CameraPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: CameraPicker
        init(parent: CameraPicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            parent.image = info[.originalImage] as? UIImage
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

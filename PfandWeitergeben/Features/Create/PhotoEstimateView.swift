import SwiftUI
import PhotosUI
import Vision
import UIKit
import AVFoundation

struct PhotoEstimateView: View {
    @Binding var roughCount: Int

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

            if roughCount > 0 {
                Stepper(value: $roughCount, in: 1...200) {
                    HStack {
                        Text("Grobe Gesamtzahl")
                        Spacer()
                        Text("\(roughCount)").font(.headline).monospacedDigit()
                    }
                }
            }

            Label("Grobe Schätzung – kann falsch sein. Passe die Gesamtzahl an und verteile sie unten auf die Pfandarten.", systemImage: "exclamationmark.triangle")
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
            Text("Du kannst stattdessen ein Foto auswählen oder die Mengen nach Pfandart direkt eingeben.")
        }
    }

    @MainActor
    private func analyse(_ image: UIImage) {
        isProcessing = true
        let result = PhotoEstimateService.estimate(from: image, fallback: max(roughCount, 1))
        roughCount = result.count
        resultMessage = result.usedFallback
            ? L10n.string("camera.fallback_count_result", result.count)
            : L10n.string("camera.rough_count_result", result.count)
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
    /// Deliberately rough: the heuristic looks for upright, container-shaped dark silhouettes.
    /// It does not recognise deposit classes and is not calibrated for field use.
    static func estimate(from image: UIImage, fallback: Int) -> PhotoEstimateResult {
        let bounded = PhotoEstimateResult(count: min(max(1, fallback), 200), usedFallback: true)
        guard let cgImage = image.cgImage else { return bounded }

        let request = VNDetectContoursRequest()
        request.maximumImageDimension = 512
        request.contrastAdjustment = 1.2
        request.detectsDarkOnLight = true

        do {
            // Camera photos carry their rotation as metadata. Vision has to be told about it,
            // otherwise an upright can is analysed lying on its side and never matches.
            let orientation = CGImagePropertyOrientation(image.imageOrientation)
            try VNImageRequestHandler(cgImage: cgImage, orientation: orientation).perform([request])
            guard let observation = request.results?.first else { return bounded }

            let shapes = flatten(observation.topLevelContours)
                .map { $0.normalizedPath.boundingBox }
                .filter(isContainerShaped)
            let containers = distinctContainers(shapes)
            guard !containers.isEmpty else { return bounded }
            return PhotoEstimateResult(count: min(containers.count, 60), usedFallback: false)
        } catch {
            return bounded
        }
    }

    private static func flatten(_ contours: [VNContour]) -> [VNContour] {
        contours + contours.flatMap { flatten($0.childContours) }
    }

    private static func isContainerShaped(_ box: CGRect) -> Bool {
        guard box.width > 0.035, box.height > 0.09, box.width < 0.85, box.height < 0.95 else { return false }
        let ratio = box.height / max(box.width, 0.001)
        return ratio > 1.25 && ratio < 7 && box.width * box.height > 0.008
    }

    /// A printed label, a highlight or a shadow produces its own contour inside or across the
    /// container that carries it. Keep only the largest shape of each overlapping group so that
    /// one can counts once.
    private static func distinctContainers(_ boxes: [CGRect]) -> [CGRect] {
        var kept: [CGRect] = []
        for box in boxes.sorted(by: { $0.width * $0.height > $1.width * $1.height }) {
            let coveredByLarger = kept.contains { larger in
                let overlap = larger.intersection(box)
                guard !overlap.isNull, !overlap.isEmpty else { return false }
                return (overlap.width * overlap.height) / (box.width * box.height) > 0.5
            }
            if !coveredByLarger { kept.append(box) }
        }
        return kept
    }
}

private extension CGImagePropertyOrientation {
    init(_ orientation: UIImage.Orientation) {
        switch orientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        @unknown default: self = .up
        }
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

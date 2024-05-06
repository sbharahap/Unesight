//
//  ImagePickerCoordinator.swift
//  Unesight
//
//  Created by Satria Baladewa Harahap on 06/05/24.
//


// ImagePickerCoordinator.swift

import SwiftUI
import AVFoundation
import Vision
import CoreML

struct ImagePickerCoordinator: UIViewControllerRepresentable {
    @Binding var isShown: Bool
    @Binding var image: Image?
    @Binding var result: String
    @Binding var results: [Int]
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePickerCoordinator>) {}
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePickerCoordinator>) -> UIImagePickerController {
        let obj = UIImagePickerController()
        obj.sourceType = .camera // Mengatur sumber gambar ke kamera
        obj.cameraDevice = .rear // Mengatur kamera ke belakang
        obj.cameraFlashMode = .on // Menyalakan lampu kilat
        obj.delegate = context.coordinator
        return obj
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
}

class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var parent: ImagePickerCoordinator
    let speechSynthesizer = AVSpeechSynthesizer()

    init(parent: ImagePickerCoordinator) {
        self.parent = parent
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        parent.isShown = false
        if let image = info[.originalImage] as? UIImage,
           let identifier = classifyImage(image) {
            parent.image = Image(uiImage: image)
            parent.result = identifier
            parent.results.append(Int(identifier) ?? 0)

            // Mengucapkan hasil klasifikasi
            speakResult(identifier: identifier)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        parent.isShown = false
    }

    // Klasifikasi Gambar
    func classifyImage(_ image: UIImage) -> String? {
        guard let model = try? uangclassifier(configuration: MLModelConfiguration()).model else {
            return "Model error"
        }

        guard let vnModel = try? VNCoreMLModel(for: model) else {
            return "VNCoreMLModel initialization error"
        }

        guard let ciImage = CIImage(image: image) else {
            return "Image conversion error"
        }

        let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue)) ?? .up
        let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)

        var identifier: String?
        let request = VNCoreMLRequest(model: vnModel) { request, error in
            guard let results = request.results as? [VNClassificationObservation],
                  let firstResult = results.first else {
                identifier = "Unable to classify image"
                return
            }

            identifier = firstResult.identifier
        }

        do {
            try handler.perform([request])
        } catch {
            identifier = "Error classifying image: \(error.localizedDescription)"
        }

        return identifier
    }
    
    // Fungsi untuk mengucapkan hasil deteksi
    func speakResult(identifier: String) {
        var speechText = ""
        switch identifier {
            case "1000":
                speechText = "Seribu"
            case "2000":
                speechText = "Dua ribu"
            case "5000":
                speechText = "Lima ribu"
            case "10000":
                speechText = "Sepuluh ribu"
            case "20000":
                speechText = "Dua puluh ribu"
            case "50000":
                speechText = "Lima puluh ribu"
            case "100000":
                speechText = "Seratus ribu"
            default:
                speechText = "Nominal uang tidak teridentifikasi"
        }
        
        // Memecah kalimat menjadi beberapa bagian
        let sentences = speechText.components(separatedBy: ".")
        
        // Mengucapkan setiap kalimat
        for sentence in sentences {
            let speechUtterance = AVSpeechUtterance(string: sentence.trimmingCharacters(in: .whitespacesAndNewlines))
            speechUtterance.voice = AVSpeechSynthesisVoice(language: "id-ID") // Bahasa Indonesia
            speechSynthesizer.speak(speechUtterance)
            
            // Menunggu sebelum melanjutkan ke kalimat berikutnya
            while speechSynthesizer.isSpeaking {}
        }
    }
}


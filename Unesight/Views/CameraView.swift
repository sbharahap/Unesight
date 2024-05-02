//
//  CameraView.swift
//  Unesight
//
//  Created by Satria Baladewa Harahap on 25/04/24.
//

import SwiftUI
import CoreML
import Vision

struct ImagePicker: View {
    @State private var isShown: Bool = false
    @State private var image: Image?
    @State private var classifiedResult: String = ""
    @State private var detectedResults: [Int] = [] // Menyimpan hasil deteksi
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                if let image = image {
                    image
                        .resizable()
                        .frame(width: 300, height: 200)
                } else {
                    Text("No image selected")
                }
                Text(classifiedResult).font(.system(size: 36, weight: .bold))
                Spacer()
                Button(action: {
                    self.isShown = true
                }) {
                    Text("Deteksi Uang Lagi       ")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                }
                Spacer()
                NavigationLink(destination: HistoryView(results: $detectedResults)) {
                    Text("Jumlahkan Uang Saya")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                }
                Spacer()
            }
            .navigationBarTitle("Hasil Deteksi Uang")
        }
        .sheet(isPresented: $isShown) {
            A(isShown: self.$isShown, image: self.$image, result: self.$classifiedResult, results: self.$detectedResults)
        }
        .onAppear {
            self.isShown = true
        }
    }
}

struct ImagePicker_Previews: PreviewProvider {
    static var previews: some View {
        ImagePicker()
    }
}

struct A: UIViewControllerRepresentable {
    @Binding var isShown: Bool
    @Binding var image: Image?
    @Binding var result: String
    @Binding var results: [Int] // Tambahkan binding untuk hasil deteksi

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<A>) {}
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<A>) -> UIImagePickerController {
        let obj = UIImagePickerController()
        obj.sourceType = .camera // Mengatur sumber gambar ke kamera
        obj.cameraDevice = .rear // Mengatur kamera ke belakang
        obj.cameraFlashMode = .on // Menyalakan lampu kilat
        obj.delegate = context.coordinator
        return obj
    }
    
    func makeCoordinator() -> C {
        return C(parent: self)
    }
}

class C: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var parent: A
    
    init(parent: A) {
        self.parent = parent
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        parent.isShown = false
        if let image = info[.originalImage] as? UIImage,
           let identifier = classifyImage(image) {
            parent.image = Image(uiImage: image) // Menyimpan foto sementara di sini
            parent.result = identifier
            parent.results.append(Int(identifier) ?? 0) // Menambahkan hasil deteksi ke dalam array
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
}

struct HistoryView: View {
    @State private var isShown: Bool = false // Menyimpan status tampilan kamera
    @Binding var results: [Int]
    
    var total: Int {
        return results.reduce(0, +)
    }
    
    var body: some View {
        VStack {
            List {
                ForEach(results.indices, id: \.self) { index in
                    HStack {
                        Text("Deteksi uang senilai \(results[index])")
                        Spacer()
                        Button(action: {
                            self.results.remove(at: index) // Hapus item yang dipilih
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
                .onDelete(perform: delete) // Aktifkan fitur delete
                
            }
            
            Text("Total: \(total)").font(.title)
            
            Button(action: {
                self.isShown = true
            }) {
                Text("Deteksi Uang Lagi")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
            }
            Spacer()
            Spacer()
            Button(action: {
                self.results = [] // Menghapus riwayat deteksi
                self.isShown = true
            }) {
                Text("Reset                     ")
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
            }
            Spacer()
            Spacer()
        }.navigationBarTitle("Riwayat Deteksi Uang")
        
        .sheet(isPresented: $isShown) {
            A(isShown: self.$isShown, image: .constant(nil), result: .constant(""), results: self.$results)
        }
    }
    
    func delete(at offsets: IndexSet) {
        results.remove(atOffsets: offsets)
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView(results: .constant([100, 200, 500]))
    }
}





//
//  ImagePicker.swift
//  Unesight
//
//  Created by Satria Baladewa Harahap on 06/05/24.
//
// ImagePicker.swift

import SwiftUI

struct ResultView: View {
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
                        .frame(width: 400, height: 300)
                        .accessibility(label: Text("Gambar Terpilih"))
                } else {
                    Text("No image selected")
                        .accessibility(label: Text("Tidak ada gambar terpilih"))
                }
                Text(classifiedResult)
                    .font(.system(size: 36, weight: .bold))
                    .accessibility(label: Text("Hasil Deteksi: \(classifiedResult)"))
                Spacer()
                Button(action: {
                    self.isShown = true
                }) {
                    Text("Deteksi Uang Lagi")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .accessibility(label: Text("Deteksi Uang Lagi"))
                }
                NavigationLink(destination: HistoryView(results: $detectedResults)) {
                    Text("Jumlahkan Uang   ")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .accessibility(label: Text("Jumlahkan Uang Saya"))
                }
                Spacer()
            }
            .navigationBarTitle("Hasil Deteksi Uang")
        }
        .sheet(isPresented: $isShown) {
            ImagePickerCoordinator(isShown: self.$isShown, image: self.$image, result: self.$classifiedResult, results: self.$detectedResults)
        }
        .onAppear {
            self.isShown = true
        }
    }
}

struct ResultView_Previews: PreviewProvider {
    static var previews: some View {
        ResultView()
    }
}



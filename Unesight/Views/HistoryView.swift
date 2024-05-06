//
//  HistoryView.swift
//  Unesight
//
//  Created by Satria Baladewa Harahap on 06/05/24.
//


// HistoryView.swift

import SwiftUI

struct HistoryView: View {
    @Binding var results: [Int]
    @State private var showResultView = false // Tambahkan property
    
    var total: Int {
        return results.reduce(0, +)
    }
    
    var body: some View {
        NavigationView {
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
                                    .accessibility(label: Text("Hapus deteksi uang"))
                            }
                        }
                        .accessibility(label: Text("Deteksi uang senilai \(results[index])"))
                    }
                    .onDelete(perform: delete) // Aktifkan fitur delete
                }
                
                Text("Total: \(total)").font(.title)
                    .accessibility(label: Text("Total uang: \(total)"))
                
                Button(action: {
                    self.showResultView = true
                }) {
                    Text("Deteksi Uang Lagi")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .accessibility(label: Text("Deteksi Uang Lagi"))
                }
                Spacer()
                Spacer()
                Button(action: {
                    self.results = [] // Menghapus riwayat deteksi
                    self.showResultView = true
                }) {
                    Text("Reset                     ")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .accessibility(label: Text("Reset Riwayat Deteksi"))
                }
                Spacer()
                Spacer()
            }
            .navigationBarTitle("Riwayat Deteksi Uang")
            .sheet(isPresented: $showResultView) {
                ImagePickerCoordinator(isShown: self.$showResultView, image: .constant(nil), result: .constant(""), results: self.$results)
            }
        }
    }
    
    func delete(at offsets: IndexSet) {
        results.remove(atOffsets: offsets)
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView(results: .constant([]))
    }
}




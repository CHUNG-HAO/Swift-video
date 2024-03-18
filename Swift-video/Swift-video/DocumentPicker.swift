//
//  DocumentPicker.swift
//  Swift-video
//
//  Created by 鍾弘浩 on 2024/3/19.
//

import SwiftUI
import AVKit
import MobileCoreServices

// 是一個符合 UIViewControllerRepresentable 的結構
struct DocumentPicker: UIViewControllerRepresentable {
    // 一個接受 URL 為參數 當選擇一個文件時，將會調用此。
    var onPick: (URL) -> Void
    
    // UIViewControllerRepresentable 所需要的。它創建並返回一個具體化的 UIDocumentPickerViewController
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        // 創建一個用於選擇影片文件的文件選擇器
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.movie])
        
        picker.delegate = context.coordinator
        return picker
    }
    
    // UIViewControllerRepresentable 所需要的，未使用，所以留空。
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    // 具體化創立這個協調方法
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // 協調方法類別用於處理來自 UIDocumentPickerViewController 的回調。
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        // 對父類 DocumentPicker 的引用
        var parent: DocumentPicker
        
        // 初始化器具體化接受一個 DocumentPicker
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        // 當選擇一個文件時，調用此方法。它調用父類 DocumentPicker 的 onPick
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            parent.onPick(url)
        }
    }
}

//
//  VideoPlayerView.swift
//  Swift-video
//
//  Created by 鍾弘浩 on 2024/3/19.
//

import SwiftUI
import AVKit
import MobileCoreServices

// 建立影片播放器
struct VideoPlayerView: View {
    // 定義影片URL和播放器的狀態
    @State private var videoURL1: URL?
    @State private var videoURL2: URL?
    @State private var isPickerPresented = false
    @State private var player1: AVPlayer?
    @State private var player2: AVPlayer?
    @State private var timeObserver: Any?
    @State private var rateObserver: NSKeyValueObservation?
    @State private var itemObserver: NSKeyValueObservation?
    
    // 建立主體
    var body: some View {
        VStack {
            // 如果有影片URL，則建立視頻播放器
            if let videoURL1 = videoURL1 {
                VideoPlayer(player: player1)
                    .aspectRatio(contentMode: .fit)
                    .onAppear {
                        addTimeObserver()
                        addObservers()
                    }
                    .onDisappear {
                        if let observer = timeObserver {
                            player1?.removeTimeObserver(observer)
                        }
                        rateObserver?.invalidate()
                        itemObserver?.invalidate()
                    }
            }
            
            // 如果有第二個影片URL，則建立第二個影片播放器
            if let videoURL2 = videoURL2 {
                VideoPlayer(player: player2)
                    .aspectRatio(contentMode: .fit)
            }
            
            // 建立一個按鈕，用於選擇影片
            Button(action: {
                isPickerPresented = true
            }) {
                Text("選擇影片")
            }
        }
        .sheet(isPresented: $isPickerPresented) {
            DocumentPicker { url in
                if videoURL1 == nil {
                    saveVideo(url: url, for: &videoURL1, player: &player1, key: "videoURL1")
                } else if videoURL2 == nil {
                    saveVideo(url: url, for: &videoURL2, player: &player2, key: "videoURL2")
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime)) { _ in
            player1?.seek(to: .zero)
            player2?.seek(to: .zero)
            player1?.play()
            player2?.play()
        }
        .onAppear {
            if let savedVideoURL1 = UserDefaults.standard.string(forKey: "videoURL1"), let url1 = URL(string: savedVideoURL1) {
                videoURL1 = url1
                player1 = AVPlayer(url: url1)
            }
            if let savedVideoURL2 = UserDefaults.standard.string(forKey: "videoURL2"), let url2 = URL(string: savedVideoURL2) {
                videoURL2 = url2
                player2 = AVPlayer(url: url2)
            }
        }
    }
    
    // 保存影片的方法
    private func saveVideo(url: URL, for videoURL: inout URL?, player: inout AVPlayer?, key: String) {
        let destinationURL = getDocumentsDirectory().appendingPathComponent(url.lastPathComponent)
        try? FileManager.default.copyItem(at: url, to: destinationURL)
        videoURL = destinationURL
        player = AVPlayer(url: destinationURL)
        
        UserDefaults.standard.set(destinationURL.absoluteString, forKey: key)
        
        if player1 != nil && player2 != nil && player1?.status == .readyToPlay && player2?.status == .readyToPlay {
            addTimeObserver()
            addObservers()
        }
    }
    
    // 獲取文件目錄的方法
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    // 添加觀察方法
    private func addObservers() {
        rateObserver = player1?.observe(\.rate, options: [.new]) { player, change in
            guard let rate = change.newValue else { return }
            DispatchQueue.main.async {
                if self.player2?.status == .readyToPlay {
                    self.player2?.rate = rate
                }
            }
        }
        
        itemObserver = player1?.currentItem?.observe(\.status, options: [.new]) { item, change in
            guard let status = change.newValue, status == .readyToPlay else { return }
            DispatchQueue.main.async {
                if self.player2?.status == .readyToPlay {
                    self.player2?.seek(to: self.player1?.currentTime() ?? CMTime.zero)
                    self.player2?.rate = self.player1?.rate ?? 0
                }
            }
        }
    }
    
    // 添加時間觀察方法
    private func addTimeObserver() {
        let interval = CMTime(seconds: 0.01, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player1?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { time in
            DispatchQueue.main.async {
                if self.player2?.status == .readyToPlay {
                    self.player2?.seek(to: time)
                }
            }
        }
    }
}

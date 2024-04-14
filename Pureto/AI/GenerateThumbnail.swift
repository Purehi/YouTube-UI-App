//
//  SwiftUIView01.swift
//  Pureto
//
//  Created by Pureto on 24/9/23.
//

import SwiftUI
import AVKit
import AVFoundation


public class ACThumbnailGenerator: NSObject {

    private(set) var preferredBitrate: Double
    private(set) var streamUrl: URL
    private(set) var queue: [Double] = []
    
    private var player: AVPlayer?
    private var videoOutput: AVPlayerItemVideoOutput?
    
    private var _completion: (_ generator: ACThumbnailGenerator, _ image: UIImage, _ at: Double) -> Void
    var loading = false
    
    public init(streamUrl: URL, preferredBitrate: Double = 0.0, completion: @escaping (_ generator: ACThumbnailGenerator, _ image: UIImage, _ at: Double) -> Void) {
        self.streamUrl = streamUrl
        self.preferredBitrate = preferredBitrate
        self._completion = completion
    }
    
    deinit {
        clear()
    }
    
    private func prepare(completionHandler: @escaping () -> Void) {
        let asset = AVAsset(url: streamUrl)
        Task{
            do{
                let (_, _, _) =  try await asset.load(.isPlayable, .tracks, .duration)
                let playerItem = AVPlayerItem(asset: asset)
                playerItem.preferredPeakBitRate = self.preferredBitrate 
                
                DispatchQueue.main.async {
                    let settings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
                    self.videoOutput = AVPlayerItemVideoOutput.init(pixelBufferAttributes: settings)
                    if let videoOutput = self.videoOutput {
                        playerItem.add(videoOutput)
                    }
                    
                    self.player = AVPlayer(playerItem: playerItem)
                    self.player?.currentItem?.addObserver(self, forKeyPath: "status", options: [], context: nil)
                    
                    completionHandler()
                }
            }catch{
                print(error.localizedDescription)
            }
        }
        
    }
    
    private func clear() {
        if let player = player {
            player.currentItem?.removeObserver(self, forKeyPath: "status")
            player.pause()
            if let videoOutput = videoOutput {
                player.currentItem?.remove(videoOutput)
                self.videoOutput = nil
            }
            player.currentItem?.asset.cancelLoading()
            player.cancelPendingPrerolls()
            player.replaceCurrentItem(with: nil)
            self.player = nil
        }
    }
    
    public func replaceStreamUrl(newUrl url: URL) {
        streamUrl = url
        clear()
    }
    
    public func captureImage(at position: Double) {
        guard !loading else {
            // If loading, queue new request
            if let index = queue.firstIndex(of: position) {
                queue.remove(at: index)
            }
            queue.append(position)
            return
        }
        loading = true
        
        if player == nil {
            prepare { [weak self] in
                self?.seek(to: position)
            }
        }
        else {
            seek(to: position)
        }
    }
    
    private func seek(to position: Double) {
        Task{
            do{
                let timeScale = try await self.player?.currentItem?.asset.load(.duration).timescale ?? 0
                let targetTime = CMTimeMakeWithSeconds(position, preferredTimescale: timeScale)
                if CMTIME_IS_VALID(targetTime) {
                    await self.player?.seek(to: targetTime)
                }
            }catch{
                print(error.localizedDescription)
            }
        }
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard
            let videoOutput = self.videoOutput,
            let currentItem = self.player?.currentItem,
            currentItem.status == .readyToPlay
            else {
                return
        }
        
        let currentTime = currentItem.currentTime()
        if let buffer = videoOutput.copyPixelBuffer(forItemTime: currentTime, itemTimeForDisplay: nil) {
            let ciImage = CIImage(cvPixelBuffer: buffer)
            let imgRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(buffer), height: CVPixelBufferGetHeight(buffer))
            if let videoImage = CIContext().createCGImage(ciImage, from: imgRect) {
                let image = UIImage.init(cgImage: videoImage)
                _completion(self, image, CMTimeGetSeconds(currentTime))
                loading = false
                
                // Capture the next position in the queue
                if !queue.isEmpty {
                    let position = queue.removeFirst()
                    captureImage(at: position)
                }
            }
        }
    }
}

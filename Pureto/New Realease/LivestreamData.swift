//
//  NewRealeaseItem.swift
//  Pureto
//
//  Created by Pureto on 9/8/23.
//

import SwiftUI

public struct Livestream {
    
    public enum StreamType {
        case hls
    }
    
    public let url: URL
    public let streamType: StreamType
    
}

struct VideoInfo: Decodable {
    let playabilityStatus: PlayabilityStatus?
    let streamingData: StreamingData?
    
    struct PlayabilityStatus: Decodable {
        let status: String?
        let reason: String?
    }
}
struct StreamingData: Decodable {
    let expiresInSeconds: String?
    let formats: [Format]?
    let adaptiveFormats: [Format]? // actually slightly different Format object (TODO)
    let onesieStreamingUrl: String?
    let hlsManifestUrl: String?
    
    struct Format: Decodable {
        let itag: Int
        var url: String?
        let mimeType: String
        let bitrate: Int?
        let width: Int?
        let height: Int?
        let lastModified: String?
        let contentLength: String?
        let quality: String
        let fps: Int?
        let qualityLabel: String?
        let averageBitrate: Int?
        let audioQuality: String?
        let approxDurationMs: String?
        let audioSampleRate: String?
        let audioChannels: Int?
        let signatureCipher: String? // not tested yet
        var s: String? // assigned from Extraction.applyDescrambler
    }
}

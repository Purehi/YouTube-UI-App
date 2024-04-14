//
//  SwiftUIView2.swift
//  Pureto
//
//  Created by Pureto on 12/7/23.
//

import SwiftUI

public class YourTube{
    public let videoID: String
    private var _videoInfo: VideoInfo?
    public init(videoID: String) {
        self.videoID = videoID
    }
    /// Returns a list of live streams - currently only HLS supported
    public var livestreams: [Livestream] {
        get async throws {
            var livestreams = [Livestream]()
            if let hlsManifestUrl = try await streamingData.hlsManifestUrl.flatMap({ URL(string: $0) }) {
                livestreams.append(Livestream(url: hlsManifestUrl, streamType: .hls))
            }
            return livestreams
        }
    }

    /// streaming data from video info
    var streamingData: StreamingData {
        get async throws {
            if let streamingData = try await videoInfo.streamingData {
                return streamingData
            } else {
                try await bypassAgeGate()
                if let streamingData = try await videoInfo.streamingData {
                    return streamingData
                } else {
                    throw YourTubeKitError.extractError
                }
            }
        }
    }

    var videoInfo: VideoInfo {
        get async throws {
            if let cached = _videoInfo {
                return cached
            }
            let innerYourtube = InnerYourTube()
            let innertubeResponse = try await innerYourtube.player(videoID: videoID)
            _videoInfo = innertubeResponse
            return innertubeResponse
        }
    }
    private func bypassAgeGate() async throws {
        let innertube = InnerYourTube(client: .tvEmbed)
        let innertubeResponse = try await innertube.player(videoID: videoID)
        
        if innertubeResponse.playabilityStatus?.status == "UNPLAYABLE" || innertubeResponse.playabilityStatus?.status == "LOGIN_REQUIRED" {
            throw YourTubeKitError.videoAgeRestricted
        }
        
        _videoInfo = innertubeResponse
    }
}



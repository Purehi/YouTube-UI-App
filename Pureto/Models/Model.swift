//
//  SwiftUIView.swift
//  Pureto
//
//  Created by Pureto on 12/7/23.
//

import SwiftUI
import UIKit

struct ApiResponse: Codable {
    var status: String
    var visitorData: String?
    var sections: [SectionListRenderer]?
    var videos: [VideoData]?
    var nextContinuation: String?
    var reloadContinuation: String?
    var reelSection: reelSectionRenderer?
    var commentSection:commentsHeaderRenderer?
    var header: String?
    var reels: [ReelData]?
    var carouselVideos: [VideoData]?
    var compactRenderers:[CompactRenderer]?
    var commands: [MusicMenuItem]?
    var mutations: [Payload]?
    var ranks: [MusicVideo]?
    var trends: [MusicVideo]?
    var comments: [CommentThread]?
    var browseId: String?
    var filters: [SearchFilterRenderer]?
    var hlsManifestUrl: String?
    var recsVideos:[VideoData]?
    var message: String
}

struct SearchRenderer: Codable{
    var filters: [SearchFilterRenderer]?
    var nextContinuation: String?
    var videos: [VideoData]?
    var reels: [ReelData]?
}


struct SearchFilterRenderer: Codable{
    let title: String
    let params: String
}

struct ShortsRenderer: Codable {
    let videoId: String
    let commentRenderer: [ShortsCommentRenderer]?
    let reelPlayer: ReelPlayerRenderer
    
}
struct ShortsCommentRenderer: Codable {
    let title: String
    let continuation: String
    
}

struct ReelPlayerRenderer: Codable {

    let videoId: String
    let reelTitleText: String
    let timestampText: String
    let channelId: String
    let channelName: String
    let avatar: String
    
}
struct ReelItem: Codable {
    
    let videoId: String
    let thumbnail: String
    let params: String
}

struct CommentRenderer: Codable{
    let videoId: String
    let comments: [CommentThread]?
    let nextContinuation: String?
}
struct CommentThread: Codable{
    let commentId: String
    let authorText: String
    let authorThumbnail: String
    let contentText: String
    let publishedTimeText: String
    let voteCount: String

}
struct MusicSection: Codable {
    let countryId: String
    let ranks: [MusicVideo]?
}
struct MusicVideo: Codable {
    let videoId: String
    let thumbnail: String
    let title: String
    let subtitle: String
    let indexColumn: String
    let iconType: String
}
struct NewVideo: Codable {
    let videoId: String
    let thumbnail: String
    let title: String
    let subtitle: String
}

struct MusicMenuItem: Codable {
    let title: String
    let formItemEntityKey: String
}
struct Payload: Codable {
    let id: String
    let opaqueToken: String
}

struct PlaylistVideos: Codable {
    let playlistId: String
    var videos: [VideoData]?
}

struct CompactRenderer: Codable {
    let title: String
    let stations: [CompactStationRenderer]?
}

struct CompactStationRenderer: Codable {
    let playlistId: String
    let params: String
    let thumbnail: String
    let title: String
    let description: String
    let videoCountText: String
    
}

struct NewJeans: Codable{
    let header: String?
    let reels: [ReelData]?
}
struct RecsRenderer: Codable{
    let videoId: String
    let headerRenderer: commentsHeaderRenderer?
    let videos: [VideoData]?
}
struct reelSectionRenderer: Codable {
    let title: String
    let reels: [ReelData]
}
struct commentsHeaderRenderer: Codable{
    
    let headerText: String
    let commentCount: String
    let teasers: [TeaserRenderer]?
    var nextContinuation: String?
    var reloadContinuation: String?

}

struct TeaserRenderer: Codable{
    
    let avatar: String
    let author: String
    let content: String
}

struct ReelData: Codable {
    
    let videoId: String
    let videoTitle: String
    let bottomText: String
    let thumbnail: String
    let params: String
    let sequenceParams: String
}

struct LinkRenderer: Codable{
    let videoId: String
    let hlsManifestUrl: String?
    let links: [LinkItem]?
}
struct LinkItem: Codable{
    let url: String
    let tag: Int
    let isLive: Bool
}

struct SectionListRenderer: Codable {
    let params: String
    var videos: [VideoData]?
    var nextContinuation: String?
    var reloadContinuation: String?
}
struct VideoData: Codable {
    let videoId: String
    let title: String
    let timestampText: String
    let thumbnail: String
    let avatar: String
    let metadataDetails: String
}

//let host:String = "http://127.0.0.1:8080/api/v1/music"
let host:String = "http://broker.happyitapp.com:8082/api/v1/music"

let countries = [
    "US",
    "ZZ",
    "AR",
    "AU",
    "AT",
    "BE",
    "BO",
    "BR",
    "CA",
    "CL",
    "CO",
    "CR",
    "CZ",
    "DK",
    "DO",
    "EC",
    "EG",
    "SV",
    "EE",
    "FI",
    "FR",
    "DE",
    "GT",
    "HN",
    "HU",
    "IS",
    "IN",
    "ID",
    "IE",
    "IL",
    "IT",
    "JP",
    "KE",
    "LU",
    "MX",
    "NL",
    "NZ",
    "NI",
    "NG",
    "NO",
    "PA",
    "PY",
    "PE",
    "PL",
    "PT",
    "RO",
    "RU",
    "SA",
    "RS",
    "ZA",
    "KR",
    "ES",
    "SE",
    "CH",
    "TZ",
    "TR",
    "UG",
    "UA",
    "AE",
    "GB",
    "UY",
    "ZW"
]

extension String{
    func fillter() -> String{
        let fillters = ["twitter", "facebook", "youtube", "viemo", "netflix", "disney", "espn", "cbs sports golazo", "official video", "official music video","official trailer","official","apple tv+","hulu","tiktok","tik tok","tv","()","[]"]
        var title = self
     
        for fillter in fillters {
            let tempTitle = title.lowercased()
            if let range = tempTitle.range(of: fillter) {
                title = title.replacingCharacters(in: range,with: "")
            }
        }
        title = title.replacingOccurrences(of: "Netflix", with: "")
        return title
    }
    func removeAuthor() -> String?{
        let array = self.split(separator: "·")
        var index = 0
        var title = ""
        for a in array{
            if index == 0{
                index += 1
                continue
            }else{
                if index < array.count - 1 {
                    title += "\(a) · "
                }else{
                    title += "\(a)"
                }
                index += 1
            }
        }
        if title.count > 0{
            return title
        }
        return nil
    }
    func removeMusicAuthor() -> String?{
        let array = self.split(separator: "•")
        var index = 0
        var title = ""
        for a in array{
            if index == 0{
                index += 1
                continue
            }
            title += "\(a)"
        }
        if title.count > 0{
            return title
        }
        return nil
    }
    func isFillter() -> Bool{
        let fillters = ["apple tv", "twitter", "facebook", "youtube", "viemo", "netflix", "disney", "espn", "hulu", "cbs sports golazo","official", "tiktok"]
        let title = self
        var isContain = false
        for fillter in fillters {
            isContain = title.lowercased().contains(fillter)
            if isContain == true{
                return isContain
            }
        }
        return isContain
    }
}

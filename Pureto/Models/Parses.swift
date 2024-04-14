//
//  SwiftUIView3.swift
//  Pureto
//
//  Created by Pureto on 3/8/23.
//

import SwiftUI
import SwiftyJSON

// parse Tabs
func parseTabs(json: JSON) -> [JSON]?{
    guard let contents = json.dictionaryValue["contents"] else { return nil }
    guard let singleColumnBrowseResultsRenderer = contents.dictionaryValue["singleColumnBrowseResultsRenderer"] else{return nil}
    guard let tabs = singleColumnBrowseResultsRenderer.dictionaryValue["tabs"]?.arrayValue else{return nil}
    return tabs
   
}

// parse sectionListRenderer
func parseSectionListRenderer(json: JSON) -> JSON?{
    guard let tabRenderer = json.dictionaryValue["tabRenderer"] else { return nil }
    guard let content = tabRenderer.dictionaryValue["content"] else{return nil}
    guard let sectionListRenderer = content.dictionaryValue["sectionListRenderer"] else{return nil}
    return sectionListRenderer
   
}

func parseMusicVideo(json: JSON) -> NewVideo?{
    guard let musicTwoRowItemRenderer = json.dictionaryValue["musicTwoRowItemRenderer"] else{return nil}
    guard let thumbnail = parseThumbnailRenderer(json: musicTwoRowItemRenderer) else{return nil}
    guard let titleJson = musicTwoRowItemRenderer.dictionaryValue["title"] else { return nil }
    guard let title = parseTitle(json: titleJson) else {return nil}
    guard let subTitleJson = musicTwoRowItemRenderer.dictionaryValue["subtitle"] else { return nil }
    guard let subtitle = parseTitle(json: subTitleJson) else{return nil}
    guard let videoId = parseVideoId(json: musicTwoRowItemRenderer) else{return nil}
    let newVideo = NewVideo(videoId: videoId, thumbnail: thumbnail, title: title, subtitle: subtitle)
    return newVideo
}

// parse thumbnailRenderer
func parseThumbnailRenderer(json:JSON) -> String?{
    guard let thumbnailRenderer = json.dictionaryValue["thumbnailRenderer"] else {return nil}
    guard let musicThumbnailRenderer = thumbnailRenderer.dictionaryValue["musicThumbnailRenderer"] else {return nil}
    guard let thumbnail = musicThumbnailRenderer.dictionaryValue["thumbnail"] else{return nil}
    guard let thumbnails = thumbnail.dictionaryValue["thumbnails"]?.arrayValue else{return nil}
    let thumbnailJSON = thumbnails.last
    let thumbnailStr = thumbnailJSON?.dictionaryValue["url"]?.stringValue
    return thumbnailStr
}
func parseTitle(json:JSON) -> String?{
    guard let runs = json.dictionaryValue["runs"]?.arrayValue else {return nil}
    var title: String?
    for run in runs{
        let text = run.dictionaryValue["text"]?.stringValue
        if text != nil{
            if title != nil
            {
                title! += text!
                
            }else{
                title = text!
            }
        }
    }
    return title
}
// parse videoId
func parseVideoId(json: JSON) -> String?{
    guard let navigationEndpoint = json.dictionaryValue["navigationEndpoint"] else {return nil}
    guard let watchEndpoint = navigationEndpoint.dictionaryValue["watchEndpoint"] else {return nil}
    guard let videoId = watchEndpoint.dictionaryValue["videoId"]?.stringValue else{return nil}
    return videoId
}

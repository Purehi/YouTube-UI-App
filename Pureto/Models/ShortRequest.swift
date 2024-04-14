//
//  SwiftUIView.swift
//  Pureto
//
//  Created by Pureto on 9/8/23.
//

import SwiftUI
import SwiftyJSON


class ShortRequest: ObservableObject{
    @Published var reelItems: [ReelItem] = []
//    @Published var commentRenderers: [ShortsCommentRenderer]?
    @Published var renderers: [ReelPlayerRenderer] = []
    static var shared = ShortRequest()
    var visitorData: String?
    var nextContinuation: String?
    // On initialize of the class, fetch the context
    private init() {}
    private let contextURL = "https://www.you"+"tube.com/yout"+"ubei/v1/reel/reel_item_watch?key=AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8&prettyPrint=false"
    private let shortURL = "https://www.you"+"tube.com/yout"+"ubei/v1/reel/reel_watch_sequence?key=AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8&prettyPrint=false"

    
    
    func fetchContext() async{
        guard let url = URL(string: "\(contextURL)") else { fatalError("Missing URL") }
        let localeLanguageCode = (Locale.current as NSLocale).object(forKey: .languageCode) as? String ?? "en"
        var localeCountryCode =  (Locale.current as NSLocale).object(forKey: .countryCode) as? String ?? "US"
        // Make sure we have a URL before continuing
        if localeCountryCode.uppercased() == "CN"{
            localeCountryCode = "HK"
        }
        let body = String(format: #"{"context":{"client":{"clientName":"IOS","clientVersion":"18.31.3","deviceModel":"iPhone14,3","gl":"%@",hl:"%@"}},"inputType":"REEL_WATCH_INPUT_TYPE_SEEDLESS","autonavState":"STATE_ON","params":"CA8="}"#, localeCountryCode.uppercased(),localeLanguageCode.lowercased())
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("com.goo"+"gle.ios.you"+"tube/", forHTTPHeaderField: "User-Agent")
        urlRequest.httpBody = body.data(using: .utf8)
        do{
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            // Making sure the response is 200 OK before continuing
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("Error while fetching data") }
            guard let json = try? JSON(data: data) else{return}
            guard let sequenceContinuation = json.dictionaryValue["sequenceContinuation"]?.stringValue else{return}
            let responseContext = json.dictionaryValue["responseContext"]
            guard let visitorData = responseContext?.dictionaryValue["visitorData"]?.stringValue else{
                return
            }
            self.visitorData = visitorData
            await self.fetchShorts(sequenceParams: sequenceContinuation)
        }catch{
            print(error)
        }

    }
    
    func fetchShorts(sequenceParams: String) async{
        guard let url = URL(string: "\(shortURL)") else { fatalError("Missing URL") }
        let localeLanguageCode = (Locale.current as NSLocale).object(forKey: .languageCode) as? String ?? "en"
        
        var localeCountryCode =  (Locale.current as NSLocale).object(forKey: .countryCode) as? String ?? "US"
        if localeCountryCode.uppercased() == "CN"{
            localeCountryCode = "HK"
        }
        // Make sure we have a URL before continuing
        let body = String(format: #"{"context":{"client":{"clientName":"IOS","clientVersion":"18.31.3","deviceModel":"iPhone14,3","gl":"%@",hl:"%@","visitorData":"%@"}},"sequenceParams":"%@"}"#, localeCountryCode.uppercased(),localeLanguageCode.lowercased(),self.visitorData ?? "", sequenceParams)
            
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("com.goo"+"gle.ios.you"+"tube/", forHTTPHeaderField: "User-Agent")
        urlRequest.httpBody = body.data(using: .utf8)
        do{
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            // Making sure the response is 200 OK before continuing
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("Error while fetching data") }
            guard let json = try? JSON(data: data) else{return}
            guard let videos = praseShortVideos(json: json) else{return}
            DispatchQueue.main.async{
                self.reelItems.append(contentsOf: videos)
                self.nextContinuation = json.dictionaryValue["continuation"]?.stringValue
            }
        }catch{
            print(error)
        }

    }
    func fetchNextShorts() async{
        guard let url = URL(string: "\(shortURL)") else { fatalError("Missing URL") }
        let localeLanguageCode = (Locale.current as NSLocale).object(forKey: .languageCode) as? String ?? "en"
        var localeCountryCode =  (Locale.current as NSLocale).object(forKey: .countryCode) as? String ?? "US"
        if localeCountryCode.uppercased() == "CN"{
            localeCountryCode = "HK"
        }
        // Make sure we have a URL before continuing
        let body = String(format: #"{"context":{"client":{"clientName":"IOS","clientVersion":"18.31.3","deviceModel":"iPhone14,3","gl":"%@",hl:"%@","visitorData":"%@"}},"continuation":"%@"}"#, localeCountryCode.uppercased(),localeLanguageCode.lowercased(),self.visitorData ?? "", self.nextContinuation ?? "")
            
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("com.goo"+"gle.ios.you"+"tube/", forHTTPHeaderField: "User-Agent")
        urlRequest.httpBody = body.data(using: .utf8)
        do{
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            // Making sure the response is 200 OK before continuing
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("Error while fetching data") }
            guard let json = try? JSON(data: data) else{return}
            guard let videos = praseShortVideos(json: json) else{return}
            DispatchQueue.main.async {
                
                self.reelItems.append(contentsOf: videos)
                self.nextContinuation = json.dictionaryValue["continuation"]?.stringValue
            }
        }catch{
            print(error)
        }

    }
    func fetchShortsRender(videoId: String, params: String) async{
        guard let url = URL(string: "\(contextURL)") else { fatalError("Missing URL") }
        let localeLanguageCode = (Locale.current as NSLocale).object(forKey: .languageCode) as? String ?? "en"
        var localeCountryCode =  (Locale.current as NSLocale).object(forKey: .countryCode) as? String ?? "US"
        if localeCountryCode.uppercased() == "CN"{
            localeCountryCode = "HK"
        }
        // Make sure we have a URL before continuing
        let body = String(format: #"{"context":{"client":{"clientName":"IOS","clientVersion":"18.31.3","deviceModel":"iPhone14,3","gl":"%@",hl:"%@","visitorData":"%@"}},"params":"%@","playerRequest":{"videoId":"%@"}}"#, localeCountryCode.uppercased(),localeLanguageCode.lowercased(),self.visitorData ?? "", self.nextContinuation ?? "", params, videoId)
            
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("com.goo"+"gle.ios.you"+"tube/", forHTTPHeaderField: "User-Agent")
        urlRequest.httpBody = body.data(using: .utf8)
        do{
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            // Making sure the response is 200 OK before continuing
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("Error while fetching data") }
            guard let json = try? JSON(data: data) else{return}
            guard let reelRenderer = self.praseRender(json: json, videoId: videoId) else{return}
            DispatchQueue.main.async {
                self.renderers.append(reelRenderer)
            }
        }catch{
            print(error)
        }

    }
    private func praseRender(json: JSON, videoId: String) -> ReelPlayerRenderer?{
        guard let overlay = json.dictionaryValue["overlay"]?.dictionary else{return nil}
        guard let reelPlayerOverlayRenderer_ = overlay["reelPlayerOverlayRenderer"]?.dictionaryValue else{return nil}
        guard let reelPlayerHeaderSupportedRenderers = reelPlayerOverlayRenderer_["reelPlayerHeaderSupportedRenderers"]?.dictionaryValue else{return nil}
        guard let reelPlayerHeaderRenderer = reelPlayerHeaderSupportedRenderers["reelPlayerHeaderRenderer"]?.dictionaryValue else{return nil}
        
        var reelTitle = ""
        let reelTitleText = reelPlayerHeaderRenderer["reelTitleText"]?.dictionaryValue
        let runs_ = reelTitleText?["runs"]?.arrayValue ?? []
        for run_ in runs_ {
            let text = run_.dictionaryValue["text"]?.stringValue ?? ""
            reelTitle += text
        }
        let timestampText = reelPlayerHeaderRenderer["timestampText"]?.dictionaryValue
        var time = ""
        let runs__ = timestampText?["runs"]?.arrayValue ?? []
        for run__ in runs__ {
            let text = run__.dictionaryValue["text"]?.stringValue ?? ""
            time += text
        }
        
        let channelTitleText = reelPlayerHeaderRenderer["channelTitleText"]?.dictionaryValue
        var channelTitle = ""
        let _runs_ = channelTitleText?["runs"]?.arrayValue ?? []
        for _run_ in _runs_ {
            let text = _run_.dictionaryValue["text"]?.stringValue ?? ""
            channelTitle += text
        }
        
        guard let channelThumbnail = reelPlayerHeaderRenderer["channelThumbnail"]?.dictionaryValue else{return nil}
        guard let thumbnails = channelThumbnail["thumbnails"]?.arrayValue else{return nil}
        guard let thumbnail = thumbnails.first else{return nil}
        guard let thumbnailUrl = thumbnail.dictionaryValue["url"]?.stringValue else{return nil}

        guard let channelNavigationEndpoint = reelPlayerHeaderRenderer["channelNavigationEndpoint"] else{return nil}
        guard let browseEndpoint = channelNavigationEndpoint.dictionaryValue["browseEndpoint"] else{return nil}
        guard let browseId = browseEndpoint.dictionaryValue["browseId"]?.stringValue else{return nil}
                
        

        let render = ReelPlayerRenderer(videoId: videoId, reelTitleText: reelTitle, timestampText: time , channelId: browseId, channelName: channelTitle, avatar: thumbnailUrl)

        return render
    }

   private func parseSource(json: JSON?) -> String?{
        guard let image = json?.dictionaryValue["image"] else{
            guard let sources = json?.dictionaryValue["sources"]?.arrayValue else{return nil}
            for source in sources {
                let url = source.dictionaryValue["url"]?.stringValue
                return url
            }
            return nil
        }
        let sources = image.dictionaryValue["sources"]?.arrayValue ?? []
        for source in sources {
            let url = source.dictionaryValue["url"]?.stringValue
            return url
        }
        return nil
    }


    private func praseShortVideos(json: JSON) -> [ReelItem]?{
        guard let entries = json.dictionaryValue["entries"]?.arrayValue else{return nil}
        var shortVideos:[ReelItem] = []
        for subJson in entries{
            guard let command = subJson.dictionaryValue["command"]?.dictionaryValue else{continue}
            guard let reelWatchEndpoint = command["reelWatchEndpoint"]?.dictionaryValue else{continue}
            guard let videoId = reelWatchEndpoint["videoId"]?.stringValue else{continue}
            guard let params = reelWatchEndpoint["params"]?.stringValue else{continue}
            guard let thumbnail = reelWatchEndpoint["thumbnail"]?.dictionaryValue else{continue}
            guard let thumbnails = thumbnail["thumbnails"]?.arrayValue else{continue}
            guard let thumbnail_ = thumbnails.first else{continue}
            guard let thumbnailURL = thumbnail_.dictionaryValue["url"]?.stringValue else{continue}
            let video = ReelItem(videoId: videoId, thumbnail: thumbnailURL, params: params)
            shortVideos.append(video)
        }
        if shortVideos.count > 0{
            return shortVideos
        }
        return nil
        
    }
}

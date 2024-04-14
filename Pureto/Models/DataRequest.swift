//
//  SwiftUIView1.swift
//  Pureto
//
//  Created by Pureto on 12/7/23.
//

import SwiftUI
import SwiftyJSON


class DataRequest: ObservableObject {
    @Published var sections: [SectionListRenderer] = []
    @Published private(set) var linkSections: [LinkRenderer] = []
    @Published private(set) var recsSections:[RecsRenderer] = []
    @Published private(set) var commentSections:[CommentRenderer] = []
    @Published private(set) var playlistVideos:[PlaylistVideos] = []
    @Published private(set) var compactRenderers:[CompactRenderer]?
    @Published private(set) var menuStations: [CompactStationRenderer]? = nil
    @Published private(set) var carouselVideos: [VideoData]? = nil
    @Published private(set) var popularVideos: [VideoData]? = nil
    @Published private(set) var menuItems: [CompactStationRenderer]? = nil
    @Published var selectedItem: VideoData? = nil
    @Published var newJeans: NewJeans? = nil
    @Published private(set) var commands: [MusicMenuItem]? = nil
    @Published private(set) var mutations: [Payload]? = nil
    @Published var ranks: [MusicSection] = []
    @Published private(set) var trends: [MusicVideo]? = nil
    @Published private(set) var visitorData: String?
    @Published private(set) var browseId: String?
    @Published var countryId: String?
    @Published var search: SearchRenderer?
    @Published private(set) var hightlightVideos: [VideoData]? = nil
    @Published private(set) var reelVideos: [ReelData]? = nil

    //MARK: review data
    @Published var reviewVideos: [VideoData]?
    @Published var reviewReels: [ReelData]?
    @Published var reviewCarouselVideos: [VideoData]?
    @Published var reviewRecsVideos:[VideoData]?
    
    @Published var isReview = true
    
    static var shared = DataRequest()
    // On initialize of the class, fetch the context
    private init() {}
    
    func fetchAppReviewData() async {
        do {
            guard let url = URL(string: "\(host)") else { fatalError("Missing URL") }
            let body = String(format: #"{"action":"review"}"#)
            // Create a URLRequest
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = body.data(using: .utf8)
            // Fetching the data
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            // Making sure the response is 200 OK before continuing
            //            print(String(data: data, encoding: .utf8) as Any)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("Error while fetching data") }
            // Creating a JSONDecoder instance
            let decoder = JSONDecoder()
            // Allows us to convert the data from the API from snake_case to cameCase
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            // Decode into the Response struct below
            let decodedData = try decoder.decode(ApiResponse.self, from: data)
            DispatchQueue.main.async {
                // Assigning the sections we fetched from the API
                self.reviewVideos = decodedData.videos
                self.reviewReels = decodedData.reels
                self.reviewCarouselVideos = decodedData.carouselVideos
                self.reviewRecsVideos = decodedData.recsVideos
            }
            
        } catch {
            // If we run into an error, print the error in the console
            print("Error fetching data from Review: \(error)")
        }
    }
    func fetchAppUpdated(appId: String) async{
        do{
            //MARK: Local Version
            let localVersion: String = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
//            print(localVersion)
            //MARK: App Store
            let urlString = "https://itunes.apple.com/lookup?id=\(appId)"
            var urlRequest = URLRequest(url: URL(string: urlString)!)
            urlRequest.httpMethod = "GET"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            // Fetching the data
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
//            print(String(data: data, encoding: .utf8) as Any)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("Error while fetching data") }
            guard let jsonString = String(data: data, encoding: .utf8) else{
                if self.reviewRecsVideos == nil{
                    Task.detached {
                        await self.fetchAppReviewData()
                    }
                }
                return
            }
           
            let json =  JSON(parseJSON: jsonString)
            guard let result = json.dictionaryValue["results"]?.arrayValue.first else{
                if self.reviewRecsVideos == nil{
                    Task.detached {
                        await self.fetchAppReviewData()
                    }
                }
                return
            }
            guard let version = result.dictionaryValue["version"]?.stringValue else{
                if self.reviewRecsVideos == nil{
                    Task.detached {
                        await self.fetchAppReviewData()
                    }
                }
                return
            }
            guard let appVersionNumber = Int(version.replacingOccurrences(of: ".", with: "")) else{
                if self.reviewRecsVideos == nil{
                    Task.detached {
                        await self.fetchAppReviewData()
                    }
                }
                return
            }
            guard let localVersionNumber = Int(localVersion.replacingOccurrences(of: ".", with: "")) else{
                if self.reviewRecsVideos == nil{
                    Task.detached {
                        await self.fetchAppReviewData()
                    }
                }
                return
            }
            if localVersionNumber <= appVersionNumber{
                DispatchQueue.main.async {
                    self.isReview = false
                }
                if self.carouselVideos == nil{
                    Task.detached {
                        await self.fetchMusicChannelsData()
                    }
                }
                if self.hightlightVideos == nil{
                    Task.detached {
                        await self.fetchHightlightData()
                    }
                }

                    //                print(localVersionNumber)
//                print(appVersionNumber)
            }else{
                if self.reviewRecsVideos == nil{
                    Task.detached {
                        await self.fetchAppReviewData()
                    }
                }

            }
        }catch{
            print(error.localizedDescription)
        }
        
    }
    // Fetching the init data asynchronously
    func fetchHightlightData() async {
        do {
            guard let url = URL(string: "\(host)") else { fatalError("Missing URL") }
            var localeCountryCode =  (Locale.current as NSLocale).object(forKey: .countryCode) as? String ?? "US"
            // Make sure we have a URL before continuing
            let localeLanguageCode = (Locale.current as NSLocale).object(forKey: .languageCode) as? String ?? "en"
    
            //filter china
            if localeCountryCode.uppercased() == "CN"{
                localeCountryCode = "HK"
            }
//            if localeCountryCode.uppercased() == "US"{
//                localeCountryCode = "US"
//                localeLanguageCode = "vi"
//            }
            let body = String(format: #"{"action":"trends", "gl":"%@", "hl":"%@"}"#, localeCountryCode.uppercased(), localeLanguageCode.lowercased())
        // Create a URLRequest
        var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = body.data(using: .utf8)
        
            // Fetching the data
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            // Making sure the response is 200 OK before continuing
//            print(String(data: data, encoding: .utf8) as Any)
            
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("Error while fetching data") }
            
            // Creating a JSONDecoder instance
            let decoder = JSONDecoder()
            
            // Allows us to convert the data from the API from snake_case to cameCase
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            // Decode into the Response struct below
            let decodedData = try decoder.decode(ApiResponse.self, from: data)

            DispatchQueue.main.async {
                // Assigning the sections we fetched from the API
                guard let videos = decodedData.videos else{return}
                self.hightlightVideos = videos
                self.reelVideos = decodedData.reels
            }

        } catch {
            // If we run into an error, print the error in the console
            print("Error fetching data from Pexels: \(error)")
        }
    }
    // Fetching the init data asynchronously
    func fetchPopularData() async {
        do {
            guard let url = URL(string: "\(host)") else { fatalError("Missing URL") }
            var localeCountryCode =  (Locale.current as NSLocale).object(forKey: .countryCode) as? String ?? "US"
            // Make sure we have a URL before continuing
            let localeLanguageCode = (Locale.current as NSLocale).object(forKey: .languageCode) as? String ?? "en"
    
            //filter china
            if localeCountryCode.uppercased() == "CN"{
                localeCountryCode = "HK"
            }
//            if localeCountryCode.uppercased() == "US"{
//                localeCountryCode = "US"
//                localeLanguageCode = "vi"
//            }
            let body = String(format: #"{"action":"popular", "gl":"%@", "hl":"%@"}"#, localeCountryCode.uppercased(), localeLanguageCode.lowercased())
        // Create a URLRequest
        var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = body.data(using: .utf8)
        
            // Fetching the data
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            // Making sure the response is 200 OK before continuing
            
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("Error while fetching data") }
            
            // Creating a JSONDecoder instance
            let decoder = JSONDecoder()
            
            // Allows us to convert the data from the API from snake_case to cameCase
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            // Decode into the Response struct below
            let decodedData = try decoder.decode(ApiResponse.self, from: data)

            DispatchQueue.main.async {
                // Assigning the sections we fetched from the API
                guard let videos = decodedData.videos?.shuffled() else{return}
                self.popularVideos = videos
//                if videos.count > 0{
//                    self.popularVideos = []
//                }
//                videos.indices.forEach { index in
//                    let videoData = videos[index]
//                    if index == 1 || index == 5 || index == 9{
//                        self.popularVideos?.append(VideoData(videoId: "", title: "", timestampText: "", thumbnail: "", avatar: "", metadataDetails: ""))
//                    }else{
//                        self.popularVideos?.append(videoData)
//                    }
//                }
            }

        } catch {
            // If we run into an error, print the error in the console
            print("Error fetching data from Pexels: \(error)")
        }
    }
    // Fetching the init data asynchronously
    func fetchData(params: String) async {
        do {
            guard let url = URL(string: "\(host)") else { fatalError("Missing URL") }
            var localeCountryCode =  (Locale.current as NSLocale).object(forKey: .countryCode) as? String ?? "US"
            // Make sure we have a URL before continuing
            let localeLanguageCode = (Locale.current as NSLocale).object(forKey: .languageCode) as? String ?? "en"
    
            //filter china
            if localeCountryCode.uppercased() == "CN"{
                localeCountryCode = "HK"
            }
//            if localeCountryCode.uppercased() == "US"{
//                localeCountryCode = "US"
//                localeLanguageCode = "vi"
//            }
            let body = String(format: #"{"action":"trend", "gl":"%@", "hl":"%@","params":"%@"}"#, localeCountryCode.uppercased(), localeLanguageCode.lowercased(), params)
        // Create a URLRequest
        var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = body.data(using: .utf8)
        
            // Fetching the data
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            // Making sure the response is 200 OK before continuing
            
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("Error while fetching data") }
            
            // Creating a JSONDecoder instance
            let decoder = JSONDecoder()
            
            // Allows us to convert the data from the API from snake_case to cameCase
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            // Decode into the Response struct below
            let decodedData = try decoder.decode(ApiResponse.self, from: data)

            DispatchQueue.main.async {
                // Assigning the sections we fetched from the API
                if decodedData.visitorData != nil{
                    self.visitorData = decodedData.visitorData
                }
                guard let videos = decodedData.videos else{return}
                let section = SectionListRenderer(params: params, videos: videos, nextContinuation: decodedData.nextContinuation, reloadContinuation: decodedData.reloadContinuation)
                self.sections.append(section)
            }

        } catch {
            // If we run into an error, print the error in the console
            print("Error fetching data from Pexels: \(error)")
        }
    }
    
    // Fetching the init data asynchronously
    func fetchStreamData(params: String, token: String) async {
     

        do {
            guard let url = URL(string: "\(host)") else { fatalError("Missing URL") }
            let localeLanguageCode = (Locale.current as NSLocale).object(forKey: .languageCode) as? String ?? "en"
            var localeCountryCode =  (Locale.current as NSLocale).object(forKey: .countryCode) as? String ?? "US"
            if localeCountryCode.uppercased() == "CN"{
                localeCountryCode = "HK"
            }
//            if localeCountryCode.uppercased() == "US"{
//                localeCountryCode = "US"
//                localeLanguageCode = "vi"
//            }
      
            // Make sure we have a URL before continuing
            let body = String(format: #"{"action":"stream", "gl":"%@", "hl":"%@", "token":"%@", "visitorData":"%@"}"#, localeCountryCode.uppercased(), localeLanguageCode.lowercased(), token, visitorData ?? "")
        // Create a URLRequest
        var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = body.data(using: .utf8)
        
            // Fetching the data
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            // Making sure the response is 200 OK before continuing
            
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("Error while fetching data") }
            
            // Creating a JSONDecoder instance
            let decoder = JSONDecoder()
            
            // Allows us to convert the data from the API from snake_case to cameCase
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            // Decode into the Response struct below
            let decodedData = try decoder.decode(ApiResponse.self, from: data)

            DispatchQueue.main.async {
                // Assigning the sections we fetched from the API
                guard let videos = decodedData.videos else{return}
                let results = self.sections.filter{$0.params == params}
                if results.count > 0{
                    let first = results.first
                    if first != nil{
                        var tempVideos = results.first?.videos ?? []
                        tempVideos.append(contentsOf: videos)
                        
                        self.sections.removeAll{$0.params == params}
                        let section = SectionListRenderer(params: params,videos: tempVideos, nextContinuation: decodedData.nextContinuation, reloadContinuation: decodedData.reloadContinuation )
                        self.sections.append(section)
                    }
                }
               
            }

        } catch {
            // If we run into an error, print the error in the console
            print("Error fetching data from Pexels: \(error)")
        }
    }
    // Fetching the recs data asynchronously
    func fetchRecsData(videoId: String) async {
        do {
            guard let url = URL(string: "\(host)") else { fatalError("Missing URL") }
            let localeLanguageCode = (Locale.current as NSLocale).object(forKey: .languageCode) as? String ?? "en"
            var localeCountryCode =  (Locale.current as NSLocale).object(forKey: .countryCode) as? String ?? "US"
            // Make sure we have a URL before continuing
            if localeCountryCode.uppercased() == "CN"{
                localeCountryCode = "HK"
            }
//            if localeCountryCode.uppercased() == "US"{
//                localeCountryCode = "US"
//                localeLanguageCode = "vi"
//            }
            let body = String(format: #"{"action":"recs", "gl":"%@", "hl":"%@", "videoId":"%@", "visitorData":"%@"}"#, localeCountryCode.uppercased(), localeLanguageCode.lowercased(), videoId, visitorData ?? "")
        // Create a URLRequest
        var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = body.data(using: .utf8)
        
            // Fetching the data
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
//            print(String(data: data, encoding: .utf8) as Any)
            // Making sure the response is 200 OK before continuing
            
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("Error while fetching data") }
            
            // Creating a JSONDecoder instance
            let decoder = JSONDecoder()
            
            // Allows us to convert the data from the API from snake_case to cameCase
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            // Decode into the Response struct below
            let decodedData = try decoder.decode(ApiResponse.self, from: data)

            DispatchQueue.main.async {
                // Assigning the sections we fetched from the API
                let recs = RecsRenderer(videoId: videoId, headerRenderer: decodedData.commentSection, videos: decodedData.videos)
                self.recsSections.append(recs)
            }

        } catch {
            // If we run into an error, print the error in the console
            print("Error fetching data from Pexels: \(error)")
        }
    }
    // Fetching the comment data asynchronously
    func fetchCommentData(videoId: String, token: String) async {
   
        do {
            guard let url = URL(string: "\(host)") else { fatalError("Missing URL") }
            let localeLanguageCode = (Locale.current as NSLocale).object(forKey: .languageCode) as? String ?? "en"
            var localeCountryCode =  (Locale.current as NSLocale).object(forKey: .countryCode) as? String ?? "US"
            // Make sure we have a URL before continuing
            if localeCountryCode.uppercased() == "CN"{
                localeCountryCode = "HK"
            }
//            if localeCountryCode.uppercased() == "US"{
//                localeCountryCode = "US"
//                localeLanguageCode = "vi"
//            }
            let body = String(format: #"{"action":"comment", "gl":"%@", "hl":"%@", "token":"%@", "visitorData":"%@"}"#, localeCountryCode.uppercased(), localeLanguageCode.lowercased(), token, visitorData ?? "")
        // Create a URLRequest
        var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = body.data(using: .utf8)
        
            // Fetching the data
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            // Making sure the response is 200 OK before continuing
            
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("Error while fetching data") }
            
            // Creating a JSONDecoder instance
            let decoder = JSONDecoder()
            
            // Allows us to convert the data from the API from snake_case to cameCase
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            // Decode into the Response struct below
            let decodedData = try decoder.decode(ApiResponse.self, from: data)

            DispatchQueue.main.async {
                // Assigning the sections we fetched from the API
                let comment = self.commentSections.filter{$0.videoId == videoId}.last
                if  comment == nil{
                    if decodedData.comments != nil{
                        let comments = CommentRenderer(videoId: videoId, comments: decodedData.comments, nextContinuation: decodedData.nextContinuation)
                        self.commentSections.append(comments)
                    }

                }else{
                    var comments = comment?.comments ?? []
                    if decodedData.comments != nil{
                        comments.append(contentsOf: decodedData.comments!)
                        self.commentSections.removeAll{$0.videoId == videoId}
                        let commentSection = CommentRenderer(videoId: videoId, comments: comments, nextContinuation: decodedData.nextContinuation)
                        self.commentSections.append(commentSection)
                    }
                }
                
            }

        } catch {
            // If we run into an error, print the error in the console
            print("Error fetching data from Pexels: \(error)")
        }
    }
    // Fetching the context asynchronously
    func fetchLinksData(videoId: String, shorts: Bool = false) async {
        do{
            let hlsManifestUrl = try await YourTube(videoID: videoId).livestreams
                .filter { $0.streamType == .hls }
                .first
            guard let urlStream = hlsManifestUrl?.url.absoluteString else{return}
            DispatchQueue.main.async {
                let linkSection = LinkRenderer(videoId: videoId, hlsManifestUrl: urlStream, links:nil)
                self.linkSections.append(linkSection)
            }
            if !shorts{
                // Get recs videos
                Task.init {
                    await fetchRecsData(videoId: videoId)
                }
            }
        }catch{
            print(error.localizedDescription)
        }
    }
    
    // Fetching the newjeans data asynchronously
    func fetchNewJeansData() async {
        do {
        // Make sure we have a URL before continuing
            guard let url = URL(string: "\(host)") else { fatalError("Missing URL") }
            var localeCountryCode =  (Locale.current as NSLocale).object(forKey: .countryCode) as? String ?? "US"
            let localeLanguageCode = (Locale.current as NSLocale).object(forKey: .languageCode) as? String ?? "en"
            if localeCountryCode.uppercased() == "CN"{
                localeCountryCode = "HK"
            }
//            if localeCountryCode.uppercased() == "US"{
//                localeCountryCode = "US"
//                localeLanguageCode = "vi"
//            }
            let body = String(format: #"{"action":"newJeans", "gl":"%@", "hl":"%@"}"#, localeCountryCode.uppercased(), localeLanguageCode.lowercased())
        // Create a URLRequest
        var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = body.data(using: .utf8)
        
            // Fetching the data
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            // Making sure the response is 200 OK before continuing
            
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("Error while fetching data") }
            
            // Creating a JSONDecoder instance
            let decoder = JSONDecoder()
            
            // Allows us to convert the data from the API from snake_case to cameCase
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            // Decode into the Response struct below
            let decodedData = try decoder.decode(ApiResponse.self, from: data)

            DispatchQueue.main.async {
                // Assigning the sections we fetched from the API
                guard let datas = decodedData.reels else{return}
                let newJean = NewJeans(header: decodedData.header, reels: datas)
                self.newJeans = newJean
            }

        } catch {
            // If we run into an error, print the error in the console
            print("Error fetching data from Pexels: \(error)")
        }
    }
    
    // Fetching the newjeans data asynchronously
    func fetchMusicChannelsData() async {

        do {
        // Make sure we have a URL before continuing
            guard let url = URL(string: "\(host)") else { fatalError("Missing URL") }
            var localeCountryCode =  (Locale.current as NSLocale).object(forKey: .countryCode) as? String ?? "US"
            let localeLanguageCode = (Locale.current as NSLocale).object(forKey: .languageCode) as? String ?? "en"
            if localeCountryCode.uppercased() == "CN"{
                localeCountryCode = "HK"
            }
//            if localeCountryCode.uppercased() == "US"{
//                localeCountryCode = "US"
//                localeLanguageCode = "vi"
//            }
            let body = String(format: #"{"action":"channel", "gl":"%@", "hl":"%@"}"#, localeCountryCode.uppercased(), localeLanguageCode.lowercased())
        // Create a URLRequest
        var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = body.data(using: .utf8)
        
            // Fetching the data
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            // Making sure the response is 200 OK before continuing
//            print(String(data: data, encoding: .utf8) as? String as Any)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("Error while fetching data") }
            
            // Creating a JSONDecoder instance
            let decoder = JSONDecoder()
            
            // Allows us to convert the data from the API from snake_case to cameCase
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            // Decode into the Response struct below
            let decodedData = try decoder.decode(ApiResponse.self, from: data)

            DispatchQueue.main.async {
                // Assigning the sections we fetched from the API
                
                guard let datas = decodedData.compactRenderers else{return}
                self.compactRenderers = datas
                let carouselitems = decodedData.carouselVideos?.shuffled() ?? []
                if carouselitems.count > 0{
                    self.carouselVideos = []
                }
                carouselitems.indices.forEach { index in
                    let videoData = carouselitems[index]
                    if index == 1 || index == 5 || index == 9 || index == carouselitems.count - 1 {
                        self.carouselVideos?.append(VideoData(videoId: "", title: "", timestampText: "", thumbnail: "", avatar: "", metadataDetails: ""))
                    }
                    self.carouselVideos?.append(videoData)
                }
               
                
                var tempTeaderStations:[CompactStationRenderer] = []
                var tempMenuItems:[CompactStationRenderer] = []
                for _ in 1...100 {
                    guard let item = datas.randomElement() else{continue}
                    guard let render = item.stations?.randomElement() else{continue}
                    let filters = tempTeaderStations.filter{$0.playlistId == render.playlistId}
                    if filters.count == 0, tempMenuItems.count < 16 {
                        tempTeaderStations.append(render)
                    }
                    if tempTeaderStations.count >= 16{
                        if filters.count == 0{
                            let _filters = tempMenuItems.filter{$0.playlistId == render.playlistId}
                            if _filters.count == 0, tempMenuItems.count < 3{
                                tempMenuItems.append(render)
                            }
                            if tempMenuItems.count >= 3{
                                break
                            }
                        }
                    }
                }
                self.menuStations = tempTeaderStations
                self.menuItems = tempMenuItems
            }

        } catch {
            // If we run into an error, print the error in the console
            print("Error fetching data from Pexels: \(error)")
        }
    }
    // Fetching the newjeans data asynchronously
    func fetchPlaylistData(playlistId: String) async {
     
        do {
        // Make sure we have a URL before continuing
            guard let url = URL(string: "\(host)") else { fatalError("Missing URL") }
            var localeCountryCode =  (Locale.current as NSLocale).object(forKey: .countryCode) as? String ?? "US"
            let localeLanguageCode = (Locale.current as NSLocale).object(forKey: .languageCode) as? String ?? "en"
            if localeCountryCode.uppercased() == "CN"{
                localeCountryCode = "HK"
            }
//            if localeCountryCode.uppercased() == "US"{
//                localeCountryCode = "US"
//                localeLanguageCode = "vi"
//            }
            let body = String(format: #"{"action":"playlist", "gl":"%@", "hl":"%@", "playlistId":"%@"}"#, localeCountryCode.uppercased(), localeLanguageCode.lowercased(), playlistId)
        // Create a URLRequest
        var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = body.data(using: .utf8)
        
            // Fetching the data
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            // Making sure the response is 200 OK before continuing
            
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("Error while fetching data") }
            
            // Creating a JSONDecoder instance
            let decoder = JSONDecoder()
            
            // Allows us to convert the data from the API from snake_case to cameCase
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            // Decode into the Response struct below
            let decodedData = try decoder.decode(ApiResponse.self, from: data)

            DispatchQueue.main.async {
                // Assigning the sections we fetched from the API
                let list = self.playlistVideos.filter{$0.playlistId == playlistId}
                if list.count == 0, decodedData.videos != nil{
                    let playlistItem = PlaylistVideos(playlistId: playlistId, videos: decodedData.videos)
                    self.playlistVideos.append(playlistItem)
                }
            }

        } catch {
            // If we run into an error, print the error in the console
            print("Error fetching data from Pexels: \(error)")
        }
    }
    
    // fetch music data
    // Fetching the newjeans data asynchronously
    func fetchMusicData(id: String?) async {
        do {
        // Make sure we have a URL before continuing
            guard let url = URL(string: "\(host)") else { fatalError("Missing URL") }
            var localeCountryCode =  (Locale.current as NSLocale).object(forKey: .countryCode) as? String ?? "US"
            if countries.contains(localeCountryCode.uppercased()) == false{
                localeCountryCode = "US"
            }
            if id != nil{
                localeCountryCode = id!
            }
            if localeCountryCode.uppercased() == "CN"{
                localeCountryCode = "HK"
            }
        let localeLanguageCode = (Locale.current as NSLocale).object(forKey: .languageCode) as? String ?? "en"
            let body = String(format: #"{"action":"music", "gl":"%@", "hl":"%@"}"#, localeCountryCode.uppercased(), localeLanguageCode.lowercased())
            let idx = localeCountryCode.uppercased()
            DispatchQueue.main.async {
                self.countryId = idx
            }
        // Create a URLRequest
        var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = body.data(using: .utf8)
        
            // Fetching the data
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            // Making sure the response is 200 OK before continuing
            
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("Error while fetching data") }
            
            // Creating a JSONDecoder instance
            let decoder = JSONDecoder()
            
            // Allows us to convert the data from the API from snake_case to cameCase
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            // Decode into the Response struct below
            let decodedData = try decoder.decode(ApiResponse.self, from: data)
           
            DispatchQueue.main.async {
                // Assigning the sections we fetched from the API
                
                self.commands = decodedData.commands
                self.mutations = decodedData.mutations
                let section = MusicSection(countryId: idx, ranks: decodedData.ranks)
                self.ranks.append(section)
                self.browseId = decodedData.browseId
                if decodedData.trends != nil{
                    self.trends = decodedData.trends
                }
                
//                Task.init {
//                    await self.modelRequest.fetchData(id: idx)
//                }
                
            }            

        } catch {
            // If we run into an error, print the error in the console
            print("Error fetching data from Pexels: \(error)")
        }
    }
    
    // Fetching the newjeans data asynchronously
    func fetchMusicPlaylistData(playlistId: String) async {
        do {
        // Make sure we have a URL before continuing
            guard let url = URL(string: "\(host)") else { fatalError("Missing URL") }
             var localeCountryCode = "US"
            if localeCountryCode.uppercased() == "CN"{
                localeCountryCode = "HK"
            }
         
            let localeLanguageCode = (Locale.current as NSLocale).object(forKey: .languageCode) as? String ?? "en"
//            if localeCountryCode.uppercased() == "US"{
//                localeCountryCode = "US"
//                localeLanguageCode = "vi"
//            }
            // Create a URLRequest
            let body = String(format: #"{"action":"mplaylist", "gl":"%@", "hl":"%@","playlistId":"%@"}"#, localeCountryCode.uppercased(), localeLanguageCode.lowercased(), playlistId)
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = body.data(using: .utf8)
            
            // Fetching the data
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            // Making sure the response is 200 OK before continuing
            
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("Error while fetching data") }
            
            // Creating a JSONDecoder instance
            let decoder = JSONDecoder()
            
            // Allows us to convert the data from the API from snake_case to cameCase
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            // Decode into the Response struct below
            let decodedData = try decoder.decode(ApiResponse.self, from: data)
            guard let token = decodedData.nextContinuation else{return}
            let idx = localeCountryCode.uppercased()
            Task.init {
                await self.fetchMusicPlaylistContinuationData(id: idx, token: token)
            }

        } catch {
            // If we run into an error, print the error in the console
            print("Error fetching data from Pexels: \(error)")
        }
    }
    
    // Fetching the newjeans data asynchronously
    func fetchMusicPlaylistContinuationData(id: String, token: String) async {
        do {
        // Make sure we have a URL before continuing
            guard let url = URL(string: "\(host)") else { fatalError("Missing URL") }
            var localeCountryCode =  (Locale.current as NSLocale).object(forKey: .countryCode) as? String ?? "US"
            let localeLanguageCode = (Locale.current as NSLocale).object(forKey: .languageCode) as? String ?? "en"
            if countries.contains(id.uppercased()) == false{
                localeCountryCode = "US"
            }
            if localeCountryCode.uppercased() == "CN"{
                localeCountryCode = "HK"
            }
//            if localeCountryCode.uppercased() == "US"{
//                localeCountryCode = "US"
//                localeLanguageCode = "vi"
//            }
            let body = String(format: #"{"action":"mstream", "gl":"%@", "hl":"%@","token":"%@"}"#, localeCountryCode.uppercased(), localeLanguageCode.lowercased(), token)
        // Create a URLRequest
        var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = body.data(using: .utf8)
        
            // Fetching the data
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            // Making sure the response is 200 OK before continuing
            
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("Error while fetching data") }
            
            // Creating a JSONDecoder instance
            let decoder = JSONDecoder()
            
            // Allows us to convert the data from the API from snake_case to cameCase
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            // Decode into the Response struct below
            let decodedData = try decoder.decode(ApiResponse.self, from: data)
            guard let ranks = decodedData.ranks else{return}
            let idx = localeCountryCode.uppercased()
            DispatchQueue.main.async { [self] in
                // Assigning the sections we fetched from the API
                let sections = self.ranks.filter{$0.countryId == idx}
                if sections.isEmpty == false{
                    var _ranks = sections.first?.ranks ?? []
                    for rank in ranks {
                        let list = _ranks.filter{$0.videoId == rank.videoId}
                        if list.count == 0{
                            _ranks.append(rank)
                        }
                    }
                    self.ranks.removeAll{$0.countryId == idx}
                    let section = MusicSection(countryId: idx, ranks: _ranks)
                    self.ranks.append(section)
                }
            }


        } catch {
            // If we run into an error, print the error in the console
            print("Error fetching data from Pexels: \(error)")
        }
    }
    
    // Fetching the context asynchronously
    func SearchData(query: String, token:String?, params: String?) async {
        do {
            guard let url = URL(string: "\(host)") else { fatalError("Missing URL") }
            let localeLanguageCode = (Locale.current as NSLocale).object(forKey: .languageCode) as? String ?? "en"
            var localeCountryCode =  (Locale.current as NSLocale).object(forKey: .countryCode) as? String ?? "US"
            if localeCountryCode.uppercased() == "CN"{
                localeCountryCode = "HK"
            }
//            if localeCountryCode.uppercased() == "US"{
//                localeCountryCode = "US"
//                localeLanguageCode = "vi"
//            }
            var body = ""
            if token != nil, params != nil{
                body = String(format: #"{"action":"search", "gl":"%@", "hl":"%@", "token":"%@", "params":"%@","query":"%@"}"#, localeCountryCode.uppercased(), localeLanguageCode.lowercased(), token!, params!, query)

            }else if token != nil{
                body = String(format: #"{"action":"search", "gl":"%@", "hl":"%@", "token":"%@","query":"%@"}"#, localeCountryCode.uppercased(), localeLanguageCode.lowercased(), token!, query)
            }else if params != nil{
                body = String(format: #"{"action":"search", "gl":"%@", "hl":"%@", "params":"%@","query":"%@"}"#, localeCountryCode.uppercased(), localeLanguageCode.lowercased(), params!, query)

            }else{
                body = String(format: #"{"action":"search", "gl":"%@", "hl":"%@","query":"%@"}"#, localeCountryCode.uppercased(), localeLanguageCode.lowercased(), query)

            }
            
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = body.data(using: .utf8)
            
            // Fetching the data
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("Error while fetching data") }
//            print(String(data: data, encoding: .utf8) as Any)
            // Creating a JSONDecoder instance
            let decoder = JSONDecoder()
            
            // Allows us to convert the data from the API from snake_case to cameCase
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            // Decode into the Response struct below
            let decodedData = try decoder.decode(ApiResponse.self, from: data)
            DispatchQueue.main.async {
                if self.search != nil{
                    var videos = self.search?.videos ?? []
                    videos.append(contentsOf: decodedData.videos ?? [])
                    self.search?.videos = videos
                    self.search?.filters = decodedData.filters
                    self.search?.nextContinuation = decodedData.nextContinuation
                }else{
                    let searchs = SearchRenderer(filters: decodedData.filters, nextContinuation: decodedData.nextContinuation, videos: decodedData.videos, reels: decodedData.reels)
                    self.search = searchs
                }
            }
            
        } catch {
            // If we run into an error, print the error in the console
            print("Error fetching data from Pexels: \(error)")
        }
    }
    // Fetching the context asynchronously

}

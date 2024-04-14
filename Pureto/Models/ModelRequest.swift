//
//  SwiftUIView2.swift
//  Pureto
//
//  Created by Pureto on 3/8/23.
//

import SwiftUI
import SwiftyJSON
import UIKit

let musicKey = "AIzaSyC9XL3ZjWddXya6X74dJoCTL-WEYFDNX30"
class ModelRequest: ObservableObject{
    @Published var releases: [NewVideo]?
    @Published var topReleases: [NewVideo]?
    @Published var suggestions:[String] = []
    static var shared = ModelRequest()
    // On initialize of the class, fetch the context
    private init() {}
    private let baseURL = "https://music"+".you"+"tube.com/"+"yout"+"ubei/v1/browse?key=\(musicKey)&prettyPrint=false"
    
    // fetch new realease music videos
    func fetchData(id: String?) async{
        if id != nil, id == "ZZ"{
            return
        }

        guard let url = URL(string: "\(baseURL)") else { fatalError("Missing URL") }
        let localeLanguageCode = (Locale.current as NSLocale).object(forKey: .languageCode) as? String ?? "en"
        var localeCountryCode =  (Locale.current as NSLocale).object(forKey: .countryCode) as? String ?? "US"
        // Make sure we have a URL before continuing
        if id != nil{
            localeCountryCode = id!
        }
        let body = String(format: #"{"context":{"client":{"clientName":"IOS_MUSIC","clientVersion":"6.13.2","deviceModel":"iPhone14,3","gl":"%@",hl:"%@"}},"browseId":"FEmusic_new_releases_videos"}"#, localeCountryCode.uppercased(),localeLanguageCode.lowercased())
            
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("com.goo"+"gle.ios.you"+"tubemusic/", forHTTPHeaderField: "User-Agent")
        urlRequest.httpBody = body.data(using: .utf8)
        // Fetching the data
        do{
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            // Making sure the response is 200 OK before continuing
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("Error while fetching data") }
            guard let json = try? JSON(data: data) else{return}
            guard let videos = parseContents(json: json) else{return}
            let shuffleVideos = videos.shuffled()
            let first8Elements : [NewVideo] // An Array of up to the first 3 elements.
            if shuffleVideos.count >= 8 {
                first8Elements = Array(shuffleVideos[0 ..< 8])
            } else {
                first8Elements = shuffleVideos
            }
            DispatchQueue.main.async {
                self.topReleases = first8Elements
                self.releases = videos
            }
            
        }catch{
            
        }
    }
    
    private func parseContents(json: JSON) -> [NewVideo]?{
        guard let tabs = parseTabs(json: json) else{return nil}
        var videos: [NewVideo] = []
        for tab in tabs {
            guard let sectionListRenderer = parseSectionListRenderer(json: tab) else{continue}
            guard let contents = sectionListRenderer.dictionaryValue["contents"]?.arrayValue else{continue}
            for content in contents {
                guard let gridRenderer = content.dictionaryValue["gridRenderer"] else{continue}
                guard let items = gridRenderer.dictionaryValue["items"]?.arrayValue else{continue}
                for item in items {
                    guard let video = parseMusicVideo(json: item) else{continue}
                    videos.append(video)
                }
            }
        }
        if videos.count > 0{
            return videos
        }
        return nil
    }
    
    // Fetching the context asynchronously
    func fetchSuggestData(query: String) async {
        if query.count == 0{
            return
        }
        do {
            let queryStr = query.replacingOccurrences(of: " ", with: "+")
//            let localeLanguageCode = (Locale.current as NSLocale).object(forKey: .languageCode) as? String
            let domain = "you"+"tube"
            let subDomain = "goo" + "gle"
            let urlStr = "https://suggestqueries.\(subDomain).com/complete/search?ds=yt&client=\(domain)&client=android&q=\(queryStr)"
            guard let urlString = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else{return}
            print(urlString as Any)
            guard let url = URL(string: "\(urlString)") else { fatalError("Missing URL") }
      
        // Create a URLRequest
            var urlRequest = URLRequest(url: url)
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
            // Fetching the data
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            // Making sure the response is 200 OK before continuing
//            print(String(data: data, encoding: .utf8) as Any)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("Error while fetching data") }
            

            guard let dataString = String(data: data, encoding: .utf8) else{return}
            DispatchQueue.main.async {
                // Reset the videos (for when we're calling the API again)
                let jsons =  JSON(parseJSON: dataString).arrayValue
                var suggests:[String] = []
                for json in jsons{
                    if json.arrayValue.count > 0{
                        for subJson in json.arrayValue{
                            if subJson.stringValue.count > 0{
                                suggests.append(subJson.stringValue)
                            }
                        }
                    }
                }
                self.suggestions = suggests
                // Assigning the videos we fetched from the API
            }

        } catch {
            // If we run into an error, print the error in the console
            print("Error fetching data from Pexels: \(error)")
        }
    }
}

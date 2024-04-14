//
//  NewRealeaseView.swift
//  Pureto
//
//  Created by Pureto on 9/8/23.
//

import SwiftUI

public class InnerYourTube{
    
    enum ClientType {
        case ios,tvEmbed
    }
    private let baseURL = "https://www.yout"+"ube.com/you"+"tubei/v1"
    
    private let apiKey: String
    private let context: Context
    private let headers: [String: String]
    
    private struct PlayerRequest: Encodable {
        let context: Context
        let videoId: String
        let params: String = "8AEB"
        //let paybackContext
        let contentCheckOk: Bool = true
        let racyCheckOk: Bool = true
    }
    
    private struct Context: Encodable {
        let client: ContextClient
        
        struct ContextClient: Encodable {
            let clientName: String
            let clientVersion: String
            let clientScreen: String?
            let androidSdkVersion: Int?
        }
    }
    private struct Client {
        let name: String
        let version: String
        let screen: String?
        let apiKey: String
        let userAgent: String?

        var androidSdkVersion: Int? = nil
        
        var context: Context {
            return Context(client: InnerYourTube.Context.ContextClient(clientName: name, clientVersion: version, clientScreen: screen, androidSdkVersion: androidSdkVersion))
        }
        
        var headers: [String: String] {
            ["User-Agent": userAgent ?? ""].filter { !$0.value.isEmpty }
        }
    }
    private let defaultClients = [
            ClientType.ios: Client(name: "IOS", version: "17.33.2", screen: nil, apiKey: "AIzaSyB-63vPrdThhKuerbB2N_l7Kwwcxj6yUAc", userAgent: "com.goog"+"le.ios.yout"+"ube/17.33.2 (iPhone14,3; U; CPU iOS 15_6 like Mac OS X)"),
            ClientType.tvEmbed: Client(name: "TVHTML5_SIMPLY_EMBEDDED_PLAYER", version: "2.0", screen: "EMBED", apiKey: "AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8", userAgent: "Mozilla/5.0")
        ]

    init(client: ClientType = .ios) {
        self.context = defaultClients[client]!.context
        self.apiKey = defaultClients[client]!.apiKey
        self.headers = defaultClients[client]!.headers
     
    }
    private struct BaseData: Encodable {
        let context: Context
    }
    
    private var baseData: BaseData {
        return BaseData(context: context)
    }
    
    private var baseParams: [URLQueryItem] {
        [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "contentCheckOk", value: "true"),
            URLQueryItem(name: "racyCheckOk", value: "true")
        ]
    }
    private func callAPI<D: Encodable, T: Decodable>(endpoint: String, query: [URLQueryItem], object: D) async throws -> T {
        let data = try JSONEncoder().encode(object)
        return try await callAPI(endpoint: endpoint, query: query, data: data)
    }
    
    private func callAPI<T: Decodable>(endpoint: String, query: [URLQueryItem], data: Data) async throws -> T {
        
        // TODO: handle oauth case
        
        var urlComponents = URLComponents(string: endpoint)!
        urlComponents.queryItems = query
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "post"
        request.httpBody = data
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
        request.addValue("en-US,en", forHTTPHeaderField: "accept-language")
        
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // TODO: handle oauth auth case again
        
        let (responseData, _) = try await URLSession.shared.data(for: request)
//        print(String(data: responseData, encoding: .utf8) as Any)
        return try JSONDecoder().decode(T.self, from: responseData)
    }
    func player(videoID: String) async throws -> VideoInfo {
        let endpoint = baseURL + "/player"
        let query = [
            URLQueryItem(name: "key", value: apiKey)
        ]
        let request = playerRequest(forVideoID: videoID)
        return try await callAPI(endpoint: endpoint, query: query, object: request)
    }
    private func playerRequest(forVideoID videoID: String) -> PlayerRequest {
        PlayerRequest(context: context, videoId: videoID)
    }

}

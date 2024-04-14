//
//  PlaylistsItem.swift
//  Pureto
//
//  Created by Pureto on 9/8/23.
//

import SwiftUI
import AppLovinSDK

struct Trending: View {
    @StateObject var request = DataRequest.shared
    @StateObject var nativeAd = MANativeAdLoaderModel.shared
    private let params = "6gQJRkVleHBsb3Jl"

    var body: some View {
        GeometryReader { geometry in
//            let isIphone = UIDevice.current.userInterfaceIdiom == .phone
//            let width = isIphone ? (geometry.size.width - 80)/2 : 200
//            let height = width * 3 / 2
            List {
                let results = request.sections.filter{$0.params == params}
                let videos = results.first?.videos ?? []
                if videos.count > 0{
                    ForEach(videos.indices, id: \.self) { index in
                        let canShowAd = index % 5 == 0
                        let idx = index / 5
                            if canShowAd, nativeAd.trendingNaviteAdViews.count >= idx, idx >= 1{
                                VStack(spacing: 10){
                                    let adView = nativeAd.trendingNaviteAdViews[idx - 1]
                                    MANativeAdViewSwiftUIWrapper(adView: adView)
                                        .frame(height: 260)
                                    let videoData = videos[index]
                                    VideoItem(videoData: videoData)
                                        .onAppear(){
                                            checkForMore(videoData)
                                        }
                                        .onTapGesture {
                                            request.selectedItem = videoData
                                        }
                                }
                                
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(.init(top: 0, leading: 10, bottom: 10, trailing: 10)))
                    
                            }else{
                                let videoData = videos[index]
                                VideoItem(videoData: videoData)
                                    .listRowInsets(EdgeInsets(.init(top: 0, leading: 10, bottom: 10, trailing: 0)))
                                    .listRowSeparator(.hidden)
                                    .onAppear(){
                                        checkForMore(videoData)
                                        let canRequest = index % 5 == 0
                                        if canRequest {
                                            nativeAd.showAd()
                                        }
                                        
                                    }
                                    .onTapGesture {
                                        request.selectedItem = videoData
                                    }
                                
                            }
                        }
                }else{
                    ProgressView()
                        .listRowSeparator(.hidden)
                        .foregroundColor(.primary)
                        .task {
                            let results = request.sections.filter{$0.params == params}
                            if results.count == 0{
                                await request.fetchData(params: params)
                            }
//                            if request.newJeans == nil{
//                                await request.fetchNewJeansData()
//                            }
                        }
                }
            }
            .listStyle(.plain)
            .scrollIndicators(.hidden)
        }
    }
    func checkForMore(_ item: VideoData) {
        let results = request.sections.filter{$0.params == params}
        if results.count > 0{
            let videos = results.first?.videos ?? []
            let thresholdIndex = videos.index(videos.endIndex, offsetBy: -3)
            if videos.firstIndex(where: { $0.videoId == item.videoId }) == thresholdIndex {
                // function to request more data
                loadMore()
            }
        }
    }
    func loadMore() {
        print("Load more...")
        let results = request.sections.filter{$0.params == params}
        if results.count > 0{
            guard let token = results.first?.nextContinuation ?? results.first?.reloadContinuation else{return}
            Task.init {
                await request.fetchStreamData(params: params, token: token)
            }
            
        }
        
    }
}


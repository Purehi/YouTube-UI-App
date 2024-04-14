//
//  SwiftUIView1.swift
//  Pureto
//
//  Created by Pureto on 27/7/23.
//

import SwiftUI

struct PlaylistView: View {
    var playlistItem: CompactStationRenderer
    @Environment(\.requestReview) var requestReview
    @StateObject var request = DataRequest.shared
    @StateObject var nativeAd = MANativeAdLoaderModel.shared
    var body: some View {
        List {
            let list = request.playlistVideos.filter{$0.playlistId == playlistItem.playlistId}
            let videos = list.first?.videos ?? []
            if videos.count > 0{
                ForEach(videos.indices, id: \.self) { index in
                    let canShowAd = index % 5 == 0
                    let idx = index / 5
                     if canShowAd, nativeAd.playlistNaviteAdViews.count >= idx, idx>=1{
        
                             VStack(spacing: 10){
                                 let adView = nativeAd.playlistNaviteAdViews[idx - 1]
                                 MANativeAdViewSwiftUIWrapper(adView: adView)
                                     .frame(height: 260)

                                 let videoData = videos[index]
                                 VideoItem(videoData: videoData)
                                     .onTapGesture {
                                         request.selectedItem = videoData
                                     }
                             }
                             .listRowInsets(EdgeInsets(.init(top: 0, leading: 10, bottom: 10, trailing: 10)))
                             .listRowSeparator(.hidden)
                 
                     }else{
                         let videoData = videos[index]
                         VideoItem(videoData: videoData)
                             .listRowInsets(EdgeInsets(.init(top: 0, leading: 10, bottom: 10, trailing: 0)))
                             .listRowSeparator(.hidden)
                             .onAppear(){
                                 let canRequest = index % 5 == 0
                                 if canRequest {
                                     nativeAd.showAd(tabIndex: 3)
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
            }
        }
        .listStyle(.plain)
        .navigationTitle(playlistItem.title)
        .onDisappear(){
            nativeAd.playlistNaviteAdViews = []
        }
        .task {
            let list = request.playlistVideos.filter{$0.playlistId == playlistItem.playlistId}
            if list.count == 0 || list.first?.videos == nil{
                await request.fetchPlaylistData(playlistId: playlistItem.playlistId)
            }
        }
        .toolbar{
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Image(systemName: "star.circle.fill")
                    .font(.headline.bold())
                    .onTapGesture {
                        DispatchQueue.main.async {
                            requestReview()
                        }
                    }
                NavigationLink{
                    Me()
                }label: {
                    Image(systemName: "person.circle.fill")
                        .font(.headline.bold())
                        .foregroundColor(.primary)
                    
                }
            }
        }
    }
}

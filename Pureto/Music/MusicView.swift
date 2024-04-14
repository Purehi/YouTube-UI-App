//
//  SwiftUIView1.swift
//  Pureto
//
//  Created by Pureto on 3/8/23.
//

import SwiftUI

struct MusicView: View {
    @Environment(\.requestReview) var requestReview
    @StateObject var request = DataRequest.shared
    private let params = "4gINGgt5dG1hX2NoYXJ0cw%3D%3D"
    @StateObject var nativeAd = MANativeAdLoaderModel.shared
    var body: some View {
        List {
            let results = request.sections.filter{$0.params == params}
            if results.count > 0{
                let videos = results.first?.videos ?? []
                ForEach(videos.indices, id: \.self) { index in
                    let videoData = videos[index]
                    let canShowAd = index % 5 == 0
                    let idx = index / 5
                    if canShowAd, nativeAd.musicNaviteAdViews.count >= idx, idx>=1{
                        let adView = nativeAd.musicNaviteAdViews[idx - 1]
                        VStack{
                            MANativeAdViewSwiftUIWrapper(adView: adView)
                                .frame(height: 260)
                            VideoItem(videoData: videoData)
                                .onTapGesture {
                                    request.selectedItem = videoData
                                }
                        }
                    }else{
                        VideoItem(videoData: videoData)
                            .listRowInsets(EdgeInsets(.init(top: 0, leading: 10, bottom: 10, trailing: 0)))
                            .listRowSeparator(.hidden)
                            .onAppear(){
                                let canShowAd = index % 5 == 0
                                if canShowAd
                                {
                                    nativeAd.showAd(tabIndex: 5)
                                }
                                checkForMore(videoData)
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
                        }
            }
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
//        .navigationTitle("For You")
//        .toolbar{
//            ToolbarItemGroup(placement: .navigationBarTrailing) {
//                Image(systemName: "star.circle.fill")
//                    .font(.headline.bold())
//                    .onTapGesture {
//                        DispatchQueue.main.async {
//                            requestReview()
//                        }
//                    }
//                NavigationLink{
//                    Me()
//                }label: {
//                    Image(systemName: "person.circle.fill")
//                        .font(.headline.bold())
//                        .foregroundColor(.primary)
//                    
//                }
//            }
//        }
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

struct SwiftUIMusicView_Previews: PreviewProvider {
    static var previews: some View {
        MusicView()
    }
}

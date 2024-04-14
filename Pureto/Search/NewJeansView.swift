//
//  SwiftUIView1.swift
//  Pureto
//
//  Created by Pureto on 14/8/23.
//

import SwiftUI

struct NewJeansView: View {
    var columns = [GridItem(.adaptive(minimum: 160), spacing: 10)]
    @StateObject var request = DataRequest.shared
    var body: some View {
        GeometryReader { geometry in
            let isIphone = UIDevice.current.userInterfaceIdiom == .phone
            let width = isIphone ? (geometry.size.width - 24)/2 : 200
            let height = width * 3 / 2
            ScrollView{
                if request.newJeans?.reels != nil{
                    LazyVGrid(columns: columns){
                        ForEach(request.newJeans!.reels!.indices, id: \.self) { index in
                            let reel = request.newJeans!.reels![index]
                            ReelItemView(reelData: reel)
                                .padding(.trailing, 10)
                                .frame(width: width)
                                .frame(height: height + 80)
                                .onTapGesture {
                                    request.selectedItem = VideoData(videoId: reel.videoId, title: reel.videoTitle, timestampText: "", thumbnail: reel.thumbnail, avatar: "", metadataDetails: reel.bottomText)
                                }
                        }
                    }
                    .padding(.horizontal, 12)
                    
                }else{
                    ProgressView()
                }
            }
            .scrollIndicators(.hidden)
            .navigationTitle("NewJeans")
            
        }
    }
}

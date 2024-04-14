//
//  SwiftUIView3.swift
//  Pureto
//
//  Created by Pureto on 27/7/23.
//

import SwiftUI
import AppTrackingTransparency

struct HomeNewView: View {
    @StateObject var request = DataRequest.shared
    @AppStorage("first_launch") var first_launch = true
    @State var header: ReelData? = nil
    @Binding var selectedIndex: Int
    var columns = [GridItem(.adaptive(minimum: 160), spacing: 10)]
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                if request.carouselVideos != nil{
                    CarouselView(selectedIndex: $selectedIndex)
                        .frame(height: 250)
                }
                if request.carouselVideos != nil{
                    let videos = request.carouselVideos ?? []
                    let first = videos.count > 0 ? videos[selectedIndex == -1 ? 0 : selectedIndex] : nil
                    VStack(alignment:.leading){
                        Text(first?.title.fillter() ?? "")
                            .font(.headline.bold())
                            .lineLimit(2)
                        HStack{
                            if (first?.avatar.count)! > 0{
                                AsyncImage(url: URL(string: first?.metadataDetails.isFillter() ?? false ? "" : first?.avatar ?? "")) { image in
                                    image.resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 24,height: 24)
                                        .cornerRadius(20)
                                } placeholder: {
                                    Rectangle()
                                        .foregroundColor(.gray.opacity(0.3))
                                        .frame(width: 24,height: 24)
                                        .cornerRadius(20)
                                }
                            }
                            Text("\(first?.metadataDetails.removeAuthor() ?? "")")
                                .font(.caption)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 12)
                    let isIphone = UIDevice.current.userInterfaceIdiom == .phone
                    let width = isIphone ? (geometry.size.width - 80)/2 : 250
                    let height = width * 3 / 2
                    if request.reelVideos != nil{
                        HStack{
                            Text("Reels")
                                .font(.title2.bold())
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Spacer()
                            NavigationLink {
                                ReelsView()
                            } label: {
                                HStack{
                                    Text("see more")
                                        .foregroundColor(.blue)
                                    Image(systemName: "chevron.right")
                                        .font(.callout)
                                        .foregroundColor(.primary)
                                }
                            }
                            
                        }
                        ScrollView(.horizontal){
                            HStack(spacing:0){
                                ForEach(request.reelVideos!.indices, id: \.self) { index in
                                    let reel = request.reelVideos![index]
                                    ShortItem(reelData: reel)
                                        .padding(.trailing, 10)
                                        .frame(width: width)
                                        .frame(height: height)
                                        .onTapGesture {
                                            request.selectedItem = VideoData(videoId: reel.videoId, title: reel.videoTitle, timestampText: "", thumbnail: reel.thumbnail, avatar: "", metadataDetails: reel.bottomText)
                                        }
                                }
                            }
                        }
                    }else{
                        HStack{
                            ProgressView()
                        }
                        .frame(width: geometry.size.width)
                    }
                    if request.hightlightVideos != nil{
                        HStack{
                            Text("Trending")
                                .font(.title2.bold())
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Spacer()
                        }
                        let hightlightVideos = request.hightlightVideos ?? []
                        VStack{
                            ForEach(hightlightVideos.indices, id: \.self) { index in
                                let videoData = hightlightVideos[index]
                                VideoItem(videoData: videoData)
                                    .onTapGesture {
                                        request.selectedItem = videoData
                                    }
                            }
                        }
                        .frame(maxHeight: .infinity)
                    }
                }
            }
            .scrollIndicators(.hidden)
            .padding(.horizontal, 12)
            .navigationTitle("Now")
            .onAppear(){
                if first_launch{
                    DispatchQueue.main.asyncAfter(deadline: .now()+5, execute: {
                        ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                            first_launch = false
                        })
                    })
                }
            }
            
        }
    }
}
                

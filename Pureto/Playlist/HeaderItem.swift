//
//  SwiftUIView01.swift
//  Pureto
//
//  Created by Pureto on 5/9/23.
//

import SwiftUI
import AVKit

struct HeaderItem: View {
    var video: VideoData
    var index: Int
    @Binding var selectedIndex: Int
    @StateObject var dataRequest = DataRequest.shared
    @State private var player:AVPlayer?
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let url = "https://i.ytimg.com/vi/\(video.videoId)/sddefault.jpg"
            let isPhone = UIDevice.current.userInterfaceIdiom == .phone
            ZStack(alignment: .center){
                if isPhone{
                    AsyncImage(url: URL(string: url)) { image in
                        image
                            .frame(width: width, height: height)
                            .contentShape(Rectangle())
                        
                    } placeholder: {
                        Rectangle()
                            .foregroundColor(.pink.opacity(0.2))
                            .frame(width: width, height: height)
                    }
                }else{
                    AsyncImage(url: URL(string: url)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: width, height: height)
                            .contentShape(Rectangle())
                        
                    } placeholder: {
                        Rectangle()
                            .foregroundColor(.pink.opacity(0.2))
                            .frame(width: width, height: height)
                    }
                }
                
                Image(systemName: "play.fill")
                .foregroundColor(.white)
                .font(.body)
                .padding(16)
                .background(.ultraThinMaterial)
                .cornerRadius(30)
                
                if player != nil {
                    MusicVideoPlayer(player: player)
                        .clipped()
                        .frame(width: width, height: height)
                        .ignoresSafeArea()
                        .onDisappear(){
                            player?.pause()
                        }
                        .onAppear(){
                            if selectedIndex == index{
                                player?.play()
                            }else{
                                player?.pause()
                            }
                        }
                }
            }
            .onChange(of: selectedIndex, perform: { newValue in
                if newValue == index{
                    player?.play()
                }else{
                    player?.pause()
                }
            })
            .onTapGesture {
                dataRequest.selectedItem = video
            }
            .task {
//                let items = dataRequest.linkSections.filter{$0.videoId == video.videoId}
//                if items.count == 0{
//                    player = nil
//                    await dataRequest.fetchLinksData(videoId: video.videoId, shorts: true)
//                    let items = dataRequest.linkSections.filter{$0.videoId == video.videoId}
//                    if items.count > 0 {
//                        let urlstring = items.last?.hlsManifestUrl ?? items.last?.links?.last?.url
//                        player = AVPlayer(url: URL(string: urlstring!)!)
//                        player?.isMuted = true
//                        if selectedIndex == index{
//                            player?.play()
//                        }
//                    }
//                }else{
//                    if player == nil{
//                        let urlstring = items.last?.hlsManifestUrl ?? items.last?.links?.last?.url
//                        player = AVPlayer(url: URL(string: urlstring!)!)
//                    }
//                }
                
            }
        }
    }
}


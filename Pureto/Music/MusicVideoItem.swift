//
//  SwiftUIView2.swift
//  Pureto
//
//  Created by Pureto on 27/7/23.
//

import SwiftUI

struct MusicVideoItem: View {
    @StateObject var request = DataRequest.shared
    var video: MusicVideo
    var body: some View {
            VStack(alignment:.leading, spacing: 12){
                ZStack{
                    let url = "https://i.ytimg.com/vi/\(video.videoId)/sddefault.jpg"
                    AsyncImage(url: URL(string: url)) { image in
                        image
                            .frame(minWidth:160)
                            .frame(height: 120)
                            .cornerRadius(10)
                            .contentShape(Rectangle())
                            
                            

                    } placeholder: {
                        Rectangle()
                            .foregroundColor(.gray.opacity(0.3))
                            .frame(minWidth:160)
                            .frame(height: 120)
                            .cornerRadius(10)
                    }
                    .onTapGesture {
                        let videoData = VideoData(videoId: video.videoId, title: video.title, timestampText: "", thumbnail: video.thumbnail, avatar: "", metadataDetails: video.subtitle)
                        request.selectedItem = videoData
                    }

                    Image(systemName: "play.fill")
                    .foregroundColor(.white)
                    .font(.body)
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .cornerRadius(30)
                }
                VStack(alignment: .leading, spacing: 0){
                    HStack(alignment: .center){
                        Text("\(video.indexColumn)")
                            .font(.headline.bold())
                        if video.iconType == "ARROW_DROP_UP"{
                            Image(systemName: "triangle.fill")
                                .font(.caption2)
                                .foregroundColor(.green)
                        }else if video.iconType == "ARROW_CHART_NEUTRAL"{
                            Image(systemName: "circle.fill")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }else if video.iconType == "ARROW_DROP_DOWN"{
                            Image(systemName: "triangle.fill")
                                .rotationEffect(.degrees(180))
                                .font(.caption2)
                                .foregroundColor(.red)
                        }
                        Text("\(video.title)")
                            .font(.headline.bold())
                            .lineLimit(1)
                    }
                    Text("\(video.subtitle.removeMusicAuthor() ?? "")")
                        .font(.callout)
                        .lineLimit(1)
                    
                }
                .padding(.bottom, 12)

            }
    }
}

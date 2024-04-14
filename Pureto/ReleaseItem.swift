//
//  SwiftUIView.swift
//  Pureto
//
//  Created by Pureto on 4/8/23.
//

import SwiftUI

struct ReleaseItem: View {
    var video: NewVideo
    var body: some View {
        VStack(alignment:.leading, spacing: 12){
            ZStack{
                AsyncImage(url: URL(string: video.thumbnail)) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 160, height: 160)
                        .cornerRadius(10)
                    
                } placeholder: {
                    Rectangle()
                        .foregroundColor(.gray.opacity(0.3))
                        .frame(width: 160, height: 160)
                        .cornerRadius(10)
                }
                Image(systemName: "play.fill")
                .foregroundColor(.white)
                .font(.body)
                .padding(8)
                .background(.ultraThinMaterial)
                .cornerRadius(30)
            }
            VStack(alignment: .leading){
                Text("\(video.title)")
                    .font(.headline.bold())
                    .lineLimit(1)
                Text("\(video.subtitle.removeMusicAuthor() ?? "")")
                    .font(.caption)
                
            }
            .frame(maxWidth: 160, alignment: .leading)
            .foregroundColor(.primary)

        }
        .padding(.trailing, 12)
    }

}

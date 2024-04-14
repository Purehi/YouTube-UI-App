//
//  SwiftUIView.swift
//  Pureto
//
//  Created by Pureto on 14/8/23.
//

import SwiftUI

struct ShortItem: View {
    @Environment(\.colorScheme) var colorScheme
    var reelData: ReelData
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            ZStack(alignment: .bottomTrailing){
                ZStack{
                    AsyncImage(url: URL(string: reelData.thumbnail)) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: width)
                            .frame(height: height)
                            .cornerRadius(10)
                        
                    } placeholder: {
                        Rectangle()
                            .foregroundColor(.gray.opacity(0.3))
                            .frame(width: width)
                            .frame(height: height)
                            .cornerRadius(10)
                    }
                    Image(systemName: "play.circle.fill")
                        .font(.title)
                        .foregroundColor(.white)
                }
                VStack(alignment: .leading){
                    Text("\(reelData.videoTitle.fillter())")
                        .font(.headline.bold())
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .foregroundColor(.white)
                    
                    Text("\(reelData.bottomText)")
                        .font(.caption)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .foregroundColor(.white)
                }
                .padding(.bottom, 10)
                
            }
            .frame(width: width)
            .frame(height: height)
        }
    }
}

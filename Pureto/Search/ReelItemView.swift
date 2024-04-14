//
//  SwiftUIView2.swift
//  Pureto
//
//  Created by Pureto on 14/8/23.
//

import SwiftUI

struct ReelItemView: View {
    @Environment(\.colorScheme) var colorScheme
    var reelData: ReelData
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = width * 3 / 2
            VStack{
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
                        .font(.caption2)
                }
                VStack(alignment: .leading){
                    Text("\(reelData.videoTitle)")
                        .font(.subheadline.bold())
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    
                    
                    Text("\(reelData.bottomText)")
                        .font(.caption2)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
                .padding(.bottom, 10)
                
            }
            
        }
        .frame(maxHeight: .infinity)
    }
}

//
//  SwiftUIView.swift
//  Pureto
//
//  Created by Pureto on 27/7/23.
//

import SwiftUI

struct PlaylistItem: View {
    var station: CompactStationRenderer
    var body: some View {
        VStack(alignment:.leading){
            ZStack(alignment: .topLeading){
                AsyncImage(url: URL(string: station.thumbnail)) { image in
                    image
                        .frame(width: 140, height: 140)
                        .cornerRadius(10)
                        .clipShape(Rectangle())
                    
                } placeholder: {
                    Rectangle()
                        .fill(
                            Color.gray
                                .opacity(0.1)
                        )
                        .frame(width: 140, height: 140)
                        .cornerRadius(10)
                    
                }
                HStack{
                    Image("app_logo")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .clipShape(.circle)
                }
                .padding(4)
                
            }
            VStack(alignment:.leading){
                Text(station.title)
                    .font(.headline)
                    .lineLimit(1)
                Text(station.videoCountText)
                    .font(.caption)
            }
            .foregroundColor(.primary)
            .frame(maxWidth: 140, alignment: .leading)
        }
        .padding(.trailing, 12)
    }
}

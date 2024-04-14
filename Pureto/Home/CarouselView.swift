//
//  SwiftUIView1.swift
//  Pureto
//
//  Created by Pureto on 1/8/23.
//

import SwiftUI

struct CarouselView: View {
    @StateObject var dataRequest = DataRequest.shared
    @Binding var selectedIndex:Int
    private let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let isPhone = UIDevice.current.userInterfaceIdiom == .phone
            if dataRequest.carouselVideos != nil{
                let videos = dataRequest.carouselVideos ?? []
                if videos.count > 0{
                    TabView(selection: $selectedIndex) {
                        ForEach(videos.indices, id: \.self) { index in
                            let video = videos[index]
                            CarouselItem(video: video, index: index, selectedIndex: $selectedIndex)
                                .cornerRadius(12)
                        }
                    }
                    .tabViewStyle(.page)
                    .frame(width: width, height: 250)
                    .onReceive(timer, perform: { _ in
                        withAnimation {
                            
                            if selectedIndex < videos.count - 1 {
                                selectedIndex += 1
                            }else{
                                selectedIndex = 0
                            }
                        }
                    })

                }
            }else{
                Rectangle()
                    .foregroundColor(.gray.opacity(0.1))
                    .frame(width: width, height: isPhone ? width : 250)
                    .cornerRadius(12)
            }
        }
   
    }
}


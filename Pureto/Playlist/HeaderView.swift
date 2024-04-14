//
//  SwiftUIView.swift
//  Pureto
//
//  Created by Pureto on 5/9/23.
//

import SwiftUI

struct HeaderView: View {
    @StateObject var dataRequest = DataRequest.shared
    @Binding var selectedIndex:Int
    private let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            if dataRequest.carouselVideos != nil{
                let videos = dataRequest.carouselVideos ?? []
                if videos.count > 0{
                    TabView(selection: $selectedIndex) {
                        ForEach(videos.indices, id: \.self) { index in
                            if index == 1 || index == videos.count - 1{
                                ALMAXSwiftUIMRecAdView()
                            }else{
                                let video = videos[index]
                                HeaderItem(video: video, index: index, selectedIndex: $selectedIndex)
                                    .cornerRadius(10)
                                
                            }
                        }
                    }
                    .tabViewStyle(.page)
                    .frame(height: height)
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
                    .foregroundColor(.pink.opacity(0.1))
                    .frame(height: height)
            }
        }
   
    }
}

struct SwiftHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView(selectedIndex: .constant(0))
    }
}

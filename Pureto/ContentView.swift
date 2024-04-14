//
//  ContentView.swift
//  Pureto
//
//  Created by Pureto on 26/6/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var dataRequest = DataRequest.shared
    @State var selectedIndex = Int.zero
    @State var innerIndex = Int.zero
    var body: some View {
        ZStack {
            TabBarView(selectedIndex: $selectedIndex)
            if dataRequest.selectedItem != nil{
                showVideoPlayView.onAppear(){
                    innerIndex = selectedIndex
                    selectedIndex = -1
                }
                .onDisappear(){
                    selectedIndex = innerIndex
                }
            }

        }
    }
    
    var showVideoPlayView: some View{
        VideoPlayerView()
            .background(Color(UIColor.systemBackground))
            .ignoresSafeArea()
            .zIndex(1)
            .transition(.asymmetric(
                insertion: .opacity.animation(.easeInOut(duration: 0.2)),
                removal:.opacity.animation(.easeInOut(duration: 0.1))))
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

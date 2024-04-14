//
//  PlaylistView.swift
//  Pureto
//
//  Created by Pureto on 9/8/23.
//

import SwiftUI

struct PlaylistsView: View {
    @StateObject var request = DataRequest.shared
    @Environment(\.requestReview) var requestReview
    @State var selectedIndex: Int = Int.zero
    var body: some View {
        let compactRenderers = request.compactRenderers ?? []
        VStack{
            List {
                Section {
                    VStack(alignment: .leading){
                        HeaderView(selectedIndex: $selectedIndex)
                            .frame(height: 250)
                        let videos = request.carouselVideos ?? []
                        let first = videos.count > 0 ? videos[selectedIndex == -1 ? 0 : selectedIndex] : nil
                        VStack(alignment:.leading){
                            Text(first?.title ?? "")
                                .font(.headline.bold())
                                .lineLimit(2)
                            Text("\(first?.metadataDetails.removeAuthor() ?? "")")
                                .font(.caption)
                        }
                        .padding(.bottom, 12)
                    }
                    .padding(.horizontal, 12)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                }
                 
                ForEach(compactRenderers.indices, id:\.self ) { index in
                    let compactRenderer = compactRenderers[index]
                    VStack{
                        HStack{
                            Text("\(compactRenderer.title)")
                                .font(.title2.bold())
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding(.horizontal, 12)

                        ScrollView(.horizontal){
                            HStack(spacing:0){
                                let stations = compactRenderer.stations ?? []
                                ForEach(stations.indices, id: \.self) { index in
                                    let station = stations[index]
                                    NavigationLink {
                                        PlaylistView(playlistItem: station)
                                    } label: {
                                        PlaylistItem(station: station)
                                            
                                    }
                                }
                            }
                            .padding(.horizontal, 12)
                        }
                        .padding(.bottom, 24)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    
                }

            }
            .listStyle(.plain)
            .scrollIndicators(.hidden)
        }
        .background(Color(uiColor: UIColor.systemBackground).ignoresSafeArea())
        .navigationTitle("All Playlists")
        .toolbar{
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Image(systemName: "star.circle.fill")
                    .font(.headline.bold())
                    .onTapGesture {
                        DispatchQueue.main.async {
                            requestReview()
                        }
                    }
                NavigationLink{
                    Me()
                }label: {
                    Image(systemName: "person.circle.fill")
                        .font(.headline.bold())
                        .foregroundColor(.primary)
                    
                }
            }
        }
            
    }
}


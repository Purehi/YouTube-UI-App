//
//  SwiftUIView4.swift
//  Pureto
//
//  Created by Pureto on 14/8/23.
//

import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @State private var canSearch = true
    @StateObject var request = DataRequest.shared
    @StateObject var modelRequest = ModelRequest.shared
    
    @State var selectedIndex = Int.zero
    
    var body: some View {
        let isIphone = (UIDevice.current.userInterfaceIdiom == .phone)
        ZStack(alignment: .top){
            List{
                SearchBar(text: $searchText, canSearch: $canSearch)
                    .listRowInsets(EdgeInsets(.init(top: 0, leading: 0, bottom: 10, trailing: 0)))
                    .listRowSeparator(.hidden)
                    .onTapGesture {
                        canSearch = true
                    }
                if request.search?.filters != nil{
                    let filters = request.search?.filters ?? []
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack{
                            ForEach(filters.indices, id: \.self) { index in
                                let filter = filters[index]
                                HStack(spacing:10){
                                    Text(filter.title)
                                        .foregroundColor(selectedIndex == index ? .pink : .primary)
                                        .font(.headline.bold())
                                }
                                .listRowSeparator(.hidden)
                                .frame(minWidth: 60)
                                .padding(.bottom, 10)
                                .onTapGesture {
                                    selectedIndex = index
                                    request.search?.videos = nil
                                    if filter.params.count > 0{
                                        Task{
                                            await request.SearchData(query: searchText, token: nil, params: filter.params)
                                        }
                                    }else{
                                        Task{
                                            request.search = nil
                                            canSearch = false
                                            await request.SearchData(query:searchText, token:nil, params:nil)
                                        }
                                    }
                                }

                               
                            }
                            .listRowSeparator(.hidden)
                        }
                        .listRowSeparator(.hidden)
                    }
                    .listRowSeparator(.hidden)
                }
                if request.search?.videos != nil{
                    let videos = request.search?.videos ?? []
                    ForEach(videos, id: \.videoId) { videoData in
                        VideoItem(videoData: videoData)
                            .listRowInsets(EdgeInsets(.init(top: 0, leading: 10, bottom: 10, trailing: 0)))
                            .listRowSeparator(.hidden)
                            .onAppear(){
                                checkForMore(videoData)
                            }
                            .onTapGesture {
                                canSearch = false
                                request.selectedItem = videoData
                            }
                    }
                }else{
                    if searchText.count > 0, request.search?.videos == nil, !canSearch{
                        ProgressView()
                            .listRowSeparator(.hidden)
                            .task {
                                await request.SearchData(query: searchText, token: nil, params: nil)
                            }
                    }else{
                        VStack(spacing:12){
                            Image(systemName: "magnifyingglass.circle.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary)
                            Text("It's time to search videos.")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 64)
                        }
                        .padding(.top, 98)
                        .listRowSeparator(.hidden)
                    }
                }
                
                if request.search == nil, canSearch == false{
                    ProgressView()
                        .foregroundColor(.primary)
                }
            }
            .onDisappear(){
                modelRequest.suggestions = []
                request.search = nil
            }
            .navigationTitle("Search")
            .listStyle(.plain)
            .simultaneousGesture(DragGesture().onChanged({ _ in
                // if keyboard is opened then hide it
                canSearch = false
            }))
            
            if modelRequest.suggestions.count > 0, canSearch{
                VStack{
                    List {
                        ForEach(modelRequest.suggestions.indices, id: \.self) { index in
                            let text = modelRequest.suggestions[index]
                            HStack{
                                Text("\(text)")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                Spacer()
                                Image(systemName: "arrow.up.forward")
                                    .font(.subheadline)
                            }
                            .contentShape(Rectangle())
                            .padding()
                            .frame(height: isIphone ? 36 : 44)
                            .onTapGesture {
                                hideKeyboard()
                                canSearch = false
                                searchText = text
                                Task{
                                    await request.SearchData(query:searchText, token:nil, params:nil)
                                }
                            }
                        }
                        
                    }
                    .listStyle(.plain)
                    .frame(height: isIphone ? 300 : 400)
                    .padding(.top, 40)
                    Spacer()
                    
                }
            }
        }
    }
        
    func checkForMore(_ item: VideoData) {
        let videos = request.search?.videos ?? []
        let thresholdIndex = videos.index(videos.endIndex, offsetBy: -3)
        if videos.firstIndex(where: { $0.videoId == item.videoId }) == thresholdIndex {
            // function to request more data
            loadMore()
        }
        
    }
    func loadMore() {
        print("Load more...")
        if request.search?.nextContinuation != nil{
            if request.search?.filters != nil{
                let filter = request.search?.filters![selectedIndex]
                if (filter?.params.count)! > 0{
                    Task{
                        await request.SearchData(query:searchText, token:request.search?.nextContinuation, params:filter?.params)
                    }
                }else{
                    Task{
                        await request.SearchData(query:searchText, token:request.search?.nextContinuation, params:nil)
                    }

                }
            }else{
                Task{
                    await request.SearchData(query:searchText, token:request.search?.nextContinuation, params:nil)
                }
            }
        }
    }

}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }}

struct SwiftUISearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}

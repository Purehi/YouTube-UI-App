//
//  SwiftUIView4.swift
//  Pureto
//
//  Created by Pureto on 12/7/23.
//

import SwiftUI

struct Musics: View {
    @StateObject var request = DataRequest.shared
    @State var formItemEntityKey = "" //2
    @State var selectedItem: MusicMenuItem? = nil //2
    @Binding var selectedIndex: Int
    var columns = [GridItem(.adaptive(minimum: 160), spacing: 10)]
    var body: some View {
        ZStack{
                ScrollView{
                    let sections = request.ranks.filter{$0.countryId == request.countryId!}
                    if sections.count > 0{
                        LazyVGrid(columns: columns){
                            let ranks = sections.first?.ranks ?? []
                            ForEach(ranks.indices, id: \.self) { index in
                                let video = ranks[index]
                                
                                MusicVideoItem(video: video)
                                    .onAppear(){
                                        checkForMore(video)
                                    }
                            }
                        }
                        .padding(.horizontal, 12)

                    }else{
                        ProgressView()
                    }
            }
            .navigationTitle("Top Charts")
            .scrollIndicators(.hidden)
            .task {
                let sections = request.ranks.filter{$0.countryId == request.countryId!}
                if sections.isEmpty == false{
                    request.ranks.removeAll{$0.countryId == request.countryId!}
                    request.ranks.append(contentsOf: sections)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    // select country which you would like to watch music videos
                    if request.commands != nil{
                        Menu {
                            Picker("Hong", selection: $formItemEntityKey) {
                                ForEach(request.commands!, id: \.formItemEntityKey) { item in // 4
                                    Text(item.title) // 5
                                }
                            }
                            .task {
                                // justiy country whenter in alivable countries
                                var localeCountryCode =  (Locale.current as NSLocale).object(forKey: .countryCode) as? String
                                if localeCountryCode != nil{
                                    if !countries.contains(localeCountryCode!.uppercased()){
                                        localeCountryCode = "US"
                                    }
                                }else{
                                    localeCountryCode = "US"
                                }
                                if request.countryId != nil{
                                    localeCountryCode = request.countryId!
                                }
                              let results = request.mutations?.filter{$0.opaqueToken == localeCountryCode!}
                                if results != nil{
                                    let id = results?.first?.id
                                    let resultss = request.commands?.filter{$0.formItemEntityKey == id}
                                    if resultss != nil{
                                        self.selectedItem = resultss?.first
//                                                self.formItemEntityKey = selectedItem?.formItemEntityKey ?? ""
                                    }
                                }
                            }
                        
                        } label: {
                            HStack{
                                if selectedItem != nil{
                                    Text(self.selectedItem!.title)
                                }else{
                                    Text("United States")
                                }
                                
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                            }
                            .font(.headline.bold())
                            .foregroundColor(.primary)
                        }
                        .onChange(of: formItemEntityKey, perform: { newValue in
                            let results = request.commands?.filter{$0.formItemEntityKey == newValue}
                            if results != nil{
                                self.selectedItem = results?.first
                                if selectedItem != nil{
                                    let resultss = request.mutations?.filter{$0.id == newValue}
                                    if resultss != nil{
                                        guard let first = resultss?.first else{return}
                                        // update data from selected country
                                        Task.init{
                                            let sections = request.ranks.filter{$0.countryId == first.opaqueToken}
                                            if sections.isEmpty {
                                                await request.fetchMusicData(id: first.opaqueToken)
                                            }else{
                                                request.countryId = first.opaqueToken
                                            }
                                            selectedIndex = 0
                                            request.sections.removeAll()
                                            
                                        }
                                    }

                                }
                            }
                        })
                     
                    }
                }
            }
        }
    }
    func checkForMore(_ item: MusicVideo) {
        let sections = request.ranks.filter{$0.countryId == request.countryId!}
        if sections.isEmpty == false{
            let videos = sections.first?.ranks ?? []
            let thresholdIndex = videos.index(videos.endIndex, offsetBy: -6)
            if videos.firstIndex(where: { $0.videoId == item.videoId }) == thresholdIndex {
                // function to request more data
                loadMore()
            }
        }
    }
    func loadMore() {
        print("Load more...")
        Task.init {
            await request.fetchMusicPlaylistData(playlistId:request.browseId ?? "")
        }
    }

}

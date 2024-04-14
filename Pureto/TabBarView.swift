//
//  SwiftUIView7.swift
//  Pureto
//
//  Created by Pureto on 12/7/23.
//

import SwiftUI
import StoreKit

struct TabBarView: View {
    @State private var title = ""
    @Environment(\.requestReview) var requestReview
    @State var formItemEntityKey = "" //2
    @State var selectedItem: MusicMenuItem? = nil //2
    @Binding var selectedIndex: Int
    @StateObject var request = DataRequest.shared

    var body: some View {
        NavigationView{
            ZStack {
                TabView {
                    HomeNewView(selectedIndex: $selectedIndex)
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("Now")
                        }
                        .onAppear(){
                            self.title = "Now"
                        }
                    MusicView()
                        .tabItem {
                            Image(systemName: "music.quarternote.3")
                            Text("Music")
                        }
                        .onAppear(){
                            self.title = "Music"
                        }
                    Trending()
                        .tabItem {
                            Image(systemName: "flame.circle.fill")
                            Text("Trending")
                        }
                        .onAppear(){
                            self.title = "Recently trending"
                        }
                    Games()
                        .tabItem {
                            Image(systemName: "gamecontroller.fill")
                            Text("Gaming")
                        }
                        .onAppear(){
                            self.title = "Gaming"
                        }

                    Movies()
                        .tabItem {
                            Image(systemName: "popcorn.circle.fill")
                            Text("Movies")
                        }
                        .onAppear(){
                            self.title = "Movies"
                        }

                }
                .frame(maxWidth:.infinity, maxHeight: .infinity)
                .tint(.red)
                .font(.headline)
                .navigationTitle(self.title)
                .toolbar{
                    /*
                    if self.title == "Top Charts"{
                        ToolbarItemGroup(placement: .navigationBarLeading) {
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
                        
                    */
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Image(systemName: "star.circle.fill")
                            .font(.headline.bold())
                            .onTapGesture {
                                DispatchQueue.main.async {
                                    requestReview()
                                }
                            }
                        NavigationLink{
                            SearchView()
                        }label: {
                            Image(systemName: "magnifyingglass.circle.fill")
                                .font(.headline.bold())
                                .foregroundColor(.primary)

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
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct SwiftUITabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView(selectedIndex: .constant(0))
    }
}

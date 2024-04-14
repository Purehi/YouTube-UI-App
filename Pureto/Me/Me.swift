//
//  SwiftUIView5.swift
//  Pureto
//
//  Created by Pureto on 12/7/23.
//

import SwiftUI
import StoreKit


struct Me: View {
    @Environment(\.requestReview) var requestReview
    var body: some View {
        VStack{
            List {
                Section {
                    rate_view
                    share_view
                }
                Section {
                    like_view
                    watch_view
                }
                Section {
                    privacy_view
                    version_view
                }
                
            }
            .listStyle(.grouped)
        }
        .navigationTitle("Me")
    }
    var version_view: some View{
        HStack{
            Label("Version", systemImage: "exclamationmark.circle.fill")
                .foregroundColor(.primary)
            let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
            Text(appVersion ?? "")
                .foregroundColor(.secondary)
        }
        .font(.callout)
        .listRowInsets(EdgeInsets())
        .listRowSeparatorTint(.primary)
        .listRowSeparator(.hidden)
        .padding()
    }
    var privacy_view: some View{
        Link(destination: URL(string: "https://sites.google.com/view/purehi")!) {
            HStack{
                Label("Privacy Policy", systemImage: "house.fill")
                    .foregroundColor(.primary)
                    
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.white)
                    .font(.callout)
            }
        }
        .font(.callout)
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        .padding()
    }

    var watch_view: some View{
        HStack{
            Label("Watch later", systemImage:"clock.arrow.circlepath")
                .foregroundColor(.primary)
            Spacer()
            Image(systemName: "chevron.right")
                
        }
        .font(.callout)
        .padding()
        .overlay {
            NavigationLink{
                WatchLaterView()
            }label: {
                EmptyView()
            }.opacity(0)
        }
        .listRowInsets(EdgeInsets())
        .listRowSeparatorTint(.primary)
        .listRowSeparator(.hidden)

    }
    var like_view: some View{
        HStack{
            Label("Likes", systemImage: "heart.circle.fill")
                .foregroundColor(.primary)
            Spacer()
            Image(systemName: "chevron.right")
                
        }
        .font(.callout)
        .padding()
        .overlay {
            NavigationLink{
                LikeView()
            }label: {
                EmptyView()
            }.opacity(0)
        }
        .listRowInsets(EdgeInsets())
        .listRowSeparatorTint(.primary)
        .listRowSeparator(.hidden)

    }
    var share_view: some View{
        VStack{
            let url = URL(string: "https://apps.apple.com/app/id6452237640")!
            ShareLink(item: url, subject:Text("Musium - HD Music Video. Global Music Video Community. Pop Music Player")) {
                HStack{
                    Label("Share app with friends", systemImage:  "arrowshape.turn.up.right.fill")
                        .foregroundColor(.primary)
                        .listRowInsets(EdgeInsets())
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            }
            .font(.callout)
            .listRowSeparatorTint(.primary)
            .listRowSeparator(.hidden)
        }
       
    }
    var rate_view: some View{
        HStack{
            Label("Rate app", systemImage: "star.circle.fill")
                .foregroundColor(.primary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.headline)
        }
        .font(.callout)
        .listRowInsets(EdgeInsets())
        .listRowSeparatorTint(.primary)
        .listRowSeparator(.hidden)
        .padding()
        .onTapGesture {
            DispatchQueue.main.async {
                requestReview()
            }
        }

    }
}

struct SwiftUIView005_Previews: PreviewProvider {
    static var previews: some View {
        Me()
    }
}

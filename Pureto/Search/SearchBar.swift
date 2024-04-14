//
//  SwiftUIView3.swift
//  Pureto
//
//  Created by Pureto on 14/8/23.
//

import SwiftUI
import Combine

struct SearchBar: View {
    @Binding var text: String
    @Binding var canSearch: Bool
    @State private var innertext = ""
    @StateObject var dataRequest = DataRequest.shared
    @StateObject var modelRequest = ModelRequest.shared
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                
                TextField("Type a keyword to search", text: $text)
                    .foregroundColor(.primary)
                    .onReceive(Just(text)) { text in
                        if innertext != text{
                            innertext = text
                            if canSearch{
                                Task{
                                    await modelRequest.fetchSuggestData(query: text)
                                }
                            }
                        }
                    }
                    .submitLabel(.search)
                    .onSubmit {
                        Task{
                            hideKeyboard()
                            dataRequest.search = nil
                            canSearch = false
                            await dataRequest.SearchData(query: innertext, token: nil, params: nil)
                        }
                    }
                
                
                if text.count > 0 {
                    Image(systemName: "xmark.circle.fill")
                        .onTapGesture {
                            self.text = ""
                            modelRequest.suggestions = []

                        }
                    
                } else {
                    EmptyView()
                }
            }
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
            .foregroundColor(.secondary)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(20)
        }
        .padding(.horizontal)
        
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

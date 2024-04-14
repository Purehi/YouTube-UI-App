//
//  SwiftUIView5.swift
//  Pureto
//
//  Created by Pureto on 21/7/23.
//

import SwiftUI

struct LikeView: View {
    var body: some View {

        VStack(spacing: 12){
            Image(systemName: "heart.circle.fill")
                .foregroundColor(.primary)
                .font(.largeTitle)
            Text("No videos yet.")
                .font(.headline)
        }
        .padding(.top, 48)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Likes")
    }
}

struct SwiftUILikeView_Previews: PreviewProvider {
    static var previews: some View {
        LikeView()
    }
}

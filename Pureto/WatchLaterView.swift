//
//  SwiftUIView6.swift
//  Pureto
//
//  Created by Pureto on 21/7/23.
//

import SwiftUI

struct WatchLaterView: View {
    var body: some View {
        VStack(spacing: 12){
            Image(systemName: "clock.arrow.circlepath")
                .foregroundColor(.primary)
                .font(.largeTitle)
            Text("No videos yet.")
                .font(.headline)
        }
        .padding(.top, 48)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Watch later")

    }
}

struct SwiftUIWatchLaterView_Previews: PreviewProvider {
    static var previews: some View {
        WatchLaterView()
    }
}

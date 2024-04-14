//
//  SwiftUIView01.swift
//  Pureto
//
//  Created by Pureto on 31/8/23.
//

import SwiftUI
import AppLovinSDK

struct MANativeAdViewSwiftUIWrapper: UIViewRepresentable {
    var adView: MANativeAdView
    func makeUIView(context: Context) -> MANativeAdView
    {
        return self.adView
    }
    
    func updateUIView(_ uiView: MANativeAdView, context: Context) {}

}


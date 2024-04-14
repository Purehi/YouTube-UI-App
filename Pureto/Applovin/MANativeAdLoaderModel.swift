//
//  SwiftUIView.swift
//  Pureto
//
//  Created by Pureto on 31/8/23.
//

import SwiftUI
import AppLovinSDK

class MANativeAdLoaderModel:NSObject ,ObservableObject {
    private let nativeAdLoader: MANativeAdLoader = MANativeAdLoader(adUnitIdentifier: "e722f6e36177a703")
    static var shared = MANativeAdLoaderModel()
    @Published fileprivate var callbacks: [CallbackTableItem] = []
    @Published var trendingNaviteAdViews: [MANativeAdView] = []
    @Published var gamingNaviteAdViews: [MANativeAdView] = []
    @Published var filmsNaviteAdViews: [MANativeAdView] = []
    @Published var playlistNaviteAdViews: [MANativeAdView] = []
    @Published var recsNaviteAdViews: [MANativeAdView] = []
    @Published var musicNaviteAdViews: [MANativeAdView] = []
    private var tabIndex:Int = Int.zero
    
    private func logCallback(functionName: String = #function)
    {
        DispatchQueue.main.async {
            withAnimation {
                self.callbacks.append(CallbackTableItem(callback: functionName))
            }
        }
    }
    // On initialize of the class, fetch the context
    private override init() {
        super.init()
        nativeAdLoader.nativeAdDelegate = self
        nativeAdLoader.revenueDelegate = self

    }
    func showAd(tabIndex: Int = Int.zero)
      {
          self.tabIndex = tabIndex
          nativeAdLoader.loadAd()
      }
}
// ---- Applovin

extension MANativeAdLoaderModel: MANativeAdDelegate, MAAdRevenueDelegate
{
    func didLoadNativeAd(_ maxNativeAdView: MANativeAdView?, for ad: MAAd)
    {
        logCallback()
                
        if let adView = maxNativeAdView
        {
            // Add ad view to view
            if self.tabIndex == 0{
                self.trendingNaviteAdViews.append(adView)
            }else if self.tabIndex == 1{
                self.gamingNaviteAdViews.append(adView)
            }else if self.tabIndex == 2{
                self.filmsNaviteAdViews.append(adView)
            }else if self.tabIndex == 3{
                self.playlistNaviteAdViews.append(adView)
            }else if self.tabIndex == 4 {
                self.recsNaviteAdViews.append(adView)
            }else if self.tabIndex == 5{
                self.musicNaviteAdViews.append(adView)
            }
        }
    }
    
    func didFailToLoadNativeAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError)
    {
        logCallback()
    }
    
    func didClickNativeAd(_ ad: MAAd)
    {
        logCallback()
    
    }
    
    func didExpireNativeAd(_ ad: MAAd)
    {
        logCallback()
    }
    func didPayRevenue(for ad: MAAd)
    {
        logCallback()
    }
}

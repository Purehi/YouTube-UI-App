//
//  SwiftUIView13.swift
//  WeTube
//
//  Created by WeTube on 10/3/23.
//

import SwiftUI
import AppLovinSDK

@available(iOS 13.0, *)
struct MAAdViewSwiftUIWrapper: UIViewRepresentable
{
    let adUnitIdentifier: String
    let adFormat: MAAdFormat
    let sdk: ALSdk
    
    @Binding var isShowAd: Bool
    
    // MAAdViewAdDelegate methods
    var didLoad: ((MAAd) -> Void)? = nil
    var didFailToLoadAd: ((String, MAError) -> Void)? = nil
    var didDisplay: ((MAAd) -> Void)? = nil
    var didFailToDisplayAd: ((MAAd, MAError) -> Void)? = nil
    var didClick: ((MAAd) -> Void)? = nil
    var didExpand: ((MAAd) -> Void)? = nil
    var didCollapse: ((MAAd) -> Void)? = nil
    var didHide: ((MAAd) -> Void)? = nil
    
    // MAAdRequestDelegate method
    var didStartAdRequest: ((String) -> Void)? = nil
    
    // MAAdRevenueDelegate method
    var didPayRevenue: ((MAAd) -> Void)? = nil
    
    func makeUIView(context: Context) -> MAAdView
    {
        let adView = MAAdView(adUnitIdentifier: adUnitIdentifier, adFormat: adFormat, sdk: sdk)
        
        adView.delegate = context.coordinator
        adView.requestDelegate = context.coordinator
        adView.revenueDelegate = context.coordinator
        
        // Set background or background color for AdViews to be fully functional
        adView.backgroundColor = .systemBackground
        
        // Load the first ad
        adView.loadAd()
        
        return adView
    }
    
    func updateUIView(_ uiView: MAAdView, context: Context) {}
    
    func makeCoordinator() -> Coordinator
    {
        Coordinator(parent: self)
    }
}

@available(iOS 13.0, *)
extension MAAdViewSwiftUIWrapper
{
    class Coordinator: NSObject, MAAdViewAdDelegate, MAAdRequestDelegate, MAAdRevenueDelegate
    {
        private var parent: MAAdViewSwiftUIWrapper
        
        init(parent: MAAdViewSwiftUIWrapper)
        {
            self.parent = parent
        }
        
        func didStartAdRequest(forAdUnitIdentifier adUnitIdentifier: String)
        {
            parent.didStartAdRequest?(adUnitIdentifier)
        }
        
        func didLoad(_ ad: MAAd)
        {
            parent.isShowAd = true
            parent.didLoad?(ad)
        }
        
        func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError)
        {
            parent.isShowAd = true
            parent.didFailToLoadAd?(adUnitIdentifier, error)
        }
        
        func didDisplay(_ ad: MAAd)
        {
            parent.didDisplay?(ad)
        }
        
        func didFail(toDisplay ad: MAAd, withError error: MAError)
        {
            parent.didFailToDisplayAd?(ad, error)
        }
        
        func didClick(_ ad: MAAd)
        {
            parent.didClick?(ad)
        }
        
        func didExpand(_ ad: MAAd)
        {
            parent.didExpand?(ad)
        }
        
        func didCollapse(_ ad: MAAd)
        {
            parent.didCollapse?(ad)
        }
        
        func didHide(_ ad: MAAd)
        {
            parent.didHide?(ad)
        }
        
        func didPayRevenue(for ad: MAAd)
        {
            parent.didPayRevenue?(ad)
        }
    }
}

@available(iOS 13.0, *)
extension MAAdViewSwiftUIWrapper
{
    @ViewBuilder
    func deviceSpecificFrame(height: CGFloat) -> some View
    {
//        let ismrec = adFormat == .mrec
//        let isPhone = (UIDevice.current.userInterfaceIdiom == .phone)
//        let height = ismrec ? (isShowAd ? 0.0 : 250.0) : (isPhone ? (isShowAd ? 0.0 : 50.0) : (isShowAd ? 0.0 : 90.0))
        modifier(MAAdViewFrame(adFormat: adFormat, adHeight: height))
    }
}

@available(iOS 13.0.0, *)
struct MAAdViewFrame: ViewModifier
{
    let adFormat: MAAdFormat
    let adHeight: CGFloat
    
    func body(content: Content) -> some View
    {
        
        if ( adFormat == .banner || adFormat == .leader )
        {
            // Stretch to the width of the screen for banners to be fully functional
            // Banner height on iPhone and iPad is 50 and 90, respectively
            content
                .frame(height: adHeight)
        }
        else // adFormat == .mrec
        {
            // MREC width and height are 300 and 250 respectively, on iPhone and iPad
            content
                .frame(height: adHeight)
        }
    }
}

struct CallbackTableItem: Identifiable
{
    let id = UUID()
    let callback: String
}

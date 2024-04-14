//
//  SwiftUIView02.swift
//  Pureto
//
//  Created by Pureto on 31/8/23.
//

import SwiftUI
import AppLovinSDK

struct ALMAXSwiftUIMRecAdView: View {
    @ObservedObject private var viewModel = ALMAXSwiftUIMRecAdViewModel()
    @State var isShowAd: Bool = false
    var body: some View {
          VStack {
              MAAdViewSwiftUIWrapper(adUnitIdentifier: "7a1e41105a9c3350",
                                     adFormat: .mrec,
                                     sdk: ALSdk.shared()!,
                                     isShowAd: $isShowAd,
                                     didLoad: viewModel.didLoad,
                                     didFailToLoadAd: viewModel.didFailToLoadAd,
                                     didDisplay: viewModel.didDisplay,
                                     didFailToDisplayAd: viewModel.didFail,
                                     didClick: viewModel.didClick,
                                     didExpand: viewModel.didExpand,
                                     didCollapse: viewModel.didCollapse,
                                     didHide: viewModel.didHide,
                                     didPayRevenue: viewModel.didPayRevenue)
//              .deviceSpecificFrame()
          }
      }
}

@available(iOS 13.0, *)
class ALMAXSwiftUIMRecAdViewModel: NSObject, ObservableObject
{
    @Published fileprivate var callbacks: [CallbackTableItem] = []
    
    private func logCallback(functionName: String = #function)
    {
        DispatchQueue.main.async {
            withAnimation {
                self.callbacks.append(CallbackTableItem(callback: functionName))
            }
        }
    }
}

@available(iOS 13.0, *)
extension ALMAXSwiftUIMRecAdViewModel: MAAdViewAdDelegate, MAAdRevenueDelegate
{
    // MARK: MAAdDelegate Protocol
    func didLoad(_ ad: MAAd) { logCallback() }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) { logCallback() }
    
    func didDisplay(_ ad: MAAd) { logCallback() }
    
    func didHide(_ ad: MAAd) { logCallback() }
    
    func didClick(_ ad: MAAd) { logCallback() }
    
    func didFail(toDisplay ad: MAAd, withError error: MAError) { logCallback() }
    
    // MARK: MAAdViewAdDelegate Protocol
    func didExpand(_ ad: MAAd) { logCallback() }
    
    func didCollapse(_ ad: MAAd) { logCallback() }
    
    // MARK: MAAdRevenueDelegate Protocol
    func didPayRevenue(for ad: MAAd)
    {
        logCallback()
    }
}

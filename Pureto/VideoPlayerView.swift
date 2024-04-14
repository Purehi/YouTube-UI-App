//
//  SwiftUIView9.swift
//  Pureto
//
//  Created by Pureto on 12/7/23.
//

import SwiftUI
import AVKit
import Combine
import AppLovinSDK
import StoreKit

struct VideoPlayerView: View {
    @StateObject var dataRequest = DataRequest.shared
    @State var isLike = false
    @State var isSave = false
    @State var isBlock = false
    @State var isExpand = false
    @State var isShow = false
    @State var adHeight: CGFloat = 0
    @State private var player:AVPlayer?
    @State var innerRichItem:VideoData?
    @StateObject var nativeAd = MANativeAdLoaderModel.shared
    @Environment(\.requestReview) var requestReview
    @State var isShowAd: Bool = false
    
    @ObservedObject private var viewModel = ALMAXSwiftUIBannerAdViewModel()
    
    var body: some View {
       
        GeometryReader { geometry in
            let bounds = geometry.size
            if dataRequest.selectedItem != nil{
                let richItem = dataRequest.selectedItem!
                let iPhone = (UIDevice.current.userInterfaceIdiom == .phone)
                let url = "https://i.ytimg.com/vi/\(richItem.videoId)/sddefault.jpg"
                VStack(alignment: .leading){
                    //placement
                    ZStack(alignment: .topTrailing){
                        if richItem.metadataDetails.isFillter() {
                            ZStack{
                                AsyncImage(url: URL(string: url)) { image in
                                    image
                                        .frame(width: bounds.width,height: iPhone ? (bounds.width * 0.8) : (bounds.width * 0.5))
                                        .cornerRadius(0)
                                        .contentShape(Rectangle())
                                } placeholder: {
                                    Rectangle()
                                        .foregroundColor(.gray.opacity(0.3))
                                        .frame(width: bounds.width,height: iPhone ? (bounds.width * 0.8) : (bounds.width * 0.5))
                                        .cornerRadius(0)
                                }
                                VisualEffectView(effect: UIBlurEffect(style: .dark))
                                    .frame(width: bounds.width, height: iPhone ? (bounds.width * 0.8) : (bounds.width * 0.5))
                                
//                                AsyncImage(url: URL(string: url)) { image in
//                                    image
//                                        .frame(width: bounds.width/2.0 , height: iPhone ? (bounds.width * 0.8) : (bounds.width * 0.5))
//                                        .contentShape(Rectangle())
//
//                                } placeholder: {
//                                    Rectangle()
//                                        .frame(width: bounds.width/2.0, height: iPhone ? (bounds.width * 0.8) : (bounds.width * 0.5))
//
//                                }
                      
                            }
                        }else{
                            AsyncImage(url: URL(string: url)) { image in
                                image
                                    .frame(width: bounds.width,height: iPhone ? (bounds.width * 0.8) : (bounds.width * 0.5))
                                    .cornerRadius(0)
                                    .contentShape(Rectangle())
                                
                                
                            } placeholder: {
                                Rectangle()
                                    .foregroundColor(.gray.opacity(0.3))
                                    .frame(width: bounds.width,height: iPhone ? (bounds.width * 0.8) : (bounds.width * 0.5))
                                    .cornerRadius(0)                            }
                        }

                        if player != nil {
                            MusicVideoPlayer(player: player)
                                .clipped()
                                .frame(width: bounds.width, height: iPhone ? (bounds.width * 0.8) : (bounds.width * 0.5))
                                .onAppear(){
                                    player?.play()
                                }
                                .onDisappear(){
                                    player?.pause()
                                }
                                .ignoresSafeArea()
                            
                        }
                        closeButton
                    }
                    .ignoresSafeArea()
                    ScrollView{
                        let recss = dataRequest.recsSections.filter{$0.videoId == richItem.videoId}
                        VStack(alignment: .leading, spacing: 24){
                            //title
                            titleContent(richItem: richItem)
                                .padding(.top, 12)

                            let isPhone = (UIDevice.current.userInterfaceIdiom == .phone)
//                            let height = isPhone ? (isShowAd ? 0.0 : 50.0) : (isShowAd ? 0.0 : 90.0)
                            //banner ad
                            MAAdViewSwiftUIWrapper(adUnitIdentifier: "ca2e30b1fc97e1d6",
                                                   adFormat: .banner,
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
                            .deviceSpecificFrame(height:  isShowAd ? ( isPhone ? 50.0 : 90.0) : 0 )
                            //action
                            actionContent
                            // comment
                            if recss.count > 0, recss.last?.headerRenderer != nil{
                                HStack{
                                    commentWidget(recs: recss.last!)
                                        .background(
                                            Color.primary.cornerRadius(20)
                                        )
                                        .onTapGesture {
                                            isShow.toggle()
                                        }
                                }
                                .padding(12)
                                .sheet(isPresented: $isShow) {
                                    CommentsView(header: recss.last!.headerRenderer!, videoId: richItem.videoId)
                                        .presentationDetents([.medium])
                                }
                            }
                            //recs
                            HStack{
                                Text("May be you like")
                                    .font(.title3.bold())
                            }
                            .padding(.leading, 12)
                            if recss.last?.videos != nil{
                                let videos = recss.last?.videos ?? []
                                ForEach(videos.indices, id: \.self) { index in
                                let richItem = videos[index]
                                    let canShowAd = index % 5 == 0
                                    let idx = index / 5
                                    if canShowAd, nativeAd.recsNaviteAdViews.count > idx, nativeAd.recsNaviteAdViews.count > 0{
                                        let adView = nativeAd.recsNaviteAdViews[idx]
                                        VStack{
                                            MANativeAdViewSwiftUIWrapper(adView: adView)
                                                .frame(height: 260)
                                            VideoItem(videoData: richItem)
                                                .onTapGesture {
                                                    dataRequest.selectedItem = richItem
                                                    nativeAd.recsNaviteAdViews = []
                                                }
                                        }
                                    }else{
                                        VideoItem(videoData: richItem)
                                            .onAppear(){
                                                let canShowAd = index % 5 == 0
                                                if canShowAd{
                                                    nativeAd.showAd(tabIndex: 4)
                                                }
                                            }
                                            .onTapGesture {
                                                dataRequest.selectedItem = richItem
                                                nativeAd.recsNaviteAdViews = []
                                            }
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 12)
                            }else{
                                ProgressView()
                                    .task {
                                        if innerRichItem?.videoId != dataRequest.selectedItem?.videoId{
                                            player = nil
                                            innerRichItem = dataRequest.selectedItem
                                            await dataRequest.fetchLinksData(videoId: richItem.videoId)
                                            let items = dataRequest.linkSections.filter{$0.videoId == richItem.videoId}
                                            if items.count > 0 {
                                                let urlstring = items.first?.hlsManifestUrl ?? items.first?.links?.first?.url
                                                player = AVPlayer(url: URL(string: urlstring!)!)
                                            }
                                            
                                        }
                                    }
                            
                            }
                        }
                        
                    }
                }
                .frame(width: bounds.width, height: bounds.height)
                .statusBarHidden(true)
                .ignoresSafeArea()
                .task {
                    innerRichItem = richItem
                    let items = dataRequest.linkSections.filter{$0.videoId == richItem.videoId}
                    if items.count == 0{
                        
                        await dataRequest.fetchLinksData(videoId: richItem.videoId)
                        let items = dataRequest.linkSections.filter{$0.videoId == richItem.videoId}
                        if items.count > 0 {
                            let urlstring = items.last?.hlsManifestUrl ?? items.last?.links?.last?.url
                            player = AVPlayer(url: URL(string: "https://drive.google.com/file/d/1U6MVoUV2TSiY--ONhaw6eZgUw0CpkFHs/preview")!)
                        }
                    }else{
                        let urlstring = items.last?.hlsManifestUrl ?? items.last?.links?.last?.url
                        player = AVPlayer(url: URL(string: "https://drive.google.com/file/d/1U6MVoUV2TSiY--ONhaw6eZgUw0CpkFHs/preview")!)
                    }
                }
                
            }
        }
    }
    func commentWidget(recs: RecsRenderer) -> some View{
        return VStack(alignment: .leading){
            HStack{
                Text(recs.headerRenderer?.headerText ?? "Comments")
                    .font(.headline.bold())
                if recs.headerRenderer?.commentCount != nil, (recs.headerRenderer?.commentCount.count)! > 0{
                    Text(recs.headerRenderer!.commentCount)
                        .font(.callout)
                }
            }
            .padding(.leading, 12)
            .padding(.top, 12)
            .foregroundColor(Color(uiColor: UIColor.systemBackground))
            
            HStack(alignment: .top){
                AsyncImage(url: URL(string: recs.headerRenderer?.teasers?.last?.avatar ?? "")) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 30 ,height: 30)
                        .cornerRadius(20)
                } placeholder: {
                    Rectangle()
                        .foregroundColor(.gray.opacity(0.3))
                        .frame(width: 30 ,height: 30)
                        .cornerRadius(20)
                    
                }
                Text(recs.headerRenderer?.teasers?.last?.content ?? "")
                    .font(.callout)
                    .lineLimit(2)
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.headline)
                    .padding(.trailing)
            }
            .padding(.leading, 12)
            .padding(.bottom, 12)
            .foregroundColor(Color(uiColor: UIColor.systemBackground))
            
        
        }
    }

    func titleContent(richItem: VideoData) -> some View{
        return HStack(alignment: .top){
            VStack(alignment: .leading){
                Text("\(richItem.title.fillter())")
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                    .lineLimit(isExpand ? .none : 2)
                HStack{
                    AsyncImage(url: URL(string: richItem.metadataDetails.isFillter() ? "" : richItem.avatar)) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 24,height: 24)
                            .cornerRadius(20)
                    } placeholder: {
                        Rectangle()
                            .foregroundColor(.gray.opacity(0.3))
                            .frame(width: 24,height: 24)
                            .cornerRadius(20)
                    }
                    Text("\(richItem.metadataDetails.removeAuthor() ?? richItem.metadataDetails.removeMusicAuthor() ?? "")")
                        .font(.caption)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
            }
            .padding(.leading, 12)
            Spacer()
            Image(systemName: isExpand ? "chevron.up" : "chevron.down")
                .font(.headline)
                .padding(.trailing)
                .onTapGesture {
                    isExpand.toggle()
                }
        }
    }
    var actionContent : some View{
        HStack{
            likewidget
            Spacer()
            savewidget
            Spacer()
            sharewidget
            Spacer()
            ratewidget
            Spacer()
            blockwidget
        }
        .padding(.horizontal, 24)
    }
    var ratewidget : some View{
        VStack(spacing: 6){
            Image(systemName: "star.circle.fill")
                .foregroundColor(.primary)
                .font(.title3.bold())
                .onTapGesture {
                    requestReview()
                }
            Text("Rate")
                .font(.callout)
        }
    }
    var blockwidget : some View{
        VStack(spacing: 6){
            Image(systemName: "circle.slash.fill")
                .foregroundColor(isBlock ? .red : .primary)
                .font(.title3.bold())
                .onTapGesture {
                    isBlock.toggle()
                }
            Text("Block")
                .font(.callout)
        }
    }

    var sharewidget : some View{
        VStack(spacing: 6){
            let url = URL(string: "https://apps.apple.com/app/id6452237640")!
            ShareLink(item: url, subject: Text("Musium - HD Music Video. Global Music Video Community. Pop Music Player")){
                Image(systemName: "arrowshape.turn.up.right.fill")
                    .font(.title3.bold())
                    .foregroundColor(.primary)
            }
            Text("Share")
                .font(.callout)
        }
    }
    var savewidget : some View{
        VStack(spacing: 6){
            Image(systemName:"heart.fill")
                .foregroundColor(isSave ? .red : .primary)
                .font(.title3.bold())
                .onTapGesture {
                    isSave.toggle()
                }
            Text("Save")
                .font(.callout)
        }
    }
    var likewidget : some View{
        VStack(spacing: 6){
            Image(systemName:"hand.thumbsup.fill")
                .foregroundColor(isLike ? .red : .primary)
                .font(.title3.bold())
                .onTapGesture {
                    isLike.toggle()
                }
            Text("Like")
                .font(.callout)
        }
    }
    var closeButton : some View {
        Button{
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)){
                dataRequest.selectedItem = nil
                nativeAd.recsNaviteAdViews = []
            }
        }label: {
            Image(systemName: "xmark")
                .font(.subheadline)
                .padding(8)
                .background(Color.white, in: Circle())
        }
        .padding(.top, 24)
        .padding(.trailing, 24)
        
    }
    
}
// ---- Applovin
    @available(iOS 13.0, *)
    class ALMAXSwiftUIBannerAdViewModel: NSObject, ObservableObject
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
    extension ALMAXSwiftUIBannerAdViewModel: MAAdViewAdDelegate, MAAdRevenueDelegate
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
            
            //            let adjustAdRevenue = ADJAdRevenue(source: ADJAdRevenueSourceAppLovinMAX)!
            //            adjustAdRevenue.setRevenue(ad.revenue, currency: "USD")
            //            adjustAdRevenue.setAdRevenueNetwork(ad.networkName)
            //            adjustAdRevenue.setAdRevenueUnit(ad.adUnitIdentifier)
            //            if let placement = ad.placement
            //            {
            //                adjustAdRevenue.setAdRevenuePlacement(placement)
            //            }
            //
            //            Adjust.trackAdRevenue(adjustAdRevenue)
        }
    }
    

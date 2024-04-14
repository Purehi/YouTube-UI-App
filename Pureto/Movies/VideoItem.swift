//
//  SwiftUIView8.swift
//  Pureto
//
//  Created by Pureto on 12/7/23.
//

import SwiftUI
import AVKit

struct VideoItem: View {
    @StateObject var request = DataRequest.shared
    @Environment(\.colorScheme) var colorScheme
    @StateObject var bgRemover = BackgroundRemoval()
    @State var uiImage : UIImage? = nil
    @State var isprocess : Bool = false
    var videoData: VideoData
    var body: some View {
        HStack(alignment: .top){
            ZStack(alignment: .bottomLeading){
                ZStack(alignment: .center){
                    AsyncImage(url: URL(string: videoData.thumbnail)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                            .frame(width: 160)
                            .frame(height: 90)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                      
                        
                    } placeholder: {
                        Rectangle()
                            .foregroundColor(.gray.opacity(0.1))
                            .frame(width: 160)
                            .frame(height: 90)
                            .cornerRadius(10)
                    }
                }
                HStack{
                    HStack(spacing: 4) {
                        Image(systemName: "play.circle.fill")
                            .font(.caption2)
                        Text("\(videoData.timestampText)")
                            .font(.caption2)
                    }
                    .padding(4)
                    .foregroundColor(colorScheme == .dark ? .black:.white)
                }
                .background(.primary)
                .cornerRadius(6)
                .padding(4)
                
            }
            .onTapGesture {
                request.selectedItem = videoData
            }
            VStack(alignment: .leading){
                Text("\(videoData.title.fillter())")
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                HStack{
                    if videoData.avatar.count > 0 {
                        AsyncImage(url: URL(string: videoData.metadataDetails.isFillter() ? "" : videoData.avatar)) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 20)
                                .frame(height: 20)
                                .cornerRadius(15)
                            
                        } placeholder: {
                            Rectangle()
                                .foregroundColor(.gray.opacity(0.3))
                                .frame(width: 20)
                                .frame(height: 20)
                                .cornerRadius(15)
                        }
                    }
                    Text("\(videoData.metadataDetails.removeAuthor() ?? videoData.metadataDetails.removeMusicAuthor() ?? videoData.metadataDetails)")
                        .font(.caption)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
//                        .foregroundColor(.black)
                }
            }
            Spacer()
        }
        
    }
 
}
struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}
extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        
        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

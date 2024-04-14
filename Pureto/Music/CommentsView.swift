//
//  SwiftUIView4.swift
//  Pureto
//
//  Created by Pureto on 27/7/23.
//

import SwiftUI

struct CommentsView: View {
    var header:commentsHeaderRenderer
    var videoId: String
    @StateObject var dataRequest = DataRequest.shared
    var body: some View {
        let section = dataRequest.commentSections.filter{$0.videoId == videoId}.last
        if section?.comments != nil {
            VStack{
                Text("\(header.headerText) \(header.commentCount)")
                    .font(.headline.bold())
                    .padding(.vertical, 10)
                List{
                    ForEach(section!.comments!.indices, id: \.self) { i in
                        let comment = section!.comments![i]
                        CommentsItem(comment: comment)
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            .onAppear(){
                                checkForMore(comment)
                            }
                    }
                    
                }
                .listStyle(.plain)
            }
            .padding(.horizontal, 10)
        }else{
            ProgressView()
                .task {
                    let comment = dataRequest.commentSections.filter{$0.videoId == videoId}.last
                    if comment?.comments == nil {
                        await dataRequest.fetchCommentData(videoId: videoId, token: header.nextContinuation ?? header.reloadContinuation ?? "")
                    }
                }
        }
    }
    func checkForMore(_ item: CommentThread) {
        let comment = dataRequest.commentSections.filter{$0.videoId == videoId}.last
        if  comment?.comments != nil {
            let comments = comment?.comments ?? []
            let thresholdIndex = comments.index(comments.endIndex, offsetBy: -3)
            if comments.firstIndex(where: { $0.commentId == item.commentId }) == thresholdIndex {
                // function to request more data
                loadMore()
            }
        }
    }
    func loadMore() {
        print("Load more...")
        let comment = dataRequest.commentSections.filter{$0.videoId == videoId}.last
        if  comment?.comments != nil {
            guard let token = comment?.nextContinuation else{return}
            Task.init {
                await dataRequest.fetchCommentData(videoId:videoId, token:token)
            }
            
        }
    }
       
}

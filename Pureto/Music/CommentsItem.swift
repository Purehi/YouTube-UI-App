//
//  SwiftUIView.swift
//  Pureto
//
//  Created by Pureto on 1/8/23.
//

import SwiftUI

struct CommentsItem: View {
    var comment: CommentThread
    var body: some View {
        HStack(alignment: .top){
            AsyncImage(url: URL(string: comment.authorThumbnail)) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 32, height: 32)
                    .cornerRadius(16)
                
            } placeholder: {
                Rectangle()
                    .foregroundColor(.gray.opacity(0.2))
                    .frame(width: 32, height: 32)
                    .cornerRadius(16)
            }
            VStack(alignment: .leading, spacing: 6){
                HStack{
                    Text("\(comment.authorText)")
                        .font(.caption.bold())
                    Text("\(comment.publishedTimeText)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                
                Text(comment.contentText)
                    .lineLimit(2)
                    .font(.callout)
                Spacer()
            }

        }
    }
}

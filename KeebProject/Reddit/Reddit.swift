//
//  Reddit.swift
//  
//
//  Created by Joe on 11/6/22.
//

import Foundation
import Combine
import NaturalLanguage

struct Keywords {
    static let brands = [
        "Gateron", "Kailh", "Cherry", "Razer", "Gecko", "Boba", "Ever Glide", "EverGlide"
    ]
}

class RedditSentimentAnalyzer {
    private var cancellables: [AnyCancellable] = []
    public let commentsPublisher: PassthroughSubject<[Comment], Error> = .init()
    
    init(posts: Int) {
        PostsPublisher(count: posts).publisher.receive(on: DispatchQueue.main).sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                self.commentsPublisher.send(completion: .finished)
            case .failure(let failure):
                self.commentsPublisher.send(completion: .failure(failure))
            }
        }, receiveValue: { ids -> Void in
            for id in ids {
                Thread.sleep(forTimeInterval: 2)
                if let url = URL(string: "https://www.reddit.com/r/MechanicalKeyboards/comments/\(id).json") {
                    URLSession.shared.dataTask(with: url) { data, _, error in
                        guard data != nil else {
                            return
                        }
                        if let listings = try? JSONDecoder().decode([BaseListing<CommentResponseData>].self, from: data!) {
                            let comments = listings.first { $0.data.children.contains { $0.kind == .comment } }
                            if comments != nil {
                                let filteredComments = self.filterAnalyzeComments(comments!.data.children.map { $0.data })
                                self.commentsPublisher.send(filteredComments.filter { $0.sentimentValue != "" })
                            }
                        } else {
                            Keeb.shared.log(.error("Couldn't decode json"))
                        }
                    }.resume()
                }
            }
        }).store(in: &cancellables)
    }
    
    func filterAnalyzeComments(_ comments: [Comment]) -> [Comment] {
        var toRet: [Comment] = []
        // If a comment or its first reply mentions one or more of our keywords,
        // add it to the return value and filter its replies
        toRet = comments.compactMap { comment in
            for keyword in Keywords.brands {
                if comment.body?.lowercased().contains(keyword.lowercased()) ?? false {
                    return comment.analyze()
                }
            }
            return nil
        }
        
        return toRet
    }
    
}

extension String: Error {}

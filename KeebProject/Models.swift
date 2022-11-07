//
//  File.swift
//  
//
//  Created by Joe on 11/6/22.
//

import Foundation
import NaturalLanguage

struct ListingData: Decodable {
    var after: String?
    var children: [Article]
}

enum Kind: String, Decodable {
    case comment = "t1"
    case account = "t2"
    case link = "t3"
    case message = "t4"
    case subreddit = "t5"
    case award = "t6"
    case more = "more"
    case listing = "Listing"
}

struct CommentResponseData: Decodable {
    var after: String?
    var children: [BaseListing<Comment>]
}

struct BaseListing<T: Decodable>: Decodable {
    var kind: Kind
    var data: T
}

struct CommentRepliesParent: Decodable {
    var kind: String
    var replies: BaseListing<CommentRepliesData>
}

struct CommentRepliesData: Decodable {
    var after: String?
    var children: [BaseListing<Comment>]
}

struct CommentRepliesChildrenData: Decodable {
    var count: Int
    var id: String
    var children: [BaseListing<Comment>]
}

struct ArticleData: Decodable {
    var id: String
    var body: String?
    var ups: Int?
    var downs: Int?
    var kind: Kind?
}

struct Article: Decodable {
    var kind: Kind?
    var data: ArticleData
    var body: String?
    var ups: Int?
    var downs: Int?
}

struct Comment: Decodable {
    var body: String?
    var sentimentValue: String?
    var ups: Int?
    var replies: BaseListing<CommentRepliesData>?
    var ratedReplies: [Comment] = []
    var downs: Int?
    
    enum CodingKeys: CodingKey {
        case body, ups, downs, replies
    }
    
    init(body: String? = nil, sentimentValue: String? = nil, ups: Int, replies: BaseListing<CommentRepliesData>? = nil, ratedReplies: [Comment]? = nil, downs: Int) {
        self.body = body
        self.sentimentValue = sentimentValue
        self.ups = ups
        self.downs = downs
        self.replies = replies
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
            body = try? container.decode(String.self, forKey: .body)
            ups = try? container.decode(Int.self, forKey: .ups)
            downs = try? container.decode(Int.self, forKey: .downs)
            replies = try? container.decode(BaseListing<CommentRepliesData>.self, forKey: .replies)
    }
    /*
     Board Specs: QK65 R2 e-white chroma bt version + boba u4t lubed + staebies + pbt analog dreams clones.\n\nThis is by far my favourite board, so much that I sold all my other 65% besides 67 lite (so nice and affordable I can not sell it).\n\nBuild quality and sound are top notch. Waiting for 75,  tkl and alice layout from qwertykeys to see what they come up to. Seen qk60 and it sounds great even without any foams, so expecting to see that in future boards from them.
     */
    func analyze() -> Comment? {
        var toRet: Comment?
        let nlTagger: NLTagger = .init(tagSchemes: [.sentimentScore])
        nlTagger.string = self.body
        let (tag,_) = nlTagger.tag(at: self.body!.startIndex, unit: .paragraph, scheme: .sentimentScore)
        if let sentiment = tag?.rawValue {
            var analyzedReplies: [Comment] = self.analyzeReplies(self) ?? []
            toRet = Comment(body: self.body, sentimentValue: sentiment, ups: self.ups ?? 0, ratedReplies: analyzedReplies, downs: self.downs ?? 0)
        }
        return toRet
    }
    
    func analyzeReplies(_ comment: Comment, holder: [Comment] = []) -> [Comment]? {
        // For each reply, if the reply has replies, recurse until end of chain
        guard comment.replies != nil else {
            return nil
        }
        var toRet = holder
        for var reply in comment.replies!.data.children.compactMap({ $0.data }) {
            toRet.append(reply.analyze()!)
            if !(reply.replies?.data.children.isEmpty ?? true) {
                // This reply has replies, go to end of reply chain before continuing
                for reply in reply.replies!.data.children.compactMap({ reply in
                    reply.data
                }) {
                    toRet += analyzeReplies(reply) ?? []
                }
            }
        }
        return toRet
    }
}

struct SwitchResult: Identifiable {
    var id: ObjectIdentifier
    
    var brand: String
    var kind: String
    var avgSentiment: Float = 0.0
    var comments: [Comment]
    var rating: Int = 0
    var sentimentString: String {
        avgSentiment > 0.0 ? "Positive" : avgSentiment == 0 ? "Neutral" : "Negative"
    }
    
    init(brand: String, kind: String, comments: [Comment]) {
        self.id = .init(SwitchResult.self)
        self.brand = brand
        self.kind = kind
        self.comments = comments
    }
    
    mutating func calculate() {
        let sentimentScores = comments.compactMap { $0.sentimentValue?.floatValue() }
        self.avgSentiment = sentimentScores.average()
        
        // An upvote on a positive sentiment comment is a plus 1 to score
        // An upvote on a negative sentiment comment is a minus 1 to score
        // A downvote on a positive sentiment comment is a minus 1 to score
        // A downvote on a negative sentiment comment is a plus 1 to score
        for comment in comments {
            if let sentiment = comment.sentimentValue?.floatValue() {
                // A positive sentiment comment will add (ups - downs) to score
                // A negative sentiment comment will subtract (ups - downs) from score
                rating += sentiment > 0 ? (comment.ups! - comment.downs!) : -(comment.ups! - comment.downs!)
            }
        }
    }
}

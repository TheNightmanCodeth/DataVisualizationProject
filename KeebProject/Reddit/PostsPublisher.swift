//
//  PostsPublisher.swift
//  
//
//  Created by Joe on 11/6/22.
//

import Foundation
import Combine

class PostsPublisher {
    public let publisher: PassthroughSubject<[String], Error> = .init()
    private var count: Int = 100
    private var decoder: JSONDecoder = .init()
    
    init(count: Int) {
        if count % 100 == 0 {
            try! start(count)
        } else {
            fatalError("count must be a multiple of 100")
        }
    }
    
    func start(_ posts: Int, after: String? = nil) throws {
        guard posts % 100 == 0 else {
            throw "fromPosts must be a multiple of 100"
        }
        let limit = posts > 100 ? 100 : posts
        let afterArg = after != nil ? "?after=\(after!)" : ""
        if let url = URL(string: "https://www.reddit.com/r/MechanicalKeyboards.json?limit=\(limit)\(afterArg)") {
            URLSession.shared.dataTask(with: url) { [self] data, _, error in
                if error != nil {
                    publisher.send(completion: .failure("Request returned error"))
                } else {
                    if data != nil {
                        if let response = try? decoder.decode(BaseListing<ListingData>.self, from: data!) {
                            let ids = response.data.children.compactMap { $0.data.id }
                            publisher.send(ids)
                            if posts == 100 {
                                publisher.send(completion: .finished)
                            } else {
                                publisher.send(response.data.children.map { $0.data.id })
                                if (posts - 100) % 100 == 0 {
                                    try! start(posts - 100, after: response.data.after)
                                }
                            }
                        } else {
                            publisher.send(completion: .failure("Couldn't decode response"))
                        }
                    } else {
                        publisher.send(completion: .failure("Server returned nil"))
                    }
                }
            }.resume()
        } else {
            publisher.send(completion: .failure("Couldn't make url"))
        }
    }
}

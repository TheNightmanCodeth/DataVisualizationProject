//
//  Keeb.swift
//  KeebProject
//
//  Created by Joe on 11/6/22.
//

import Foundation
import Combine

class Keeb: ObservableObject {
    static let shared: Keeb = .init()
    var cancellables: [AnyCancellable] = []
    @Published var UIResults: [SwitchResult] = []
    var results: [SwitchResult] = []
    func run() {
        RedditSentimentAnalyzer(posts: 1000).commentsPublisher.sink(receiveCompletion: { [self] completion in
            switch completion {
            case .failure(let failure):
                log(.error(failure.localizedDescription))
                for var result in results {
                    result.calculate()
                    log(.result(result))
                }
            case .finished:
                for var result in results {
                    result.calculate()
                    log(.result(result))
                }
            }
        }, receiveValue: { [self] comments in
            for brand in Keywords.brands {
                for comment in comments {
                    if comment.body?.contains(brand) ?? false {
                        if let resultIndex = results.firstIndex(where: { $0.brand == brand }) {
                            log(.info("Adding to \(brand)"))
                            var result = results[resultIndex]
                            result.comments.append(comment)
                            results[resultIndex] = result
                        } else {
                            log(.info("Adding \(brand)"))
                            results.append(SwitchResult(brand: brand, kind: "", comments: [comment]))                            
                        }
                    }
                }
            }
        }).store(in: &cancellables)
    }
    
    func log(_ msg: LogType) {
        switch msg {
        case .error(let error):
            print(error)
        case .info(let info):
            print("*  \(info)\n")
        case .result(let result):
            let header = "============= \(result.brand) \(result.kind) ============="
            print(header)
            print("Average Sentiment: \(result.avgSentiment) (\(result.sentimentString)")
            print("Score: \(result.rating)")
            print("Comments: \(result.comments.count)")
            print(header.map { _ in "=" })
        }
        
    }
    
    enum LogType {
        case error(_ error: String)
        case info(_ info: String)
        case result(_ result: SwitchResult)
    }
    
    func prettyPrint() {
        for result in results {
            log(.result(result))
        }
    }
}

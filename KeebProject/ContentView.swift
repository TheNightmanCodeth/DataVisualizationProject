//
//  ContentView.swift
//  KeebProject
//
//  Created by Joe on 11/6/22.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var keeb = Keeb.shared
    
    var body: some View {
        VStack {
            List(keeb.results) { item in
                Text("\(item.brand) \(item.kind)")
                Text("Sentiment: \(item.sentimentString)")
                Text("Score: \(item.rating)")
                Text("Comments: \(item.comments.count)")
            }
        }
        .padding()
        .onAppear {
            DispatchQueue.main.async {
                Keeb.shared.run()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

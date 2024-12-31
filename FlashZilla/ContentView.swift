//
//  ContentView.swift
//  FlashZilla
//
//  Created by Bruno Oliveira on 30/12/24.
//

///To force landscape mode, go to your target options in the Info tab, open the disclosure indicator for the key “Supported interface orientations (iPhone)” and delete the portrait option so it leaves just the two landscape options.

import SwiftUI

struct ContentView: View {
    @State private var cards = Array<Card>(repeating: .example, count: 10)
    
    var body: some View {
        ZStack {
            Image(.background)
                .resizable()
                .ignoresSafeArea()
            VStack {
                ZStack {
                    ForEach(0..<cards.count, id: \.self) { index in
                        //CardView(card: cards[index])
                            //.stacked(at: index, in: cards.count)
                        
                        ///Finally, we can update the way we create CardView so that we use trailing closure syntax to remove the card when it’s dragged more than 100 points. This is just a matter of calling the removeCard(at:) method we just wrote, but if we wrap that inside a withAnimation() call then the other cards will automatically slide up.
                        
                        CardView(card: cards[index]) {
                            withAnimation {
                                removeCard(at: index)
                            }
                        }
                        .stacked(at: index, in: cards.count)
                        
                    }
                }
            }
        }
    }
    
    ///we can now write a method to handle removing a card, then connect it to that closure in CardView.
    func removeCard(at index: Int) {
        ///This takes an index in our cards array and removes that item
        cards.remove(at: index)
    }
    
}

#Preview {
    ContentView()
}

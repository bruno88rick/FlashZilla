//
//  CardView.swift
//  FlashZilla
//
//  Created by Bruno Oliveira on 30/12/24.
//

import SwiftUI

struct CardView: View {
    @State private var isShowingAnswer = false
    ///track how far user drag the card
    @State private var offset = CGSize.zero
    
    let card: Card
    
    ///we don’t want CardView to call up to ContentView and manipulate its data directly, because that causes spaghetti code. Instead, a better idea is to store a closure parameter inside CardView that can be filled with whatever code we want later on – it means we have the flexibility to get a callback in ContentView without explicitly tying the two views together.
    var removal: (() -> Void)? = nil
    ///As you can see, that’s a closure that accepts no parameters and sends nothing back, defaulting to nil so we don’t need to provide it unless it’s explicitly needed.
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(.white)
                .shadow(radius: 10)
            
            VStack {
                Text(card.prompt)
                    .font(.largeTitle)
                    .foregroundStyle(.black)
                if isShowingAnswer {
                    Text(card.answer)
                        .font(.title)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(20)
            .multilineTextAlignment(.center)
        }
        .frame(width: 450, height: 250)
        ///Tip: A width of 450 is no accident: the smallest iPhones have a landscape width of 480 points, so this means our card will be fully visible on all devices.
        ///offset.width will contain how far the user dragged our card, but we don’t want to use that for our rotation because the card would spin too fast So, instead add this modifier below frame(), so we use 1/5th of the drag amount:
        .rotationEffect(.degrees(offset.width / 5.0))
        ///Next we’re going to apply our movement, so the card slides relative to the horizontal drag amount. Again, we’re not going to use the original value of offset.width because it would require the user to drag a long way to get any meaningful results, so instead we’re going to multiply it by 5 so the cards can be swiped away with small gestures.
        .offset(x: offset.width * 5)
        ///While we’re here, I want to add one more modifier based on the drag gesture: we’re going to make the card fade out as it’s dragged further away.
        ///We’re going to take 1/50th of the drag amount, so the card doesn’t fade out too quickly.
        ///We don’t care whether they have moved to the left (negative numbers) or to the right (positive numbers), so we’ll put our value through the abs() function. If this is given a positive number it returns the same number, but if it’s given a negative number it removes the negative sign and returns the same value as a positive number.
        ///We then use this result to subtract from 2. The use of 2 here is intentional, because it allows the card to stay opaque while being dragged just a little. So, if the user hasn’t dragged at all the opacity is 2.0, which is identical to the opacity being 1. If they drag it 50 points left or right, we divide that by 50 to get 1, and subtract that from 2 to get 1, so the opacity is still 1 – the card is still fully opaque. But beyond 50 points we start to fade out the card, until at 100 points left or right the opacity is 0
        .opacity(2 - Double(offset.width / 50))
        ///we’ve created a property to store the drag amount, and added three modifiers that use the drag amount to change the way the view is rendered. What remains is the most important part: we need to actually attach a DragGesture to our card so that it updates offset as the user drags the card around. Drag gestures have two useful modifiers of their own, letting us attach functions to be triggered when the gesture has changed (called every time they move their finger), and when the gesture has ended (called when they lift their finger). Both of these functions are handed the current gesture state to evaluate. In our case we’ll be reading the translation property to see where the user has dragged to, and we’ll be using that to set our offset property, but you can also read the start location, predicted end location, and more. When it comes to the ended function, we’ll be checking whether the user moved it more than 100 points in either direction so we can prepare to remove the card, but if they haven’t we’ll set offset back to 0.
        .gesture(
            DragGesture()
                .onChanged { drag in
                    offset = drag.translation
                }
                .onEnded { _ in
                    if abs(offset.width) > 100 {
                        //remove the card -> call to the removal closure
                        removal?()
                        ///This question mark here means the closure will only be called if it has been set.
                    } else {
                        //card moved to original location
                        offset = .zero
                    }
                }
            
        )
        .onTapGesture {
            isShowingAnswer.toggle()
        }
    }
}

#Preview {
    CardView(card: .example)
}

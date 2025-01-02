//
//  ContentView.swift
//  FlashZilla
//
//  Created by Bruno Oliveira on 30/12/24.
//

///To force landscape mode, go to your target options in the Info tab, open the disclosure indicator for the key “Supported interface orientations (iPhone)” and delete the portrait option so it leaves just the two landscape options.

import SwiftUI

struct ContentView: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) var accessibilityDifferentiateWithoutColor
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.accessibilityVoiceOverEnabled) var accessibilityVoiceOverEnabled
    
    @State private var cards = [Card]() //Array<Card>(repeating: .example, count: 10)
    @State private var timeRemaining = 100
    @State private var isActive = true
    ///We have two var for scenePhase here because the environment value tells us whether the app is active or inactive in terms of its visibility, but we’ll also consider the app inactive is the player has gone through their deck of flashcards – it will be active from a scene phase point of view, but we don’t keep the timer ticking.
    
    @State private var showingEditScreen = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            //Image(.background)
            
            ///our UI is a bit of a mess when used with VoiceOver. If you launch it on a real device with VoiceOver enabled, you’ll find that you can tap on the background image to get “Background, image” read out, which is pointless. To fix the background image problem we should make it use a decorative image so it won’t be read out as part of the accessibility layout
            Image(decorative: "background")
                .resizable()
                .ignoresSafeArea()
            VStack {
                Text("Time: \(timeRemaining)")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                    .background(.black.opacity(0.75))
                    .clipShape(.capsule)
                
                if cards.isEmpty {
                    Button("Start Again", action: resetCards)
                        .padding()
                        .background(.white)
                        .foregroundStyle(.black)
                        .clipShape(.capsule)
                }
                
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
                        ///it’s possible to drag cards around when they aren’t at the top. This is confusing for users because they can grab a card they can’t actually see, so this should never be possible. To fix this we’re going to use allowsHitTesting() so that only the last card – the one on top – can be dragged around
                        .allowsHitTesting(index == cards.count - 1)
                        ///make small swipes to the right and VoiceOver will move through all the accessibility elements – it reads out the text from all our cards, even the ones that aren’t visible. To fix the cards, we need to use an accessibilityHidden() modifier with a similar condition to the allowsHitTesting() modifier we added a minute ago. In this case, every card that’s at an index less than the top card should be hidden from the accessibility system because there’s really nothing useful it can do with the card:
                        .accessibilityHidden(index < cards.count - 1)                        
                    }
                }
                ///if allowHitTesting is false in the parameter, swiftUI will disable all kind of interactive (click, gestures and more). This will disable interactive if timeRemaing is 0
                .allowsHitTesting(timeRemaining > 0)
            }
            
            VStack {
             
                HStack {
                  Spacer()
                    
                    Button {
                        showingEditScreen = true
                    } label: {
                        Image(systemName: "plus.circle")
                            .padding()
                            .background(.black.opacity(0.7))
                            .clipShape(.circle)
                    }
                }
                
                Spacer()
                
            }
            .foregroundStyle(.white)
            .font(.largeTitle)
            .padding()
            
            ///we can make those buttons visible when either accessibilityDifferentiateWithoutColor is enabled or when VoiceOver
            if accessibilityDifferentiateWithoutColor || accessibilityVoiceOverEnabled {
                VStack {
                    Spacer()
                    
                    /*HStack {
                        Image(systemName: "xmark.circle")
                            .padding()
                            .background(.black.opacity(0.7))
                            .clipShape(.circle)
                        Spacer()
                        Image(systemName: "checkmark.circle")
                            .padding()
                            .background(.black.opacity(0.7))
                            .clipShape(.circle)
                    } <- old cold with button voice over problem */
                    ///Third, we need to make it easier for users to mark cards as correct or wrong, because right now our images just don’t cut it. Not only do they stop users from interacting with our app using tap gestures, but they also get read out as their SF Symbols name – “checkmark, circle, image” – rather than anything useful. To fix this we need to replace the images with buttons that actually remove the cards. We don’t actually do anything different if the user was correct or wrong – I need to leave something for your challenges! – but we can at least remove the top card from the deck. At the same time, we’re going to provide an accessibility label and hint so that users get a better idea of what the buttons do.
                    HStack {
                        Button {
                            withAnimation {
                                removeCard(at: cards.count - 1)
                            }
                        } label: {
                            Image(systemName: "xmark.circle")
                                .padding()
                                .background(.black.opacity(0.7))
                                .clipShape(.circle)
                        }
                        .accessibilityLabel("Wrong")
                        .accessibilityHint("Mark your answer as being incorrect.")
                        
                        Spacer()
                        
                        Button {
                            withAnimation {
                                removeCard(at: cards.count - 1)
                            }
                        } label: {
                            Image(systemName: "checkmark.circle")
                                .padding()
                                .background(.black.opacity(0.7))
                                .clipShape(.circle)
                        }
                        .accessibilityLabel("Correct")
                        .accessibilityHint("Mark your answer as being correct.")
                    }
                    .foregroundStyle(.white)
                    .font(.largeTitle)
                    .padding()
                }
            }
        }
        .onReceive(timer) { time in
            ///exits immediately is isActive is false and do not decrement the timeRemaining
            guard isActive else { return }
            
            ///That adds a trivial condition to make sure we never stray into negative numbers.
            if timeRemaining > 0 {
                timeRemaining -= 1
            }
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                ///making sure isActive stays false when returning from the background – we should just update our scene phase code so it explicitly checks for cards:
                if cards.isEmpty == false {
                    isActive = true
                }
            } else {
                isActive = false
            }
        }
        ///calls resetCards() when dismissed - This isn’t helpful for times you need to pass back data from the sheet, but here we’re just going to call resetCards() so it’s perfect
        /*.sheet(isPresented: $showingEditScreen, onDismiss: resetCards) {
            EditCard()
        }*/
        
        ///When we write EditCards(), we’re relying on syntactic sugar – we’re treating our view struct like a function, because Swift silently treats that as a call to the view’s initializer. So, in practice we’re actually writing EditCards.init(), just in a shorter way.This all matters because rather than creating a closure that calls the EditCards initializer, we can actually pass the EditCards initializer directly to the sheet, like this: (another way to call the sheet)
        .sheet(isPresented: $showingEditScreen, onDismiss: resetCards, content: EditCard.init)
        ///That means “when you want to read the content for the sheet, call the EditCards initializer and it will send you back the view to use . Important: This approach only works because EditCards has an initializer that accepts no parameters. If you need to pass in specific values you need to use the closure-based approach instead
        
        ///Anyway, as well as calling resetCards() when the sheet is dismissed, we also want to call it when the view first appears
        .onAppear(perform: resetCards)
    }
    
    ///we can now write a method to handle removing a card, then connect it to that closure in CardView.
    func removeCard(at index: Int) {
        ///Because those buttons remain onscreen (accessibility buttons) even when the last card has been removed, we need to add a guard check to the start of removeCard(at:) to make sure we don’t try to remove a card that doesn’t exist.
        guard index >= 0 else { return }
        
        ///This takes an index in our cards array and removes that item
        cards.remove(at: index)
        
        ///stop the timer when the final card is removed
        if cards.isEmpty {
            isActive = false
        }
    }
    
    func resetCards() {
        //cards = Array<Card>(repeating: .example, count: 10)
        timeRemaining = 100
        isActive = true
        loadData()
    }
    
    func loadData() {
        if let data = UserDefaults.standard.data(forKey: "Cards") {
            if let decoded = try? JSONDecoder().decode([Card].self, from: data) {
                cards = decoded
            }
        }
    }
    
}

#Preview {
    ContentView()
}

//
//  Card.swift
//  FlashZilla
//
//  Created by Bruno Oliveira on 30/12/24.
//

import Foundation

///We’re going to design a new EditCards view to encode and decode a Card array to UserDefaults, but before we do that I’d like you to make the Card struct conform to Codable like this

struct Card: Codable {
    var prompt: String
    var answer: String
    
    static let example = Card(prompt: "Who Played the 13th Doctor in Doctor Who?", answer: "Jodie Whittaker")
}

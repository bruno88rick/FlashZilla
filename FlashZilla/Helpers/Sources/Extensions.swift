//
//  Extensions.swift
//  FlashZilla
//
//  Created by Bruno Oliveira on 30/12/24.
//

import Foundation
import SwiftUI

extension View {
    func stacked(at position: Int, in total: Int) -> some View {
        let offset = Double(total - position)
        return self.offset(y: offset * 10)
    }
}

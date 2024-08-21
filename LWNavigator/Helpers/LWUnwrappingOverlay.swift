//
//  LWUnwrappingOverlay.swift
//  LWNavigator
//
//  Created by Leon Weimann on 08.03.23.
//

import SwiftUI

//MARK: LWUnwrappingOverlay
struct LWUnwrappingOverlay<V,C>: ViewModifier where C: View {
    init(for value: Binding<V?>, @ViewBuilder content: @escaping (V) -> C) {
        self._value = value
        self.content = content
    }
    
    @Binding var value: V?
    let content: (V) -> C
    
    var show: Binding<Bool> {
        .init { value != nil }
        set: { if !$0 { value = nil } }
    }
    
    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: show) {
                self.content(value!)
            }
    }
}

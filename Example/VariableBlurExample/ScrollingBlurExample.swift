//
//  ScrollingBlurExample.swift
//  VariableBlurExample
//
//  Created by Phil Zakharchenko on 4/26/25.
//

import SwiftUI
import VariableBlur

struct ScrollingBlurExample: View {
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            Image(.mountain)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            
            // Apply the variable blur based on scroll position.
            VariableBlur(
                .smoothLinear,
                blurRadius: min(30, scrollOffset / 10),
                from: .top,
                to: .center
            )
            
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(0..<10) { i in
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.white.opacity(0.8))
                            .frame(height: 100)
                            .padding(.horizontal)
                    }
                }
                .padding(.top, 200)
                .onGeometryChange(for: CGFloat.self) {
                    $0.frame(in: .global).minY.rounded()
                } action: { offset in
                    scrollOffset = max(0, -offset)
                }
            }
        }
    }
}

#Preview("Advanced Scrolling Blur") {
    ScrollingBlurExample()
}

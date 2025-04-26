//
//  ContentView.swift
//  VariableBlurExample
//
//  Created by Phil Zakharchenko on 4/26/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            GradientBlurExample()
                .tabItem {
                    Label("Simple Gradient", systemImage: "square.3.layers.3d")
                }
            
            CustomMaskExample()
                .tabItem {
                    Label("Custom Mask", systemImage: "square.dashed")
                }
            
            ScrollingBlurExample()
                .tabItem {
                    Label("Scrolling Blur", systemImage: "arrow.up.and.down")
                }
        }
    }
}

#Preview("Simple Gradient Blur") {
    GradientBlurExample()
}

#Preview("Custom Mask") {
    CustomMaskExample()
}

#Preview("Advanced Scrolling Blur") {
    ScrollingBlurExample()
}

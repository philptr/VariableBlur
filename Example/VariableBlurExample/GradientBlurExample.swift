//
//  GradientBlurExample.swift
//  VariableBlurExample
//
//  Created by Phil Zakharchenko on 4/26/25.
//

import SwiftUI
import VariableBlur

struct GradientBlurExample: View {
    var body: some View {
        ZStack {
            Image(.mountain)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            
            VariableBlur(
                blurRadius: 30,
                from: .bottom,
                to: .top
            )
        }
    }
}

#Preview("Simple Gradient Blur") {
    GradientBlurExample()
}

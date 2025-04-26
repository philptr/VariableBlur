//
//  CustomMaskExample.swift
//  VariableBlurExample
//
//  Created by Phil Zakharchenko on 4/26/25.
//

import SwiftUI
import VariableBlur

struct CustomMaskExample: View {
    var body: some View {
        ZStack {
            Image(.mountain)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            
            VariableBlur(blurRadius: 25) {
                // Use the SwiftUI linear gradient as the mask for the variable blur.
                LinearGradient(
                    colors: [.black, .clear, .black],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
            
            Text("Variable Blur")
                .foregroundStyle(.white)
                .font(.largeTitle.bold())
        }
    }
}

#Preview("Custom Mask") {
    CustomMaskExample()
}

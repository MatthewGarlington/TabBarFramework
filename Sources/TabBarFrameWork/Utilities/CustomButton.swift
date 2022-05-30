
//  File.swift
//  
//
//  Created by Matthew Garlington on 5/30/22.
//


import SwiftUI

struct LongPrimitiveButtonStyle: PrimitiveButtonStyle {
    
    var minDuration = 0.5
    var pressedColor: Color = Color.blue
    
    func makeBody(configuration: Configuration) -> some View {
        ButtonStyleBody(configuration: configuration,
                        minDuration: minDuration,
                        pressedColor: pressedColor)
    }
    
    private struct ButtonStyleBody: View {
        
        let configuration: Configuration
        let minDuration: CGFloat
        let pressedColor: Color
        @GestureState private var isPressed = false
        
        var body: some View {
            let longPress = LongPressGesture(minimumDuration: minDuration)
                .updating($isPressed) { value, state, _ in
                    state = value
                }
                .onEnded { _ in
                    self.configuration.trigger()
                }
            return configuration.label
                .padding(12)
                .background(
                    GeometryReader { proxy in
                        ZStack {
                            if isPressed {
                                RoundedRectangle(cornerRadius: isPressed ? proxy.size.height / 2 : 8)
                                    .fill(pressedColor)
                                    .shadow(color: .white.opacity(0.2), radius: 5, x: 5, y: 5)
                            } else {
                                RoundedRectangle(cornerRadius: isPressed ? proxy.size.height / 2 : 8)
                                    .fill(Material.bar)
                                    .shadow(color: .white.opacity(0.2), radius: 5, x: 5, y: 5)
                            }
                            
                            RoundedRectangle(cornerRadius:  isPressed ? proxy.size.height / 2 : 8)
                                .stroke(Color.white)
                        }
                    }
                    
                )
                .foregroundColor(.secondary)
                .gesture(longPress)
                .scaleEffect(isPressed ? 0.7 : 1.0)
                .animation(.spring(), value: isPressed)
        }
    }
}


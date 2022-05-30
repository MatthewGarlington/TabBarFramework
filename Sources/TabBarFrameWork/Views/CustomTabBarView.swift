//
//  File.swift
//  
//
//  Created by Matthew Garlington on 5/30/22.
//

import SwiftUI
import ComposableArchitecture


public struct CustomTabBarView: View {
    public let store: Store<CustomTabBarState, CustomTabBarAction>
    
    public init(store: Store<CustomTabBarState, CustomTabBarAction>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(self.store) { (viewStore: ViewStore<CustomTabBarState, CustomTabBarAction>) in
            ZStack {
                RoundedRectangle(cornerRadius: 15.0, style: .continuous)
                    .fill(Color.black)
                    .frame(height: 75)
                
                HStack {
                    Spacer()
                    Button {
                        viewStore.send(.profileIsSelected)
                    } label: {
                        Label {
                            Text("Profile")
                                .foregroundColor(viewStore.state.profileSelected ? .red : .secondary).opacity(0.5)
                        } icon: {
                            Image(systemName: "person")
                                .foregroundColor(viewStore.state.profileSelected ? .red : .secondary).opacity(0.5)
                        }
                    }
                    
                    .buttonStyle(LongPrimitiveButtonStyle(minDuration: 0.10, pressedColor: .red.opacity(0.4)))
                    Spacer()
                    RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                        .fill(Color.secondary)
                        .opacity(0.3)
                        .frame(width: 2, height: 50)
                    Spacer()
                    Button {
                        viewStore.send(.feedIsSelected)
                    } label: {
                        Label {
                            Text("Feed")
                                .foregroundColor(viewStore.state.feedIsSelected ? .red : .secondary).opacity(0.5)
                        } icon: {
                            Image(systemName: "house")
                                .foregroundColor(viewStore.state.feedIsSelected ? .red : .secondary).opacity(0.5)
                        }
                    }
                    
                    .buttonStyle(LongPrimitiveButtonStyle(minDuration: 0.10, pressedColor: .red.opacity(0.4)))
                    
                    Spacer()
                }
            }
        }
    }
}

public struct CustomTabBarView_Previews: PreviewProvider {
    static var mockStore = Store(initialState: CustomTabBarState(),
                                 reducer: customTabBarReducer,
                                 environment: .cancelRequest)
    public static var previews: some View {
        CustomTabBarView(store: mockStore)
    }
}


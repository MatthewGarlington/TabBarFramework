//
//  File.swift
//  
//
//  Created by Matthew Garlington on 5/30/22.
//

import Foundation
import ComposableArchitecture

public struct CustomTabBarState: Equatable {
    public var profileSelected: Bool
    public var feedIsSelected: Bool
    
    public init(
        profileSelected: Bool = false,
        feedIsSelected: Bool = false
    ) {
        self.profileSelected = profileSelected
        self.feedIsSelected = feedIsSelected
    }
}

public enum CustomTabBarAction: Equatable {
    case profileIsSelected
    case feedIsSelected
}


public typealias CustomTabBarEnviroment = NetworkRequestAction<Nothing, NetworkError>



public let customTabBarReducer = Reducer<CustomTabBarState, CustomTabBarAction, CustomTabBarEnviroment> { state, action, env in
    switch action {
    case .profileIsSelected:
        state.profileSelected = true
        state.feedIsSelected = false
        return .none
        
    case .feedIsSelected:
        state.profileSelected = false
        state.feedIsSelected = true
        return .none
    }
}

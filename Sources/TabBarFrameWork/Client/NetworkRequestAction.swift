//
//  File.swift
//  
//
//  Created by Matthew Garlington on 5/30/22.
//

import ComposableArchitecture
import Foundation

/**
 This action should be used for as basic request and response pattern when making network requests.
 The request action initiates the network call, and should map it's response to the response actions.

    *Success is an object that represents a successful call.
    *Failure is the Error type represented when the call fails.
 */
public enum NetworkRequestAction<Success: Equatable, Failure: Error>: Equatable where Failure: Equatable {
    case request
    case response(Result<Success, Failure>)
    case cancelRequest
}

public enum NetworkError: Equatable, LocalizedError {
    case requestCreationError
    case invaildAccessToken
    case blobImageDecodingFailed
    case networkFailure(String)
    case urlError(URLError)
    case parcelLinesError(ParcelLinesError)
    case estimateFrameworkError(EstimateFrameworkError)

    public var errorDescription: String? {
        switch self {
        case .requestCreationError:
            return "Error creating request"
        case .invaildAccessToken:
            return "The access token is invalid."
        case let .networkFailure(errorMessage):
            return errorMessage
        case let .urlError(error):
            return error.localizedDescription
        case .blobImageDecodingFailed:
            return "Blob image decoding failed."
        case let .parcelLinesError(error):
            return error.localizedDescription
        case let .estimateFrameworkError(error):
            return error.localizedDescription
        }
    }
}

public enum ParcelLinesError: Equatable, LocalizedError {
    // Returned when the sik token is not in the form /dc1/_T197/54babd3f-72ca-4776-99df-048969f764bc-106149_570492940
    case invalidSikToken

    public var errorDescription: String? {
        switch self {
        case .invalidSikToken:
            return "Sik Token is not in the form /<data center>/<temp id>/<token>"
        }
    }
}

public enum EstimateFrameworkError: Equatable, LocalizedError {
    case maxEstimateExceeded

    public var errorDescription: String? {
        switch self {
        case .maxEstimateExceeded:
            return "Maximum number of estimates already exist."
        }
    }
}

/**

 */

public protocol SettableAccessToken {
    var setAccessToken: (_ accesstoken: String) -> Effect<Never, Never> { get }
}

/**
 I've noticed that alot of our Environments that connect to an external service have this pattern.
 You can use it to represent a basic environment that includes a client, environmentType and a
 DispatchQueue to return calls on.
 */
public struct NetworkEnvironment<Client> {
    public let client: Client
    public let mainQueue: AnySchedulerOf<DispatchQueue>

    public init(client: Client, mainQueue: AnySchedulerOf<DispatchQueue>) {
        self.client = client
        self.mainQueue = mainQueue
    }
}

// Common Networking items
public let methodPost: (URLRequest) -> URLRequest = {
    var copy = $0
    copy.httpMethod = "POST"
    return copy
}

public let methodGet: (URLRequest) -> URLRequest = {
    var copy = $0
    copy.httpMethod = "GET"
    return copy
}

public let methodDelete: (URLRequest) -> URLRequest = {
    var copy = $0
    copy.httpMethod = "DELETE"
    return copy
}

// Takes and eTag and adds a if-none-match header if the etag is present.
public func ifMatchNone(_ eTag: String?) -> (URLRequest) -> URLRequest {
    {
        var copy = $0
        eTag.map { eTag in
          //  copy.setValue(eTag, forHTTPHeaderField: .ifNoneMatch)
        }
        return copy
    }
}

public func cachePolicy(_ policy: URLRequest.CachePolicy) -> (URLRequest) -> URLRequest {
    {
        var copy = $0
        copy.cachePolicy = policy
        return copy
    }
}

public let methodPut: (URLRequest) -> URLRequest = {
    var copy = $0
    copy.httpMethod = "PUT"
    return copy
}

public let acceptJson: (URLRequest) -> URLRequest = {
    var copy = $0
  //  copy.setValue("application/json", forHTTPHeaderField: .accept)
    return copy
}

public let contentJson: (URLRequest) -> URLRequest = {
    var copy = $0
   // copy.setValue("application/json", forHTTPHeaderField: .contentType)
    return copy
}

public let contentJpg: (URLRequest) -> URLRequest = {
    var copy = $0
  //  copy.setValue("image/jpeg", forHTTPHeaderField: .contentType)
    return copy
}

public let blobTypeBlock: (URLRequest) -> URLRequest = {
    var copy = $0
   // copy.setValue("BlockBlob", forHTTPHeaderField: .blobType)
    return copy
}

public let addApiKey: (URLRequest) -> URLRequest = {
    var copy = $0
   // copy.setValue(AppConstants.Api.key, forHTTPHeaderField: .xApiKey)
    return copy
}

public func addAccessToken(_ token: String) -> (URLRequest) -> URLRequest {
    {
        var copy = $0
      //  copy.setValue("Bearer \(token)", forHTTPHeaderField: .authorization)
        return copy
    }
}

public func addJsonBody<T>(_ encodable: T) -> (URLRequest) -> URLRequest where T: Encodable {
    {
        var copy = $0
        copy.httpBody = try! JSONEncoder().encode(encodable)
        return copy
    }
}

public func addImageData(_ imageData: Data?) -> (URLRequest) -> URLRequest {
    {
        var copy = $0
        copy.httpBody = imageData
        return copy
    }
}

public func upgradeToHttps(_ url: URL) -> (URL) {
    var comps = URLComponents(url: url, resolvingAgainstBaseURL: false)!
    comps.scheme = "https"
    return comps.url!
}

/**
 Takes a url string and trys to extract the last component of the path in the url.
 */
public func extractLastComponent(_ imageUrl: String) -> String? {
    imageUrl
//        |> URL.init(string:)
//        |> { $0?.pathComponents.last }
//        |> { $0 == "/" ? nil : $0 }
}

public func urlEncode(_ value: String) -> String {
    let allowedCharacterSet = CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ").inverted

    if let escapedString = value.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) {
        return escapedString
    } else {
        return value
    }
}

public func checkHTTPResponse(data: Data, response: URLResponse) throws -> Data {
    guard let httpResponse = response as? HTTPURLResponse
    else {
        throw URLError(.badServerResponse)
    }
    HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
    if httpResponse.statusCode < 400 {
        return data
    } else {
        let error = URLError(.init(rawValue: httpResponse.statusCode), userInfo: [NSLocalizedDescriptionKey: HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)])

        throw error
    }
}

public func checkAndPassHTTPResponse(data: Data, response: URLResponse) throws -> (Data, HTTPURLResponse) {
    _ = try checkHTTPResponse(data: data, response: response)

    return (data, response as! HTTPURLResponse)
}

/**
 Trys to use a URLResponse as a HTTPURLResponse, throws and error if it can't.
 */
public let httpUrlResponse: (Data,URLResponse) throws -> (Data, HTTPURLResponse) = { data, response in
    guard let httpResponse = response as? HTTPURLResponse
    else {
        throw URLError(.badServerResponse)
    }
    return (data, httpResponse)
    
}




public enum Nothing: Equatable {
    case empty
}


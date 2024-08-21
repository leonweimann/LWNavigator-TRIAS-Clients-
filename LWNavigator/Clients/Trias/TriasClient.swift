//
//  TriasClient.swift
//  LWNavigator
//
//  Created by Leon Weimann on 08.03.23.
//

import CoreLocation
import Foundation

// MARK: TriasClient

///
/// The TriasClient is used for communicating to the Trias-API-Service. It provides all necessary functionality for getting the data from the API.
///
final class TriasClient {
    ///
    /// Initializes an instance of TriasClient
    ///
    /// It is important to understand the idea behind this client.
    ///
    /// You should initialize for each request a new instance. So, this client is not architectured for being used holding a instance over a longer time.
    ///
    /// When the request is done, you should deinitialize this client. Following, this client is not usable for more than one request.
    ///
    public init() {
        // Set timestamp.
        let formatter = Self.timestampFormatter
        self.timestamp = formatter.string(from: Date())
        
        // Set request.
        self.request = URLRequest(url: URL(string: "https://efa-bw.de/trias")!, timeoutInterval: .infinity)
        self.request.addValue("application/xml", forHTTPHeaderField: "Content-Type")
        self.request.addValue("ServerID=bw-ww33", forHTTPHeaderField: "Cookie")
        self.request.httpMethod = "POST"
    }
    
    // MARK: - Properties
    
    ///
    /// The API token.
    ///
    private static let token: String = "LEoN_WeiMANn-_ScHWAnaU"
    
    ///
    /// The timestamp of creating this Client. Is used for all requests this Client does.
    ///
    private let timestamp: String
    
    ///
    /// This property holds the timestamp in a date format.
    ///
    public var dateFromTimestamp: Date {
        // Get timestamp formatter and format date.
        let formatter = Self.timestampFormatter
        let date = formatter.date(from: self.timestamp)
        
        // Ensure, that date isn't nil. If ensurement fails, make assertion failure and return dummy data
        // -> This code should never fail!
        guard let date = date else { assertionFailure(); return .init() }
        
        // Return date.
        return date
    }
    
    ///
    /// This property holds the timestamp formatter for making formatting timestamp values easily.
    ///
    private static let timestampFormatter: DateFormatter = {
        // Create default date formatter.
        let formatter = DateFormatter()
        
        // Apply specific formatting style.
        formatter.dateFormat = "yyyy-MM-dd'T'hh:mm:ss"
        
        // Return configured formatter.
        return formatter
    }()
    
    ///
    /// The urlRequest all requests will be sent with.
    ///
    private var request: URLRequest
    
    // MARK: - Functions
    
    ///
    /// This function gives the ability to get data easily from the API.
    ///
    /// All occur-able errors are thrown through all nested functions out to the accessed point of this function, so error handlich can be done specifically on the given case.
    ///
    /// If no errors occurs this function returns a trias response confirming to the response type of the utilized request.
    ///
    ///     Task {
    ///         do {
    ///             let response = try await TriasClient().request(for: .locationInformation(.name("Apple Park")))
    ///             // utilize response data from here ...
    ///         } catch {
    ///             // handle occur-able errors here ...
    ///         }
    ///     }
    ///
    /// How you can see, utilizing this function is very simple. With just one line of code you have the response from the API.
    ///
    /// So, you do not need any API knowledge and you have not to handle verification, validation or converting with this service.
    ///
    /// - Parameter triasRequest: Here you need to inject the trias request which should be sent to the API.
    /// - Returns: A trias response utilizable for getting the data from the API in a applicable way.
    /// - Throws: An error if there is a problem getting the response from the API
    ///
    public func request<R>(for triasRequest: R) async throws -> R.Response where R: TriasRequest {
        // setup trias request
        var triasRequest = triasRequest
        
        triasRequest.token = Self.token
        triasRequest.timestamp = self.timestamp
        
        // setup url request
        self.request.httpBody = try triasRequest.payload()
        
        // send request to API
        let (data, _) = try await URLSession.shared.data(for: self.request)
        
        // utilize arrived data to generate trias response
        let response = try RawTriasResponse<R.Response>(of: data).parse()
        
        // return trias response
        return response
    }
}

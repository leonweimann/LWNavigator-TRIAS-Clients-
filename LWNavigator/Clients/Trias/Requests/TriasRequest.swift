//
//  TriasRequest.swift
//  LWNavigator
//
//  Created by Leon Weimann on 22.04.23.
//

import Foundation

///
/// A protocol defining a Trias request.
///
/// This protocol is used to represent any request made to the Trias API. It should be adopted by
/// specific request types, each conforming to the protocol by providing their associated TriasResponse type.
///
protocol TriasRequest {
    ///
    /// The associated TriasResponse type for this request.
    ///
    associatedtype Response: TriasResponse

    ///
    /// The timestamp for this request.
    ///
    /// This property includes a timestamp in the request. It is optional, because this value can be set firstly
    /// after initializing the Trias Request. This is caused by the client architecture.
    ///
    var timestamp: String? { get set }

    ///
    /// The token for this request.
    ///
    /// This property is used to authenticate the client for the Trias API in the request. It is optional, because
    /// this value can be set firstly after initializing the Trias Request. This is caused by the client architecture.
    ///
    var token: String? { get set }

    ///
    /// Generates the payload for this request.
    ///
    /// This function is responsible for creating the request's payload (encoding the xml parameters to data
    /// for an url request). The generated payload should conform to the Trias API's requirements for the
    /// specific request type.
    ///
    /// - Returns: The generated payload as a Data instance.
    /// - Throws: An error if there is a problem generating the payload (e.g., due to encoding issues).
    ///
    func payload() throws -> Data
}

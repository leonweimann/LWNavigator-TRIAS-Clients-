//
//  LocationInformationResponse.swift
//  LWNavigator
//
//  Created by Leon Weimann on 22.04.23.
//

import Foundation


// MARK: LocationInformationResponse

extension TriasClient {
    ///
    /// A structure that conforms to the TriasResponse protocol for handling location information responses.
    /// 
    struct LocationInformationResponse: TriasResponse {
        ///
        /// The associated Delivery Payload type for this response.
        ///
        typealias DP = LocationResult
        
        ///
        /// This property holds an empty instance of this TriasResponse. It is utilized for configuring responses protocol-orientied.
        ///
        static var emptyInstance = LocationInformationResponse(timestamp: "", reference: "", language: "", status: false, calcTime: 0, deliveryPayload: [])

        ///
        /// The timestamp this response was sent by the API server.
        ///
        var timestamp: String
        
        ///
        /// The reference of the API server data.
        ///
        var reference: String
        
        ///
        /// The laguage spoken in the country, the reference server sent the data.
        ///
        var language: String
        
        ///
        /// The status boolean value for this response sent by the server.
        ///
        var status: Bool
        
        ///
        /// The calculation time the API server needed for querying all delivery payloads.
        ///
        var calcTime: Int
        
        ///
        /// All delivery palyoads associated with the sent response. It holds the actual data.
        ///
        var deliveryPayload: [LocationResult]
    }
}

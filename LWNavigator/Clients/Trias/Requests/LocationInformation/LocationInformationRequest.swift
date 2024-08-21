//
//  LocationInformationRequest.swift
//  LWNavigator
//
//  Created by Leon Weimann on 22.04.23.
//

import Foundation

// MARK: LocationInformationRequest

extension TriasClient {
    ///
    /// A structure representing a LocationInformationRequest conforming to TriasRequest.
    ///
    /// This structure is responsible for initializing a LocationInformationRequest object with
    /// initial input and restrictions, and providing a method to generate the request payload.
    ///
    struct LocationInformationRequest: TriasRequest {
        ///
        /// The associated TriasResponse type for this request.
        ///
        typealias Response = LocationInformationResponse
        
        ///
        /// Initializes a new LocationInformationRequest object with the given initial input and restrictions.
        ///
        /// - Parameters:
        ///   - initialInput: The initial input for the request.
        ///   - restrictions: The restrictions for the request.
        ///
        init(initialInput: InitialInput, restrictions: Restrictions) {
            self.initialInput = initialInput
            self.restrictions = restrictions
        }
        
        ///
        /// The timestamp for this request.
        ///
        /// This property includes a timestamp in the request. It is optional, because this value can be set firstly
        /// after initializing the Trias Request. This is caused by the client architecture.
        ///
        var timestamp: String?
        
        ///
        /// The token for this request.
        ///
        /// This property is used to authenticate the client for the Trias API in the request. It is optional, because
        /// this value can be set firstly after initializing the Trias Request. This is caused by the client architecture.
        ///
        var token: String?
        
        ///
        /// The initial input for this request.
        ///
        /// This property is used to query for data in the Trias API.
        ///
        let initialInput: InitialInput
        
        ///
        /// The restrictions for this request.
        ///
        /// This property is used for restrict this request. The Trias API will consider this restriction when answering to this request.
        ///
        var restrictions: Restrictions
        
        ///
        /// Generates the payload for this LocationInformationRequest.
        ///
        /// This function is responsible for creating the request's payload (e.g., by encoding the request as XML).
        /// The generated payload should conform to the Trias API's requirements for the specific request type.
        ///
        /// - Returns: The generated payload as a Data instance.
        /// - Throws: A `TriasError.missingValue` error if the timestamp or token are missing.
        ///           A `TriasError.dataConverting` error if the payload cannot be converted to a Data object.
        ///
        func payload() throws -> Data {
            // Ensuring, that there is a timestamp and a token.
            guard
                let timestamp = timestamp,
                let token = token
            else {
                throw TriasError.missingValue
            }
            
            // If needed properties are set, setup payload as string. Inject all properties between into the elements.
            let payload = """
            <?xml version="1.0" encoding="utf-8" ?>
            <Trias xmlns="http://www.vdv.de/trias" xmlns:siri="http://www.siri.org.uk/siri" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="1.2">
                <ServiceRequest>
                    <siri:RequestTimestamp>\(timestamp)</siri:RequestTimestamp>
                    <siri:RequestorRef>\(token)</siri:RequestorRef>
                    <RequestPayload>
                        <LocationInformationRequest>
                            <InitialInput>
                                \(initialInput.string)
                            </InitialInput>
                            <Restrictions>
                                \(restrictions)
                            </Restrictions>
                        </LocationInformationRequest>
                    </RequestPayload>
                </ServiceRequest>
            </Trias>
        """
            
            // Converting string payload to data utilizing UTF-8 encoding.
            if let data = payload.data(using: .utf8) {
                // Return data if converting did succeed.
                return data
            } else {
                // Throw an error because converting string to data failed.
                throw TriasError.dataConverting
            }
        }
    }
}

// MARK: TriasRequest Extension

extension TriasRequest where Self == TriasClient.LocationInformationRequest {
    ///
    /// A static method for creating a LocationInformationRequest with the specified initial input and restrictions.
    ///
    /// - Parameters:
    ///   - initialInput: The initial input for the request.
    ///   - restrictions: The restrictions for the request (default is an empty Restrictions object).
    /// - Returns: A LocationInformationRequest instance initialized with the given parameters.
    ///
    static func locationInformation(_ initialInput: TriasClient.InitialInput, restrictions: TriasClient.Restrictions = .init()) -> Self {
        TriasClient.LocationInformationRequest(initialInput: initialInput, restrictions: restrictions)
    }
}

//
//  LocationResult.swift
//  LWNavigator
//
//  Created by Leon Weimann on 22.04.23.
//

import Foundation

// MARK: LocationResult

extension TriasClient {
    ///
    /// A structure conforming to the DeliveryPayload protocol for handling location results.
    ///
    struct LocationResult: DeliveryPayload {
        ///
        /// The element name associated with this DeliveryPayload.
        ///
        static let elementName = "trias:LocationResult"
        
        ///
        /// An empty instance of this DeliveryPayload, utilized for configuring payloads in a protocol-oriented manner.
        ///
        static let emptyInstance = LocationResult(stopPointRef: "", stopPointName: "", localityRef: "", locationName: "", longitude: 0, latitude: 0, complete: false, probability: 0)
        
        ///
        /// An array of property keys associated with this DeliveryPayload.
        ///
        static let propertyKeys = ["trias:StopPointRef", "trias:StopPointName>trias:Text", "trias:LocationName>trias:Text", "trias:LocalityRef", "trias:Longitude", "trias:Latitude", "trias:Complete", "trias:Probability"]
        
        ///
        /// The unique identifier of the stop point.
        ///
        var stopPointRef: String
        
        
        ///
        /// The name of the stop point.
        ///
        var stopPointName: String
        
        
        ///
        /// The unique identifier of the locality.
        ///
        var localityRef: String
        
        
        ///
        /// The name of the location.
        ///
        var locationName: String
        
        
        ///
        /// The longitude of the location.
        ///
        var longitude: Double
        
        
        ///
        /// The latitude of the location.
        ///
        var latitude: Double
        
        
        ///
        /// A boolean indicating if the location information is complete.
        ///
        var complete: Bool
        
        
        ///
        /// The probability of the location result being accurate.
        ///
        var probability: Double

        ///
        /// Sets the value for a given property key of this DeliveryPayload object.
        ///
        /// - Parameters:
        ///   - value: The value to set for the given `property key`.
        ///   - elementName: The property key for which to set the value.
        /// - Throws: A `TriasError` if the key is not found or the value has an incorrect data type.
        ///
        mutating func setValue(_ value: String, for elementName: String) throws {
            // Switch on element names this DeliveryPayload object provides.
            switch elementName {
            case "trias:StopPointRef":
                // Set stop place reference to value.
                stopPointRef = value
            case "trias:StopPointName>trias:Text":
                // Set stop point name to value.
                stopPointName = value
            case "trias:LocalityRef":
                // Set locality reference to value.
                localityRef = value
            case "trias:LocationName>trias:Text":
                // Set location name to value.
                locationName = value
            case "trias:Longitude":
                // Convert value to double and set longitude to it.
                guard let longitude = Double(value) else { throw TriasError.dataType }
                self.longitude = longitude
            case "trias:Latitude":
                // Convert value to double and set latitude to it.
                guard let latitude = Double(value) else { throw TriasError.dataType }
                self.latitude = latitude
            case "trias:Complete":
                // Convert value to boolean and set complete to it.
                guard let complete = Bool(value) else { throw TriasError.dataType }
                self.complete = complete
            case "trias:Probability":
                // Convert value to double and set probability to it.
                guard let probability = Double(value) else { throw TriasError.dataType }
                self.probability = probability
            default:
                // Throw the TriasError.
                throw TriasError.keyNotFound
            }
        }
    }
}

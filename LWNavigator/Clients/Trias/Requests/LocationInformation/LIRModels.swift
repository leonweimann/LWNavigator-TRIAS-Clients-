//
//  LIRModels.swift
//  LWNavigator
//
//  Created by Leon Weimann on 22.04.23.
//

import CoreLocation
import Foundation

// MARK: InitialInput

extension TriasClient {
    ///
    /// An enumeration for the initial input values, which can be a name, position, or a geographic radius. It is
    /// utilized for configuring an location information request
    ///
    public enum InitialInput {
        ///
        /// This case is utilized for querying the API data by stop location name.
        ///
        case name(String)
        
        ///
        /// This case is utilized for querying the API data by a position coordinate.
        ///
        case position(CLLocationCoordinate2D)
        
        ///
        /// This case is utilized for querying the API data by a circular radius with a center coordinate and a
        /// configurable radius.
        ///
        case radius(CGFloat, center: CLLocationCoordinate2D)
        
        /// Returns the emerging string for the initial input value.
        public var string: String {
            // Switch on self for configuring string keys; Return configured keys.
            switch self {
            case .name(let name): return "<LocationName>\(name)</LocationName>"
            case .position(let position): return "<GeoPosition><Longitude>\(position.longitude)</Longitude><Latitude>\(position.latitude)</Latitude></GeoPosition>"
            case .radius(let radius, center: let center): return "<GeoRestriction><Circle><Center><Longitude>\(center.longitude)</Longitude><Latitude>\(center.latitude)</Latitude></Center><Radius>\(radius)</Radius></Circle></GeoRestriction>"
            }
        }
    }
}
    
// MARK: Restrictions
 
extension TriasClient {
    ///
    /// A structure for defining restrictions for the Trias API request.
    ///
    public struct Restrictions {
        ///
        /// Initializes a new `Restrictions` instance with the specific parameters..
        ///
        /// - Parameters:
        ///   - type: The type of restriction (default is "stop").
        ///   - numberOfResults: The maximum number of results to be returned (default is 10).
        ///   - includePTModes: A boolean indicating whether to include public transport modes (default is false).
        ///
        public init(type: String = "stop", numberOfResults: Int = 10, includePTModes: Bool = false) {
            self.string = """
            <Type>\(type)</Type>
            <NumberOfResults>\(numberOfResults)</NumberOfResults>
            <IncludePtModes>\(includePTModes)</IncludePtModes>
        """
        }
        
        ///
        /// The corresponding string for the restrictions to be used in the XML request.
        ///
        public let string: String
    }
}

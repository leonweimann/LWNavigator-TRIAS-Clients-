//
//  TriasResponse.swift
//  LWNavigator
//
//  Created by Leon Weimann on 22.04.23.
//

import Foundation

///
/// A protocol defining a Trias response.
///
/// This protocol represents any response received from the Trias API. It should be adopted by
/// specific response types, each conforming to the protocol by providing their associated DeliveryPayload type.
///
protocol TriasResponse {
    ///
    /// The associated DeliveryPayload type for this response.
    ///
    associatedtype DP: DeliveryPayload

    ///
    /// An empty instance of the conforming TriasResponse type.
    ///
    /// This property is useful for initializing empty objects, especially during deserialization.
    ///
    static var emptyInstance: Self { get }

    ///
    /// The timestamp of the response.
    ///
    var timestamp: String { get set }

    ///
    /// The reference identifier for the response.
    ///
    var reference: String { get set }

    ///
    /// The language used in the response.
    ///
    var language: String { get set }

    ///
    /// The status of the response, indicating success or failure.
    ///
    var status: Bool { get set }

    ///
    /// The calculation time for generating the response.
    ///
    var calcTime: Int { get set }

    ///
    /// The array of associated delivery payloads for the response.
    ///
    var deliveryPayload: [DP] { get set }
}

///
/// A protocol defining a delivery payload.
///
/// This protocol represents any delivery payload that can be included in a TriasResponse. It should be
/// adopted by specific payload types, each conforming to the protocol by providing required information.
///
protocol DeliveryPayload {
    ///
    /// The element name for the delivery payload type.
    ///
    /// This property is useful for identifying the payload type during deserialization.
    ///
    static var elementName: String { get }

    ///
    /// An empty instance of the conforming DeliveryPayload type.
    ///
    /// This property is useful for initializing empty objects, especially during deserialization.
    ///
    static var emptyInstance: Self { get }

    ///
    /// An array of property keys for the delivery payload type.
    ///
    /// This property is useful for mapping values during deserialization.
    ///
    static var propertyKeys: [String] { get }

    ///
    /// Sets the value for a property key in the delivery payload.
    ///
    /// This method is responsible for setting a value for a given property key during deserialization.
    ///
    /// - Parameters:
    ///   - value: The value to be set.
    ///   - propertyKey: The property key to which the value should be assigned.
    /// - Throws: An error if there is a problem setting the value (e.g., due to type constraints).
    ///
    mutating func setValue(_ value: String, for propertyKey: String) throws
}

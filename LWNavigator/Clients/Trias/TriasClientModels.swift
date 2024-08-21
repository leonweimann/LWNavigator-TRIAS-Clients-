//
//  TriasClientModels.swift
//  LWNavigator
//
//  Created by Leon Weimann on 04.04.23.
//

import Foundation

// MARK: TriasError

extension TriasClient {
    /// This enumeration is used for throwing errors occurring in operations in context with the Trias client.
    enum TriasError: Error {
        /// This Trias error type is thrown when an issue with data converting through the whole process emerges.
        ///
        /// When this error is thrown, it is most likely an issue in one of the data converting steps.
        /// Issues could be caused by converting strings to data format and vice versa.
        case dataConverting

        /// This Trias error type is thrown when there is a problem parsing the data.
        /// This error can occur when the received data has an unexpected format or is incomplete.
        case parsing

        /// This Trias error type is thrown when there is a mismatch between the expected data type and the actual data type.
        /// This error can occur when the data received is not in the expected format or cannot be cast to the expected type.
        case dataType

        /// This Trias error type is thrown when a required key is not found in the data.
        /// This error can occur when the data is missing a key or has a key with a different name than expected.
        case keyNotFound

        /// This Trias error type is thrown when a value that is required for processing is missing.
        /// This error can occur when the data contains a key but no associated value or the value is `nil`.
        case missingValue
    }
}

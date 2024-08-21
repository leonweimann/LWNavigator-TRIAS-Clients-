//
//  TriasResponseModels.swift
//  LWNavigator
//
//  Created by Leon Weimann on 22.04.23.
//

import Foundation

// MARK: RawTriasResponse

extension TriasClient {
    ///
    /// A structure representing a raw Trias response.
    ///
    /// This structure is responsible for initializing a raw Trias response with data and
    /// providing a method to parse the response data into a TriasResponse object.
    ///
    struct RawTriasResponse<T> where T: TriasResponse {
        ///
        /// Initializes a new RawTriasResponse object with the given data.
        ///
        /// - Parameter data: The raw data of the response.
        /// - Throws: A `TriasError.dataConverting` error if the data cannot be converted to a UTF-8 string.
        ///
        public init(of data: Data) throws {
            // Ensuring that data is convertable to a string.
            guard let string = String(data: data, encoding: .utf8) else { throw TriasError.dataConverting }
            
            // If data is convertable, initialize raw Trias response from this data.
            self.data = string
        }
        
        ///
        /// The raw data of the response as a string.
        ///
        private let data: String
        
        ///
        /// Parses the raw response data into a `TriasResponse` object.
        ///
        /// - Returns: A `TriasResponse` object representing the parsed response.
        /// - Throws: A `TriasError.dataConverting` error if the data cannot be converted to a UTF-8 string.
        ///           A `TriasError.parsing` error if the XML parser fails to parse the data.
        ///
        public func parse() throws -> T {
            // Ensuring that data is convertable to data by UTF-8
            guard let data = self.data.data(using: .utf8) else { throw TriasError.dataConverting }
            
            // If data is convertable, initialize XMLParser from it. Make a specific delegate for this
            // parser and connect both.
            let parser = XMLParser(data: data)
            let delegate = TriasXMLParserDelegate<T>()
            parser.delegate = delegate
            
            // Parse data and ensure that it succeed.
            guard parser.parse() else { throw TriasError.parsing }
            
            // Check if parsing process was successful.
            if let error = delegate.error { throw error }
            
            // Return parsed data represented by a TriasResponse object.
            return delegate.response
        }
    }
}
    
// MARK: TriasXMLParserDelegate

extension TriasClient {
    ///
    /// A class acting as an XML parser delegate for parsing Trias responses.
    ///
    /// This class is responsible for parsing XML data into a `TriasResponse` object by conforming
    /// to the `XMLParserDelegate` protocol.
    ///
    fileprivate final class TriasXMLParserDelegate<T>: NSObject, XMLParserDelegate where T: TriasResponse {
        ///
        /// The parsed TriasResponse object.
        ///
        public private(set) var response: T = T.emptyInstance
        
        ///
        /// This property holds the current element name which the parser is parsing on.
        ///
        private var currentElement: String = ""
        
        ///
        /// The text buffer there the values for each element are saved.
        ///
        private var textBuffer = ""
        
        ///
        /// The property for the delivery payload items. It holds the current item, while the parser is configuration it with decoded data.
        ///
        private var deliveryPayloadItem: T.DP?
        
        ///
        /// This property holds all element observers in an array of tuples. Element observers are utilized for decoding information in nested blocks.
        ///
        private var elementObservers: [(parent: String, child: String)] = []
        
        ///
        /// The active parent property stores the active parent when the current element name is nested with an key. If the current element is not
        /// a parent, this property will be nil.
        ///
        private var activeParent: String?
        
        ///
        /// The optional error occuring while the parsing process.
        ///
        public var error: Error?
        
        ///
        /// Throws an error occured while parsing and decoding data.
        ///
        /// Throwing an error will not stop the parsing process in the production app. It will just highlight that the response is defective.
        ///
        /// While testing this application it will send an assertion failure and so crash the application. So, use wisely.
        ///
        /// - Parameter error: This parameter represents the occured error which will be thrown.
        ///
        private func throwError(_ error: Error) {
            // Set occured error to the global error.
            self.error = error
            
            // Throw an assertion failure for crashing the application when testing.
            assertionFailure("An error occured while parsing TriasResponse data: \(String(describing: error))")
        }
        
        ///
        /// Aborts the parsing process and sets the intern error so that the parent can understand the issue.
        /// - Parameters:
        ///   - parser: The XML Parser injected by the delegate.
        ///   - error: This parameter represents the occured error which will be set to the intern error property.
        ///
        private func abortParsing(_ parser: XMLParser, with error: Error) {
            // Set error property.
            self.error = error
            
            // Abort the parsing process.
            parser.abortParsing()
        }
        
        ///
        /// Generates the string key considering the element observers.
        /// - Parameter fallback: The value for the key if there is no observer.
        /// - Returns: The key for the DeliveryPayload object for changing values.
        ///
        private func getKeyWithObserver(with fallback: String) -> String {
            // Ensuring, that there is an active parent. If there is get the ment observer. If ensurement
            // fails return fallback value.
            guard let activeParent = activeParent else { return fallback }
            
            // Get observer from array with active parent index.
            guard let observer = elementObservers.first(where: { $0.parent == activeParent }) else { self.throwError(TriasError.missingValue); return fallback }
            
            // Check if child is correct.
            guard observer.child == currentElement else { return fallback }
            
            // Setup the string key with the observer values and return it.
            return "\(observer.parent)>\(observer.child)"
        }
        
        ///
        /// Handels the start of the operations.
        /// - Parameter parser: The XML Parser injected by the delegate.
        ///
        public func parserDidStartDocument(_ parser: XMLParser) {
            // Check if there are nested values.
            let nestedKeys = T.DP.propertyKeys.filter { $0.contains(">") }
            guard !nestedKeys.isEmpty else { return }
            
            // Loop for all nested keys for seperating parents and childs.
            for key in nestedKeys {
                // Ensure, that there is a pointer and get the index for specific key.
                if let pointer = key.firstIndex(of: ">") {
                    // Get prefix and suffix.
                    let prefix = key.prefix(upTo: pointer)
                    let suffix = key.suffix(from: pointer).dropFirst()

                    // Convert substring subsequences to strings.
                    let parent = String(prefix)
                    let child = String(suffix)

                    // Make observer tuple from parent and child.
                    let newObserver = (parent: parent, child: child)

                    // Append new observer to all observers in this xml parser.
                    self.elementObservers.append(newObserver)
                }
            }
        }
        
        ///
        /// Handles the start operations for a new element.
        /// - Parameters:
        ///   - parser: The XML Parser injected by the delegate.
        ///   - elementName: The element name the parser is starting now.
        ///   - namespaceURI: The namespace uri.
        ///   - qName: The query name.
        ///   - attributeDict: The attribute dictionary
        ///
        public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
            // Set the current element property.
            currentElement = elementName
            
            // Check if there are any observers and if the actual element is a parent. If it is, active the observation.
            if elementObservers.contains(where: { $0.parent == elementName }) { activeParent = elementName }
            
            // Check if current element name is the element name of the TriasResponse's DeliveryPayload.
            // If it is set the delivery payload item property for parsing its data.
            if elementName == T.DP.elementName { deliveryPayloadItem = T.DP.emptyInstance }
            
            // Reset the text buffer, because we are in a new element.
            textBuffer = ""
        }
        
        ///
        /// Handles found characters.
        /// - Parameters:
        ///   - parser: The XML Parser injected by the delegate.
        ///   - string: The string value for the found characters for the element name.
        ///
        public func parser(_ parser: XMLParser, foundCharacters string: String) {
            // Add found characters to text buffer after trimming them.
            textBuffer += string.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        ///
        /// Handles the end operations for the element.
        /// - Parameters:
        ///   - parser: The XML Parser injected by the delegate.
        ///   - elementName: The element name the parser is starting now.
        ///   - namespaceURI: The namespace uri.
        ///   - qName: The query name.
        ///   - attributeDict: The attribute dictionary
        ///
        public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
            // Switching on element names each Trias API response contains.
            switch elementName {
            case "siri:ResponseTimestamp":
                // Set the timestamp property of the to being put on response to the text buffer value.
                response.timestamp = textBuffer
            case "siri:ProducerRef":
                // Set the reference property of the being put on response to the text buffer value.
                response.reference = textBuffer
            case "siri:Status":
                // Set the status property of the to being put on response to the text buffer value
                // converting this from string to boolean.
                response.status = (textBuffer == "true")
            case "trias:Language":
                // Set the language property of the to being put on response to the text buffer value.
                response.language = textBuffer
            case "trias:CalcTime":
                // Set the calc time property of the to being put on response to the text buffer value
                // converting this to an integer offering an failure case to ensure it is not optional.
                response.calcTime = Int(textBuffer) ?? 0
            case T.DP.elementName:
                // Append the configured delivery payload item to the delivery payload array, if there
                // is a delivery payload setupped.
                if let deliveryPayloadItem = deliveryPayloadItem { response.deliveryPayload.append(deliveryPayloadItem) }
            default:
                
                // Ensuring, that there is a delivery payload item which can be configured. If there
                // is no one, throw an error with the helper function and stop execution of decoding but
                // not the execution for the delegation itself.
                guard var item = deliveryPayloadItem else { self.throwError(TriasError.missingValue); break }
                
                // Get key with helper function.
                let key = self.getKeyWithObserver(with: elementName)
                
                // Check if fetched key is available in delivery payload object for being set.
                guard T.DP.propertyKeys.contains(key) else { break }
                
                do {
                    // Try setting the value for the key into the item to the text buffer value.
                    try item.setValue(textBuffer, for: key)
                    // Set object property to changed item.
                    self.deliveryPayloadItem = item
                } catch {
                    // Throw an error because setting value failed.
                    self.throwError(error)
                }
                
                // Clear current element property.
                currentElement = ""
            }
        }
        
        ///
        /// Handles errors the xml parser api throws.
        /// - Parameters:
        ///   - parser: The XML Parser injected by the delegate.
        ///   - parseError: The parsing error occured by the xml parser api, also injected by this.
        ///
        public func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
            self.abortParsing(parser, with: parseError)
        }
    }
}

//
//  InformatikGFS.swift
//  LWNavigator
//
//  Created by Leon Weimann on 23.04.23.
//

import SwiftUI

// MARK: ViewModel

extension InformatikGFS {
    @MainActor final class ViewModel: ObservableObject {
        nonisolated init() { }
        
        @Published var stopName: String = ""
        
        @Published private(set) var response: TriasClient.LocationInformationResponse? = nil
        
        @Published private(set) var isLoading: Bool = false
        
        public var sendDisabled: Bool { stopName.isEmpty }
        
        public nonisolated func sendRequest() {
            Task {
                await MainActor.run {
                    self.response = nil
                    self.isLoading = true
                }
                
                let client = TriasClient()
                let response = try? await client.request(for: .locationInformation(.name(self.stopName)))
                
                await MainActor.run {
                    self.response = response
                    self.isLoading = false
                }
            }
        }
        
        public func clearData() {
            self.response = nil
            self.stopName = ""
        }
    }
}

// MARK: View

struct InformatikGFS: View {
    init(viewModel: ViewModel = .init()) {
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    @StateObject private var viewModel: ViewModel
    
    var body: some View {
        NavigationStack {
            Form {
                requestConfiguringSection
                
                sendRequestSection
                
                responseSection
                
                clearDataSection
            }
            .navigationTitle("Informatik GFS")
        }
    }
}

extension InformatikGFS {
    private var requestConfiguringSection: some View {
        Section {
            TextField("Name der Haltestelle", text: $viewModel.stopName)
        } header: {
            Text("Request Configurations")
        }
    }
    
    private var sendRequestSection: some View {
        Section {
            Button(action: viewModel.sendRequest) {
                Text("Send request")
            }
            .disabled(viewModel.sendDisabled)
        }
    }
    
    @ViewBuilder private var responseSection: some View {
        if let response = viewModel.response {
            Section {
                displayedResponse(for: response)
            } header: {
                Text("Response")
            }
        } else if viewModel.isLoading {
            ProgressView("Requesting ...")
                .frame(maxWidth: .infinity)
                .padding()
        }
    }
    
    private func displayedResponse(for response: TriasClient.LocationInformationResponse) -> some View {
        Group {
            dataForKey(key: "timestamp", data: response.timestamp)
            dataForKey(key: "reference", data: response.reference)
            dataForKey(key: "language", data: response.language)
            dataForKey(key: "calcTime", data: response.calcTime)
            dataForKey(key: "status", data: response.status)
            
            NavigationLink {
                let items = response.deliveryPayload.sorted(by: { $0.stopPointName < $1.stopPointName })
                LocationResultsList(items: items, stopName: viewModel.stopName)
            } label: {
                Text("LocationResults")
            }
        }
    }
    
    private struct LocationResultsList: View {
        let items: [TriasClient.LocationResult]
        let stopName: String
        
        @State private var searchText: String = ""
        
        @State private var highlighted: String = ""
        
        var body: some View {
            ScrollViewReader { scrollProxy in
                List(0 ..< items.count, id: \.self) { i in
                    let item = items[i]
                    
                    Section {
                        LocationResultView(locationResult: item)
                            .foregroundColor(locationResultViewHighlightColor(for: item))
                            .id(item.stopPointRef)
                    } header: {
                        Text("Result \(i + 1) for \(stopName) request")
                    }
                }
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: Text("StopPointNames durchsuchen")) {
                    let data = items.filter({ searchText.isEmpty ? true : $0.stopPointName.lowercased().contains(searchText.lowercased()) }).sorted(by: { $0.stopPointName < $1.stopPointName })
                    ForEach(0 ..< data.count, id: \.self) { i in
                        let item = data[i]
                        
                        SearchCompletionButton(title: item.stopPointName) {
                            withAnimation(.easeInOut(duration: 2)) {
                                highlighted = item.stopPointRef
                                scrollProxy.scrollTo(item.stopPointRef, anchor: .top)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle("LocationResults")
            .toolbar {
                Text(items.count.formatted())
            }
        }
        
        func locationResultViewHighlightColor(for item: TriasClient.LocationResult) -> Color {
            (highlighted.isEmpty || item.stopPointRef == highlighted) ? .primary : .secondary
        }

        struct SearchCompletionButton: View {
            init(title: String, completion: @escaping () -> ()) {
                self.title = title
                self.complition = completion
            }
            
            @Environment(\.dismissSearch) private var dismissSearch
            let complition: () -> ()
            let title: String
            
            var body: some View {
                Button {
                    complition()
                    dismissSearch()
                } label: {
                    Text(title)
                }
            }
        }
        
        struct LocationResultView: View {
            let locationResult: TriasClient.LocationResult
            
            var body: some View {
                Group {
                    dataForKey(key: "stopPointRef", data: locationResult.stopPointRef)
                    dataForKey(key: "stopPointName", data: locationResult.stopPointName)
                    dataForKey(key: "localityRef", data: locationResult.localityRef)
                    dataForKey(key: "locationName", data: locationResult.locationName)
                    dataForKey(key: "latitude", data: locationResult.latitude)
                    dataForKey(key: "longitude", data: locationResult.longitude)
                    dataForKey(key: "complete", data: locationResult.complete)
                    dataForKey(key: "probability", data: locationResult.probability)
                }
            }
            
            private func dataForKey(key: String, data: Any) -> some View {
                HStack(alignment: .center, spacing: 0) {
                    Text(key)
                    
                    Spacer()
                    
                    Text(String(describing: data))
                }
            }
        }
    }
    
    private func dataForKey(key: String, data: Any) -> some View {
        HStack(alignment: .center, spacing: 0) {
            Text(key)
            
            Spacer()
            
            Text(String(describing: data))
        }
    }
    
    @ViewBuilder private var clearDataSection: some View {
        if viewModel.response != nil {
            Section {
                Menu {
                    Button(action: viewModel.clearData) {
                        Text("Confirm")
                    }
                } label: {
                    Text("Clear data")
                }
                .tint(.red)
            }
        }
    }
}

// MARK: MainActorButton

extension Button {
    init(action: @escaping @MainActor () -> (), @ViewBuilder label: @escaping () -> Label) {
        let mainActorAction: () -> () = {
            Task {
                await action()
            }
        }

        self.init(action: mainActorAction, label: label)
    }
}

// MARK: PreviewProvider

struct InformatikGFS_PreviewProvider: PreviewProvider {
    static var previews: some View {
        InformatikGFS()
            .preferredColorScheme(.dark)
    }
}

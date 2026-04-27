#if canImport(SwiftUI)
import SwiftUI
#if canImport(MapKit)
import MapKit
#endif

public struct StageOneRootView: View {
    @State private var selectedTab: AppTab = .stats
    @State private var searchText: String = ""
    private let viewModel: StageOneViewModel

    public init(viewModel: StageOneViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        TabView(selection: $selectedTab) {
            StatsScreen(stats: viewModel.stats)
                .tabItem { Label("Stats", systemImage: "chart.bar") }
                .tag(AppTab.stats)

            VisitedMapScreen(cities: viewModel.visitedCities)
                .tabItem { Label("Map", systemImage: "map") }
                .tag(AppTab.map)

            CityCatalogScreen(cities: viewModel.filteredVisitedCities(query: searchText), searchText: $searchText)
                .tabItem { Label("Cities", systemImage: "building.2") }
                .tag(AppTab.cities)

            Text("Guides coming soon")
                .tabItem { Label("Guides", systemImage: "book") }
                .tag(AppTab.guides)
        }
    }
}

public struct StatsScreen: View {
    private let stats: TravelStats

    public init(stats: TravelStats) {
        self.stats = stats
    }

    public var body: some View {
        List {
            LabeledContent("Trips", value: "\(stats.totalTrips)")
            LabeledContent("Unique countries", value: "\(stats.uniqueCountries)")
            LabeledContent("Unique cities", value: "\(stats.uniqueCities)")
            LabeledContent("Avg duration", value: String(format: "%.1f days", stats.averageTripDurationDays))
        }
        .navigationTitle("Stats")
    }
}

public struct CityCatalogScreen: View {
    private let cities: [City]
    @Binding private var searchText: String

    public init(cities: [City], searchText: Binding<String>) {
        self.cities = cities
        self._searchText = searchText
    }

    public var body: some View {
        NavigationStack {
            List(cities) { city in
                VStack(alignment: .leading) {
                    Text(city.name)
                        .font(.headline)
                    Text("\(city.latitude), \(city.longitude)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .navigationTitle("Cities")
        }
    }
}

public struct VisitedMapScreen: View {
    private let cities: [City]

    public init(cities: [City]) {
        self.cities = cities
    }

    public var body: some View {
        #if canImport(MapKit)
        let annotations = cities.map { city in
            VisitedCityAnnotation(name: city.name, coordinate: CLLocationCoordinate2D(latitude: city.latitude, longitude: city.longitude))
        }

        Map {
            ForEach(annotations) { annotation in
                Marker(annotation.name, coordinate: annotation.coordinate)
            }
        }
        #else
        Text("MapKit unavailable on this platform")
        #endif
    }
}

public struct VisitedCityAnnotation: Identifiable, Hashable {
    public let id = UUID()
    public let name: String
    #if canImport(MapKit)
    public let coordinate: CLLocationCoordinate2D
    #endif

    #if canImport(MapKit)
    public init(name: String, coordinate: CLLocationCoordinate2D) {
        self.name = name
        self.coordinate = coordinate
    }
    #else
    public init(name: String) {
        self.name = name
    }
    #endif
}
#endif

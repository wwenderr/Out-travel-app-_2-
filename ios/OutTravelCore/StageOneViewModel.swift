import Foundation

public struct StageOneViewModel {
    public var store: OutTravelStore

    public init(store: OutTravelStore) {
        self.store = store
    }

    public var stats: TravelStats {
        store.stats
    }

    public var visitedCities: [City] {
        CityCatalogService.visitedCities(trips: store.trips, cities: store.cities)
    }

    public func filteredVisitedCities(query: String) -> [City] {
        CityCatalogService.filter(cities: visitedCities, query: query)
    }
}

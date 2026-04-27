import Foundation

public struct GuideCitySection: Identifiable, Hashable {
    public let city: City
    public let places: [Place]

    public var id: UUID { city.id }

    public init(city: City, places: [Place]) {
        self.city = city
        self.places = places
    }
}

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

    public var citiesSortedByName: [City] {
        store.cities.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    public var guideSections: [GuideCitySection] {
        let placesByCity = Dictionary(grouping: store.places, by: { $0.cityId })
        return citiesSortedByName.compactMap { city in
            guard let places = placesByCity[city.id], !places.isEmpty else { return nil }
            let sortedPlaces = places.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
            return GuideCitySection(city: city, places: sortedPlaces)
        }
    }

    @discardableResult
    public mutating func addTrip(_ input: NewTripInput) throws -> Trip {
        try store.addTrip(input)
    }

    @discardableResult
    public mutating func addPlace(_ input: NewPlaceInput) throws -> Place {
        try store.addPlace(input)
    }
}

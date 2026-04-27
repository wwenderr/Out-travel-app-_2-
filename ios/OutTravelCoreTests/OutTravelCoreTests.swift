import XCTest
@testable import OutTravelCore

final class OutTravelCoreTests: XCTestCase {
    func testAddTripUpdatesStats() throws {
        let country = Country(id: UUID(), name: "France", isoCode: "FR")
        let city = City(id: UUID(), name: "Paris", countryId: country.id, latitude: 48.8566, longitude: 2.3522)
        let store = OutTravelStore(countries: [country], cities: [city])

        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let end = Calendar.current.date(byAdding: .day, value: 3, to: start)!
        _ = try store.addTrip(NewTripInput(cityId: city.id, startDate: start, endDate: end))

        XCTAssertEqual(store.stats.totalTrips, 1)
        XCTAssertEqual(store.stats.uniqueCountries, 1)
        XCTAssertEqual(store.stats.uniqueCities, 1)
        XCTAssertEqual(store.stats.averageTripDurationDays, 3)
    }

    func testAddPlaceValidation() throws {
        let country = Country(id: UUID(), name: "Japan", isoCode: "JP")
        let city = City(id: UUID(), name: "Tokyo", countryId: country.id, latitude: 35.6764, longitude: 139.6500)
        let store = OutTravelStore(countries: [country], cities: [city])

        XCTAssertThrowsError(
            try store.addPlace(NewPlaceInput(
                cityId: city.id,
                title: "",
                description: "Great view",
                category: "Viewpoint",
                latitude: city.latitude,
                longitude: city.longitude
            ))
        ) { error in
            XCTAssertEqual(error as? OutTravelStoreError, .emptyPlaceTitle)
        }

        let place = try store.addPlace(NewPlaceInput(
            cityId: city.id,
            title: "Shibuya Sky",
            description: "Observation deck",
            category: "Viewpoint",
            latitude: city.latitude,
            longitude: city.longitude,
            rating: 5
        ))

        XCTAssertEqual(place.title, "Shibuya Sky")
        XCTAssertEqual(store.places.count, 1)
    }

    func testCityCatalogServiceFiltersVisitedCitiesAndSearch() {
        let country = Country(id: UUID(), name: "Spain", isoCode: "ES")
        let madrid = City(id: UUID(), name: "Madrid", countryId: country.id, latitude: 40.4168, longitude: -3.7038)
        let barcelona = City(id: UUID(), name: "Barcelona", countryId: country.id, latitude: 41.3874, longitude: 2.1686)
        let trip = Trip(id: UUID(), cityId: madrid.id, startDate: .now, endDate: .now)

        let visited = CityCatalogService.visitedCities(trips: [trip], cities: [barcelona, madrid])
        XCTAssertEqual(visited.map(\.name), ["Madrid"])

        let filtered = CityCatalogService.filter(cities: [madrid, barcelona], query: "bar")
        XCTAssertEqual(filtered.map(\.name), ["Barcelona"])
    }

    func testStageOneViewModelExposesVisitedCitiesAndStats() throws {
        let country = Country(id: UUID(), name: "Italy", isoCode: "IT")
        let rome = City(id: UUID(), name: "Rome", countryId: country.id, latitude: 41.9028, longitude: 12.4964)
        let store = OutTravelStore(countries: [country], cities: [rome])
        let start = Date(timeIntervalSince1970: 1_710_000_000)
        let end = Calendar.current.date(byAdding: .day, value: 2, to: start)!
        _ = try store.addTrip(NewTripInput(cityId: rome.id, startDate: start, endDate: end))

        let vm = StageOneViewModel(store: store)

        XCTAssertEqual(vm.stats.totalTrips, 1)
        XCTAssertEqual(vm.visitedCities.map(\.name), ["Rome"])
        XCTAssertEqual(vm.filteredVisitedCities(query: "ro").map(\.name), ["Rome"])
    }

    func testStageOneViewModelBuildsGuideSections() throws {
        let country = Country(id: UUID(), name: "Portugal", isoCode: "PT")
        let lisbon = City(id: UUID(), name: "Lisbon", countryId: country.id, latitude: 38.7223, longitude: -9.1393)
        let store = OutTravelStore(countries: [country], cities: [lisbon])
        var vm = StageOneViewModel(store: store)

        _ = try vm.addPlace(NewPlaceInput(
            cityId: lisbon.id,
            title: "Belem Tower",
            description: "Landmark",
            category: "Sight",
            latitude: lisbon.latitude,
            longitude: lisbon.longitude,
            rating: 5
        ))

        XCTAssertEqual(vm.guideSections.count, 1)
        XCTAssertEqual(vm.guideSections.first?.city.name, "Lisbon")
        XCTAssertEqual(vm.guideSections.first?.places.first?.title, "Belem Tower")
    }

    func testAppTabsAreDefinedForMVP() {
        XCTAssertEqual(AppTab.allCases, [.stats, .map, .cities, .guides])
    }
}

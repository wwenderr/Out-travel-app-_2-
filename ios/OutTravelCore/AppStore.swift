import Foundation

public enum AppTab: String, CaseIterable, Hashable {
    case stats
    case map
    case cities
    case guides
}

public struct NewTripInput: Hashable {
    public var cityId: UUID
    public var startDate: Date
    public var endDate: Date
    public var notes: String?

    public init(cityId: UUID, startDate: Date, endDate: Date, notes: String? = nil) {
        self.cityId = cityId
        self.startDate = startDate
        self.endDate = endDate
        self.notes = notes
    }
}

public struct NewPlaceInput: Hashable {
    public var cityId: UUID
    public var title: String
    public var description: String
    public var category: String
    public var latitude: Double
    public var longitude: Double
    public var photoURLs: [String]
    public var rating: Int?

    public init(
        cityId: UUID,
        title: String,
        description: String,
        category: String,
        latitude: Double,
        longitude: Double,
        photoURLs: [String] = [],
        rating: Int? = nil
    ) {
        self.cityId = cityId
        self.title = title
        self.description = description
        self.category = category
        self.latitude = latitude
        self.longitude = longitude
        self.photoURLs = photoURLs
        self.rating = rating
    }
}

public enum OutTravelStoreError: Error, Equatable {
    case cityNotFound
    case invalidTripDates
    case emptyPlaceTitle
    case invalidRating
}

public final class OutTravelStore {
    public private(set) var countries: [Country]
    public private(set) var cities: [City]
    public private(set) var trips: [Trip]
    public private(set) var places: [Place]

    public init(
        countries: [Country] = [],
        cities: [City] = [],
        trips: [Trip] = [],
        places: [Place] = []
    ) {
        self.countries = countries
        self.cities = cities
        self.trips = trips
        self.places = places
    }

    public var stats: TravelStats {
        StatsCalculator.buildStats(trips: trips, cities: cities)
    }

    @discardableResult
    public func addTrip(_ input: NewTripInput) throws -> Trip {
        guard cities.contains(where: { $0.id == input.cityId }) else {
            throw OutTravelStoreError.cityNotFound
        }
        guard input.endDate >= input.startDate else {
            throw OutTravelStoreError.invalidTripDates
        }

        let trip = Trip(
            id: UUID(),
            cityId: input.cityId,
            startDate: input.startDate,
            endDate: input.endDate,
            notes: input.notes
        )
        trips.append(trip)
        return trip
    }

    @discardableResult
    public func addPlace(_ input: NewPlaceInput) throws -> Place {
        guard cities.contains(where: { $0.id == input.cityId }) else {
            throw OutTravelStoreError.cityNotFound
        }
        guard !input.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw OutTravelStoreError.emptyPlaceTitle
        }
        if let rating = input.rating, !(1...5).contains(rating) {
            throw OutTravelStoreError.invalidRating
        }

        let place = Place(
            id: UUID(),
            cityId: input.cityId,
            title: input.title,
            description: input.description,
            category: input.category,
            latitude: input.latitude,
            longitude: input.longitude,
            photoURLs: input.photoURLs,
            rating: input.rating
        )
        places.append(place)
        return place
    }
}

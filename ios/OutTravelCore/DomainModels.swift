import Foundation

public struct Country: Identifiable, Hashable {
    public let id: UUID
    public var name: String
    public var isoCode: String

    public init(id: UUID, name: String, isoCode: String) {
        self.id = id
        self.name = name
        self.isoCode = isoCode
    }
}

public struct City: Identifiable, Hashable {
    public let id: UUID
    public var name: String
    public var countryId: UUID
    public var latitude: Double
    public var longitude: Double

    public init(id: UUID, name: String, countryId: UUID, latitude: Double, longitude: Double) {
        self.id = id
        self.name = name
        self.countryId = countryId
        self.latitude = latitude
        self.longitude = longitude
    }
}

public struct Trip: Identifiable, Hashable {
    public let id: UUID
    public var cityId: UUID
    public var startDate: Date
    public var endDate: Date
    public var notes: String?

    public init(id: UUID, cityId: UUID, startDate: Date, endDate: Date, notes: String? = nil) {
        self.id = id
        self.cityId = cityId
        self.startDate = startDate
        self.endDate = endDate
        self.notes = notes
    }

    public var durationDays: Int {
        let days = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
        return max(1, days)
    }
}

public struct Place: Identifiable, Hashable {
    public let id: UUID
    public var cityId: UUID
    public var title: String
    public var description: String
    public var category: String
    public var latitude: Double
    public var longitude: Double
    public var photoURLs: [String]
    public var rating: Int?

    public init(
        id: UUID,
        cityId: UUID,
        title: String,
        description: String,
        category: String,
        latitude: Double,
        longitude: Double,
        photoURLs: [String] = [],
        rating: Int? = nil
    ) {
        self.id = id
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

public struct TravelStats: Hashable {
    public var totalTrips: Int
    public var uniqueCountries: Int
    public var uniqueCities: Int
    public var averageTripDurationDays: Double

    public init(totalTrips: Int, uniqueCountries: Int, uniqueCities: Int, averageTripDurationDays: Double) {
        self.totalTrips = totalTrips
        self.uniqueCountries = uniqueCountries
        self.uniqueCities = uniqueCities
        self.averageTripDurationDays = averageTripDurationDays
    }
}

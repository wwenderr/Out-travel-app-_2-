import Foundation

public enum StatsCalculator {
    public static func buildStats(trips: [Trip], cities: [City]) -> TravelStats {
        let cityById = Dictionary(uniqueKeysWithValues: cities.map { ($0.id, $0) })
        let countryIdsVisited: Set<UUID> = Set(trips.compactMap { trip in
            guard let city = cityById[trip.cityId] else { return nil }
            return city.countryId
        })

        let uniqueCitiesVisited = Set(trips.map(\.cityId)).count
        let avgDuration = trips.isEmpty
            ? 0
            : Double(trips.map(\.durationDays).reduce(0, +)) / Double(trips.count)

        return TravelStats(
            totalTrips: trips.count,
            uniqueCountries: countryIdsVisited.count,
            uniqueCities: uniqueCitiesVisited,
            averageTripDurationDays: avgDuration
        )
    }
}

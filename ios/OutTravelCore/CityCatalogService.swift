import Foundation

public enum CityCatalogService {
    public static func visitedCities(trips: [Trip], cities: [City]) -> [City] {
        let visitedIds = Set(trips.map(\.cityId))
        return cities
            .filter { visitedIds.contains($0.id) }
            .sorted { lhs, rhs in
                lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
            }
    }

    public static func filter(cities: [City], query: String) -> [City] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return cities }

        return cities.filter { city in
            city.name.localizedCaseInsensitiveContains(trimmed)
        }
    }
}

#if canImport(SwiftUI)
import SwiftUI

public struct OutTravelAppShell: View {
    private let viewModel: StageOneViewModel

    public init() {
        let france = Country(id: UUID(), name: "France", isoCode: "FR")
        let japan = Country(id: UUID(), name: "Japan", isoCode: "JP")

        let paris = City(id: UUID(), name: "Paris", countryId: france.id, latitude: 48.8566, longitude: 2.3522)
        let tokyo = City(id: UUID(), name: "Tokyo", countryId: japan.id, latitude: 35.6764, longitude: 139.6500)

        let firstStart = Date(timeIntervalSince1970: 1_700_000_000)
        let firstEnd = Calendar.current.date(byAdding: .day, value: 4, to: firstStart) ?? firstStart
        let secondStart = Date(timeIntervalSince1970: 1_710_000_000)
        let secondEnd = Calendar.current.date(byAdding: .day, value: 6, to: secondStart) ?? secondStart

        let trips = [
            Trip(id: UUID(), cityId: paris.id, startDate: firstStart, endDate: firstEnd),
            Trip(id: UUID(), cityId: tokyo.id, startDate: secondStart, endDate: secondEnd)
        ]

        let places = [
            Place(id: UUID(), cityId: paris.id, title: "Louvre", description: "Главный музей города", category: "Museum", latitude: paris.latitude, longitude: paris.longitude),
            Place(id: UUID(), cityId: tokyo.id, title: "Senso-ji", description: "Исторический храм", category: "Temple", latitude: tokyo.latitude, longitude: tokyo.longitude)
        ]

        let store = OutTravelStore(countries: [france, japan], cities: [paris, tokyo], trips: trips, places: places)
        self.viewModel = StageOneViewModel(store: store)
    }

    public var body: some View {
        StageOneRootView(viewModel: viewModel)
    }
}
#endif

#if canImport(SwiftUI)
import SwiftUI

public struct OutTravelAppShell: View {
    private let viewModel: StageOneViewModel

    public init() {
        let country = Country(id: UUID(), name: "France", isoCode: "FR")
        let paris = City(id: UUID(), name: "Paris", countryId: country.id, latitude: 48.8566, longitude: 2.3522)
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let end = Calendar.current.date(byAdding: .day, value: 4, to: start) ?? start
        let trip = Trip(id: UUID(), cityId: paris.id, startDate: start, endDate: end)
        let store = OutTravelStore(countries: [country], cities: [paris], trips: [trip])
        self.viewModel = StageOneViewModel(store: store)
    }

    public var body: some View {
        StageOneRootView(viewModel: viewModel)
    }
}
#endif

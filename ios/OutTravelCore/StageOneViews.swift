#if canImport(SwiftUI)
import SwiftUI
#if canImport(MapKit)
import MapKit
#endif
#if canImport(PhotosUI)
import PhotosUI
#endif

public struct StageOneRootView: View {
    @State private var selectedTab: AppTab = .stats
    @State private var cityQuery: String = ""
    @State private var showAddTrip = false
    @State private var showAddPlace = false
    @State private var selectedPlaceForPhotos: Place?
    @State private var errorMessage: String?
    @State private var viewModel: StageOneViewModel

    public init(viewModel: StageOneViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                StatsScreen(stats: viewModel.stats)
            }
            .tabItem { Label("Stats", systemImage: "chart.bar") }
            .tag(AppTab.stats)

            NavigationStack {
                VisitedMapScreen(cities: viewModel.visitedCities)
            }
            .tabItem { Label("Map", systemImage: "map") }
            .tag(AppTab.map)

            NavigationStack {
                CityCatalogScreen(cities: viewModel.filteredVisitedCities(query: cityQuery), searchText: $cityQuery)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                showAddTrip = true
                            } label: {
                                Label("Add trip", systemImage: "plus")
                            }
                        }
                    }
            }
            .tabItem { Label("Cities", systemImage: "building.2") }
            .tag(AppTab.cities)

            NavigationStack {
                GuidesScreen(sections: viewModel.guideSections) { place in
                    selectedPlaceForPhotos = place
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showAddPlace = true
                        } label: {
                            Label("Add place", systemImage: "plus")
                        }
                    }
                }
            }
            .tabItem { Label("Guides", systemImage: "book") }
            .tag(AppTab.guides)
        }
        .sheet(isPresented: $showAddTrip) {
            AddTripSheet(cities: viewModel.citiesSortedByName) { input in
                do {
                    _ = try viewModel.addTrip(input)
                } catch {
                    errorMessage = "Не удалось добавить поездку: \(error.localizedDescription)"
                }
            }
        }
        .sheet(isPresented: $showAddPlace) {
            AddPlaceSheet(cities: viewModel.citiesSortedByName) { input in
                do {
                    _ = try viewModel.addPlace(input)
                } catch {
                    errorMessage = "Не удалось добавить место: \(error.localizedDescription)"
                }
            }
        }
        .sheet(item: $selectedPlaceForPhotos) { place in
            ManagePlacePhotosSheet(place: place,
                                   onAdd: { url in
                do {
                    _ = try viewModel.attachPhotoURL(url, toPlace: place.id)
                    selectedPlaceForPhotos = viewModel.store.places.first(where: { $0.id == place.id })
                } catch {
                    errorMessage = "Не удалось добавить фото: \(error.localizedDescription)"
                }
            },
                                   onRemove: { url in
                do {
                    _ = try viewModel.detachPhotoURL(url, fromPlace: place.id)
                    selectedPlaceForPhotos = viewModel.store.places.first(where: { $0.id == place.id })
                } catch {
                    errorMessage = "Не удалось удалить фото: \(error.localizedDescription)"
                }
            })
        }
        .alert("Ошибка", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
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
        List(cities) { city in
            VStack(alignment: .leading, spacing: 6) {
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

public struct GuidesScreen: View {
    private let sections: [GuideCitySection]
    private let onManagePhotos: (Place) -> Void

    public init(sections: [GuideCitySection], onManagePhotos: @escaping (Place) -> Void) {
        self.sections = sections
        self.onManagePhotos = onManagePhotos
    }

    public var body: some View {
        List {
            if sections.isEmpty {
                Text("Пока нет мест. Добавьте первое место в ваш гайд.")
                    .foregroundStyle(.secondary)
            }
            ForEach(sections) { section in
                Section(section.city.name) {
                    ForEach(section.places) { place in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(place.title)
                                .font(.headline)
                            Text(place.description)
                                .font(.subheadline)
                            HStack {
                                Text(place.category)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Label("\(place.photoURLs.count)", systemImage: "photo")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Button("Управлять фото") {
                                onManagePhotos(place)
                            }
                            .buttonStyle(.borderless)
                            .font(.caption)
                        }
                    }
                }
            }
        }
        .navigationTitle("Guides")
    }
}

public struct VisitedMapScreen: View {
    private let cities: [City]

    public init(cities: [City]) {
        self.cities = cities
    }

    public var body: some View {
        #if canImport(MapKit)
        let annotations = cities.map {
            VisitedCityAnnotation(name: $0.name, coordinate: CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude))
        }

        Map {
            ForEach(annotations) { annotation in
                Marker(annotation.name, coordinate: annotation.coordinate)
            }
        }
        .navigationTitle("Visited map")
        #else
        Text("MapKit unavailable on this platform")
        #endif
    }
}

public struct AddTripSheet: View {
    private let cities: [City]
    private let onSave: (NewTripInput) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedCityId: UUID?
    @State private var startDate: Date = .now
    @State private var endDate: Date = .now
    @State private var notes: String = ""

    public init(cities: [City], onSave: @escaping (NewTripInput) -> Void) {
        self.cities = cities
        self.onSave = onSave
    }

    public var body: some View {
        NavigationStack {
            Form {
                Picker("City", selection: $selectedCityId) {
                    ForEach(cities) { city in
                        Text(city.name).tag(Optional(city.id))
                    }
                }
                DatePicker("Start", selection: $startDate, displayedComponents: .date)
                DatePicker("End", selection: $endDate, displayedComponents: .date)
                TextField("Notes", text: $notes, axis: .vertical)
            }
            .navigationTitle("New trip")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard let cityId = selectedCityId else { return }
                        onSave(NewTripInput(cityId: cityId, startDate: startDate, endDate: endDate, notes: notes.isEmpty ? nil : notes))
                        dismiss()
                    }
                    .disabled(selectedCityId == nil)
                }
            }
        }
    }
}

public struct AddPlaceSheet: View {
    private let cities: [City]
    private let onSave: (NewPlaceInput) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedCityId: UUID?
    @State private var title = ""
    @State private var details = ""
    @State private var category = "Sight"
    @State private var rating = 5
    @State private var photoURLsText = ""

    public init(cities: [City], onSave: @escaping (NewPlaceInput) -> Void) {
        self.cities = cities
        self.onSave = onSave
    }

    public var body: some View {
        NavigationStack {
            Form {
                Picker("City", selection: $selectedCityId) {
                    ForEach(cities) { city in
                        Text(city.name).tag(Optional(city.id))
                    }
                }
                TextField("Title", text: $title)
                TextField("Description", text: $details, axis: .vertical)
                TextField("Category", text: $category)
                Stepper("Rating: \(rating)", value: $rating, in: 1...5)
                TextField("Photo URLs (comma separated)", text: $photoURLsText, axis: .vertical)
            }
            .navigationTitle("New place")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard let cityId = selectedCityId,
                              let city = cities.first(where: { $0.id == cityId }) else { return }

                        let photoURLs = photoURLsText
                            .split(separator: ",")
                            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                            .filter { !$0.isEmpty }

                        onSave(NewPlaceInput(
                            cityId: cityId,
                            title: title,
                            description: details,
                            category: category,
                            latitude: city.latitude,
                            longitude: city.longitude,
                            photoURLs: photoURLs,
                            rating: rating
                        ))
                        dismiss()
                    }
                    .disabled(selectedCityId == nil || title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

public struct ManagePlacePhotosSheet: View {
    private let place: Place
    private let onAdd: (String) -> Void
    private let onRemove: (String) -> Void
    private let photoLibrary = PhotoLibraryService(baseDirectory: FileManager.default.temporaryDirectory.appendingPathComponent("outtravel_photos"))

    @Environment(\.dismiss) private var dismiss
    @State private var urlInput = ""
    #if canImport(PhotosUI)
    @State private var pickerItems: [PhotosPickerItem] = []
    #endif

    public init(place: Place, onAdd: @escaping (String) -> Void, onRemove: @escaping (String) -> Void) {
        self.place = place
        self.onAdd = onAdd
        self.onRemove = onRemove
    }

    public var body: some View {
        NavigationStack {
            List {
                Section("Текущие фото") {
                    if place.photoURLs.isEmpty {
                        Text("Фото пока нет")
                            .foregroundStyle(.secondary)
                    }
                    ForEach(place.photoURLs, id: \.self) { url in
                        HStack {
                            Text(url)
                                .lineLimit(1)
                                .font(.caption)
                            Spacer()
                            Button(role: .destructive) {
                                onRemove(url)
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                    }
                }

                Section("Добавить URL") {
                    TextField("https://...", text: $urlInput)
                    Button("Добавить фото по URL") {
                        onAdd(urlInput)
                        urlInput = ""
                    }
                    .disabled(urlInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                #if canImport(PhotosUI)
                Section("Импорт из галереи") {
                    PhotosPicker("Выбрать изображения", selection: $pickerItems, maxSelectionCount: 10, matching: .images)
                }
                #endif
            }
            .navigationTitle(place.title)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            #if canImport(PhotosUI)
            .onChange(of: pickerItems) { items in
                Task {
                    for item in items {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let url = try? photoLibrary.savePhoto(data: data, suggestedExtension: "jpg") {
                            onAdd(url)
                        }
                    }
                    pickerItems = []
                }
            }
            #endif
        }
    }
}

public struct VisitedCityAnnotation: Identifiable, Hashable {
    public let id = UUID()
    public let name: String
    public let latitude: Double
    public let longitude: Double

    #if canImport(MapKit)
    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    #endif

    #if canImport(MapKit)
    public init(name: String, coordinate: CLLocationCoordinate2D) {
        self.name = name
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
    #endif

    public init(name: String, latitude: Double, longitude: Double) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
}
#endif

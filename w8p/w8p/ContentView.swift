
import SwiftUI
import CoreLocation

// MARK: - Task 2: Base Class

class CampusPlace {
    let name: String

    init(name: String) {
        self.name = name
    }

    func visitMessage() -> String {
        "Visiting \(name)"
    }
}

// MARK: - Task 3: Subclasses

class Classroom: CampusPlace {
    override func visitMessage() -> String {
        "Attend a lesson at \(name)"
    }
}

class Library: CampusPlace {
    override func visitMessage() -> String {
        "Read books at \(name)"
    }
}

class Laboratory: CampusPlace {
    override func visitMessage() -> String {
        "Conduct an experiment at \(name)"
    }
}

class Cafeteria: CampusPlace {
    override func visitMessage() -> String {
        "Enjoy a meal at \(name)"
    }
}

class ComputerRoom: CampusPlace {
    override func visitMessage() -> String {
        "Practice programming at \(name)"
    }
}

// MARK: - Task 4: Runtime Polymorphism

func getCampusMessages() -> [String] {
    let places: [CampusPlace] = [
        Classroom(name: "Room A101"),
        Library(name: "Central Library"),
        Laboratory(name: "Physics Lab"),
        Cafeteria(name: "Campus Cafeteria"),
        ComputerRoom(name: "Computer Room")
    ]

    return places.map { $0.visitMessage() }
}

// MARK: - Task 5: Coordinate and Protocol

struct Coordinate {
    let latitude: Double
    let longitude: Double
}

protocol LocationProvider {
    func currentLocation() -> Coordinate?
}

// MARK: - Location Providers

class MockLocationProvider: LocationProvider {
    func currentLocation() -> Coordinate? {
        Coordinate(latitude: 10.8705, longitude: 106.8039)
    }
}

class UnavailableLocationProvider: LocationProvider {
    func currentLocation() -> Coordinate? {
        nil
    }
}

class TestLocationProvider: LocationProvider {
    func currentLocation() -> Coordinate? {
        Coordinate(latitude: 21.0285, longitude: 105.8542)
    }
}

// MARK: - Location Controller

class LocationController {
    private let provider: any LocationProvider

    init(provider: any LocationProvider) {
        self.provider = provider
    }

    func showLocation() -> String {
        guard let location = provider.currentLocation() else {
            return "Location unavailable"
        }

        return "Lat: \(location.latitude), Lon: \(location.longitude)"
    }
}

// MARK: - Task 6: CoreLocation Provider

class CoreLocationProvider: NSObject, LocationProvider, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var latestLocation: Coordinate?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func currentLocation() -> Coordinate? {
        manager.requestLocation()
        return latestLocation
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.last,
              location.horizontalAccuracy >= 0 else {
            return
        }

        latestLocation = Coordinate(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        latestLocation = nil
    }
}

// MARK: - ContentView

struct ContentView: View {
    @State private var messages = getCampusMessages()
    @State private var locationMessage = "Choose a location provider"

    var body: some View {
        NavigationStack {
            List {
                Section("Task 2–4: Campus Places") {
                    ForEach(messages.indices, id: \.self) { index in
                        Text(messages[index])
                    }
                }

                Section("Task 5: Location Providers") {
                    Button("Mock Location") {
                        let controller = LocationController(
                            provider: MockLocationProvider()
                        )
                        locationMessage = controller.showLocation()
                    }

                    Button("Unavailable Location") {
                        let controller = LocationController(
                            provider: UnavailableLocationProvider()
                        )
                        locationMessage = controller.showLocation()
                    }

                    Button("Test Location") {
                        let controller = LocationController(
                            provider: TestLocationProvider()
                        )
                        locationMessage = controller.showLocation()
                    }

                    Text(locationMessage)
                        .textSelection(.enabled)
                }
            }
            .navigationTitle("Campus Places")
        }
    }
}


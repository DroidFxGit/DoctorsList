# DoctorsList - iOS Code Challenge

A SwiftUI app that displays a list of doctors with their details.

## Requirements

- **iOS**: 18.0+
- **Xcode**: 26.2+

## Setup & Run

1. Clone the repository
2. Open `DoctorsList.xcodeproj`
3. Press `Cmd + R` to run

No additional setup needed - the app uses only native iOS frameworks.

---

## Architecture: MVVM

This project uses the **Model-View-ViewModel** pattern.

### Why MVVM?

- **Testability**: ViewModels can be unit tested without UI dependencies
- **Separation of Concerns**: Business logic is separated from UI
- **SwiftUI Integration**: `@Published` properties and `ObservableObject` work naturally with SwiftUI
- **Protocol-Oriented Design**: Dependencies are injected via protocols, making mocking easy

### Architecture Flow

```
Views (SwiftUI)
    ↓
ViewModels (@MainActor, @Published)
    ↓
Services (Business Logic)
    ↓
Networking (APIClient)
    ↓
Models (Codable)
```

---

## Networking Approach

### Async/Await

The app uses Swift's modern concurrency:

- **Cleaner code**: No callback hell or completion handlers
- **Better error handling**: Native `try-catch` with typed errors
- **Main actor safety**: `@MainActor` on ViewModels ensures UI updates on main thread
- **Structured concurrency**: Tasks auto-cancel when views disappear

### Codable

JSON parsing is handled with Swift's `Codable`:

- **Type-safe**: Compile-time checking of models
- **Custom decoding**: Graceful handling of missing values with `decodeIfPresent`
- **Snake case mapping**: `CodingKeys` converts API's `snake_case` to Swift's `camelCase`

Example:
```swift
enum CodingKeys: String, CodingKey {
    case firstName = "first_name"
    case acceptingNewPatients = "accepting_new_patients"
}

init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    firstName = try container.decodeIfPresent(String.self, forKey: .firstName) ?? ""
}
```

---

## Project Structure

```
DoctorsList/
├── App/                    # Entry point & dependency injection
├── Models/                 # Codable data models
├── Views/                  # SwiftUI views
├── ViewModels/             # State management & presentation logic
├── Services/               # Business logic layer
├── Networking/             # APIClient, endpoints, errors
└── Utilities/              # Constants

DoctorsListTests/
├── ViewModels/             # ViewModel unit tests
└── Mocks/                  # Mock services for testing
```

---

## Testing Strategy

The app includes comprehensive **unit tests** for ViewModels:

### What's Tested

- ✅ Loading states (loading, success, error, empty)
- ✅ State transitions during async operations
- ✅ Error handling (network, decoding, invalid responses)
- ✅ Retry and refresh functionality
- ✅ Mock services with configurable delays

### Testing Approach

- **Protocol-based mocks**: All services have protocol definitions for easy mocking
- **Async testing**: Tests use `async/await` and `@MainActor`
- **State verification**: Tests verify `@Published` property changes

Run tests: `Cmd + U` or `xcodebuild test -scheme DoctorsList`

---

## Third-Party Libraries

**None** - This project uses only native iOS frameworks.

### Why?

For a code challenge, native frameworks provide everything needed:
- **SwiftUI**: Modern UI
- **URLSession**: Networking with async/await
- **Combine**: Reactive updates via `@Published`
- **Codable**: JSON parsing
- **XCTest**: Unit testing

Benefits: Smaller binary, faster builds, no dependency management.

# BitcoinRateDemo

A native iOS app that tracks the Bitcoin price in real time and displays its 14-day EUR price history, built as a clean-architecture showcase in Swift.

---

## Table of Contents

- [Getting Started](#getting-started)
- [Architecture](#architecture)
- [Approach](#approach)
- [Design Decisions & Trade-offs](#design-decisions--trade-offs)
- [API](#api)
- [Testing](#testing)

---

## Getting Started

### Add your CoinGecko API key

The real API key is never committed. A template is provided to guide the one-time setup:

Open `Secret.xcconfig` and replace the placeholder:

```
COINGECKO_API_KEY = <YOUR_COINGECKO_API_KEY>
```

The key is injected into `Info.plist` at build time and read at runtime via `AppConfiguration`. If the key is missing or empty the app calls `fatalError` immediately so the misconfiguration is impossible to ignore during development.

---

## Architecture

The project follows **Clean Architecture** with three distinct layers enforced through protocol boundaries, so every dependency is injectable and mockable.

```
Presentation  ──►  Domain  ◄──  Data
  (SwiftUI)     (pure Swift)   (URLSession / DTOs)
```

| Layer | Allowed imports | Responsibilities |
|---|---|---|
| **Domain** | none | Entities, use-case protocols, repository protocol |
| **Data** | Foundation | Networking, JSON decoding, DTO → Entity mapping |
| **Presentation** | SwiftUI, Combine | View models, views, navigation coordinator |

---

## Approach

The build followed a **UI-first, mocks-first** strategy: get the views and view models working against fake data immediately, then layer in real infrastructure underneath without touching the presentation code.

1. **Scaffold UI with mock use cases.** `CryptoHistoryItemsView`, `CryptoHistoryView`, `LivePriceCardView`, and their view models were built first against hand-written mock use cases. This let the UI take shape and be tested in Xcode Previews before any real networking existed. View model tests (`CryptoHistoryItemsViewModelTests`) were added at the same time as the view models.

2. **Build NetworkingKit as a standalone layer.** `DefaultNetworkClient`, `APIRequest`, `HTTPClient`, `RequestAuthorizer`, and `ResponseValidator` were added as a self-contained networking module with no knowledge of CoinGecko or any domain type. `NetworkCryptoPriceRepositoryTests` and `CoinPriceDTOTests` were written alongside this layer.

3. **Implement the real repository and use cases.** `NetworkCryptoPriceRepository` was wired to `DefaultNetworkClient`, `DefaultCryptoCurrentPriceUseCase` and `DefaultCryptoPriceHistoryUseCase` were added, and the mock use cases were replaced with the real implementations — all without changing a single line of view or view model code.

4. **Add secrets, config, and error handling.** `Secret.xcconfig`, `AppConfiguration`, and `AppConstants` were added to handle the API key and environment configuration cleanly. `ErrorView` was introduced as a shared error presentation component.

5. **Introduce navigation and the details screen.** `AppCoordinator`, `DependencyContainer`, `RootView`, and `CryptoPriceDetailsUseCase` were added together to wire up the navigation stack and the details flow. The details screen reused the existing `DefaultNetworkClient` infrastructure via a new use case.

6. **Expand test coverage and polish.** `DefaultNetworkClientTests`, additional repository tests, `DefaultLivePriceDetailsUseCase`, and coordinator tests were added. A series of cleanup commits followed — renaming `PricePoint` to `CryptoPrice`, fixing a bug where the API was called on every back-navigation, extracting UI constants to enums, unifying view creation style, and moving view model instantiation into `DependencyContainer`.

---

## Design Decisions & Trade-offs

### 1. Clean Architecture with strict layer boundaries

The codebase is split into Domain, Data, and Presentation layers. Each layer only depends on the one below it through **protocols**, never through concrete types.

- Domain is pure Swift with zero framework imports.
- Data imports `Foundation` for networking and JSON decoding, but nothing from SwiftUI or Combine.
- Presentation imports SwiftUI and Combine, but only ever calls into Domain protocols.

**Trade-off:** Three layers adds boilerplate (protocol + default implementation + mock for each use case). The project accepts this cost because a complete networking stack swap (e.g. replacing `URLSession` with a third-party HTTP library) would touch exactly one file — `NetworkCryptoPriceRepository` — without any change to view models or use cases.

---

### 2. Protocol-per-use-case instead of a single service interface

Each operation has its own protocol (`CryptoCurrentPriceUseCase`, `CryptoLivePriceDetailsUseCase`, `CryptoPriceHistoryUseCase`, `CryptoPriceDetailsUseCase`) rather than grouping all operations into one large service protocol.

**Why:** View models declare only the capability they actually need. `CryptoHistoryItemsViewModel` injects `CryptoPriceHistoryUseCase` and nothing else. This keeps the dependency surface minimal, reduces the scope of test mocks to a single method, and makes the separation of concerns explicit in every constructor signature.

**Trade-off:** More protocol declarations. For a larger team this could be partially addressed with a code-generation step; for a project at this scale it is an acceptable cost in exchange for fine-grained testability and independent replaceability of any single operation.

---

### 3. `CryptoDetailsViewModel` accepts a closure loader, not a use-case protocol

`CryptoDetailsViewModel` is initialised with `loader: () async throws -> CryptoDetails` rather than being injected with a specific use-case protocol.

**Why:** The details screen is reused for two different data sources — historical point-in-time data (`CryptoPriceDetailsUseCase`) and live details (`CryptoLivePriceDetailsUseCase`). Rather than adding a second protocol or a polymorphic wrapper, the `DependencyContainer` partially applies the correct use case at the call site and passes in the resulting closure. The view model stays completely unaware of which source is in use.

**Trade-off:** The closure approach is slightly less self-documenting at the declaration site than an explicit protocol injection. This is offset by the view model being simpler and the test setup being a plain `{ return mockDetails }` lambda with no mock object required.

---

### 4. `LivePriceCardViewModel` owns a dedicated `.stale` state

The live price card exposes four states: `.loading`, `.loaded`, `.stale`, and `.failure`. When a background refresh fails but a previously successful value is available, the view model transitions to `.stale(lastKnownPrice)` rather than `.failure`.

**Why:** Showing the last known price with a visual indicator is a better user experience than replacing valid data with an error message just because one timed refresh failed.

**Trade-off:** The view must handle an extra state case. The added complexity is confined to one view and one view model; the rest of the app uses the simpler three-case `ViewState<T>` generic.

---

### 5. Auto-refresh implemented as a looping `Task`, not a `Timer` publisher

The live price refresh is a single `Task` that calls `refresh`, then sleeps with `Task.sleep`, then loops — instead of a Combine `Timer.publish` pipeline.

**Why:** A looping `Task` is cancelled automatically when the view model is deallocated (the task is stored as a property and cancelled in `deinit` implicitly via ARC). It plays naturally with `async/await` use cases and avoids bridging between Combine and structured concurrency. The refresh interval is injected as a `TimeInterval` parameter, making tests instantaneous without needing `Scheduler` abstractions.

**Trade-off:** The timer behaviour is less composable than a Combine pipeline, which could matter if several downstream operators needed to react to each tick. For this use case — fetch, update state, wait, repeat — the `Task` loop is more readable and has fewer moving parts.

---

### 6. Navigation via a lightweight `AppCoordinator` wrapping `NavigationStack`

`AppCoordinator` is an `ObservableObject` that holds a single `@Published var activeRoute: AppRoute?`. The root view binds a `NavigationStack` path to this value. Navigation is triggered by calling `coordinator.navigate(to:)`.

**Why:** This keeps all navigation logic out of views and view models while avoiding a heavyweight coordinator hierarchy (no base classes, no child coordinators, no router protocols). View models receive navigation as a plain callback closure (`onSelection: (CryptoPrice) -> Void`) injected by `DependencyContainer`, so they never import UIKit/SwiftUI or hold a reference to the coordinator.

**Trade-off:** A single `activeRoute` can only represent one active pushed destination. For deep navigation stacks or tab-based navigation this approach would need to evolve (e.g. an array-based `NavigationPath`). For the current two-level hierarchy it is the simplest correct solution.

---

### 7. Dependency injection through SwiftUI `Environment`, not a singleton

`DependencyContainer` is constructed once at app startup in `BitcoinRateDemoApp` and propagated through the SwiftUI environment (`@EnvironmentObject`), rather than using a global singleton or passing each dependency through `init` parameters at every view level.

**Why:** Environment objects are implicitly available to any view in the hierarchy without threading them through every intermediate view. Compared to a singleton, the container is still replaceable in tests and Previews by injecting a different instance.

**Trade-off:** Any view that reads `@EnvironmentObject var container: DependencyContainer` will crash at runtime if the object was not injected — a programming error that is not caught at compile time. This is a known trade-off of the environment pattern. It is mitigated here because the single injection site is at the app's root and Previews explicitly inject mock instances.

---

### 8. API key managed via `.xcconfig`, not hardcoded or stored in a secrets file

The CoinGecko API key lives in `Secret.xcconfig` (git-ignored), is referenced in `Info.plist` as `$(COINGECKO_API_KEY)`, and is read at runtime via `Bundle.main.infoDictionary`. `AppConfiguration` calls `fatalError` if the key is absent.

**Why:** This avoids committing the key to source control while keeping the build fully reproducible for anyone who provides their own key. The `fatalError` on missing key gives a clear signal during development rather than a silent empty-string request that fails at the network layer.

**Trade-off:** The key is visible in the compiled binary and in the running process's memory — standard for client apps that call public APIs. For higher-security requirements a backend proxy that holds the key server-side would be the next step.

---

### 9. Swift Testing instead of XCTest

All unit tests use Apple's [Swift Testing](https://developer.apple.com/documentation/testing/) framework (`import Testing`, `@Suite`, `@Test`, `#expect`, `#require`) rather than `XCTestCase`.

**Why:** Swift Testing has cleaner syntax for parameterised tests, more informative failure messages from `#expect`, and better integration with Swift Concurrency (`async` test functions work without `XCTestExpectation`). It is the direction Apple is investing in for future test infrastructure.

**Trade-off:** Swift Testing requires iOS 16+ / Xcode 16+. Teams targeting older toolchains or CI environments that have not upgraded would need to remain on XCTest.

---

## API

All data comes from the [CoinGecko REST API v3](https://docs.coingecko.com/reference/introduction) (free Demo tier).

| Endpoint | Used by |
|---|---|
| `GET /simple/price` | Live price card + live details screen |
| `GET /coins/{id}/market_chart` | 14-day price history |
| `GET /coins/{id}/history` | Historical detail for a specific date |

The API key is sent as the `x-cg-demo-api-key` request header, injected by `APIKeyAuthorizer` which conforms to the `RequestAuthorizer` protocol. Swapping authentication schemes (e.g. Bearer token) means writing a new `RequestAuthorizer` conformance without changing `DefaultNetworkClient`.

---

## Testing

The test target mirrors the main target's folder structure. Coverage spans all three layers:

| Area | What is tested |
|---|---|
| `DefaultNetworkClient` | URL construction, authorizer application, validation delegation, decoding |
| `StatusCodeValidator` | Accepted and rejected HTTP status codes |
| `APIKeyAuthorizer` | Header injection |
| `NetworkCryptoPriceRepository` | DTO → entity mapping for all three endpoints |
| Use cases | Business logic in each `Default*UseCase` via `MockCryptoPriceRepository` |
| `LivePriceCardViewModel` | State transitions for initial load, timer refresh, stale data, and manual retry |
| `CryptoHistoryItemsViewModel` | Loading, idempotent `loadIfNeeded`, and failure states |
| `CryptoDetailsViewModel` | Loaded and failure states via closure injection |
| `AppCoordinator` | `navigate(to:)` and `pop()` route transitions |
| `AppConfiguration` | Key presence validation |
| `AppConstants` | Constant value assertions |

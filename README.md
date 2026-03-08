# BitcoinTest

A native iOS app that tracks the Bitcoin price in real time and displays its 14-day EUR price history, built as a clean-architecture showcase in Swift.

---
## Architecture

The project follows **Clean Architecture** with three distinct layers, enforced through protocol boundaries so every dependency is injectable and mockable.

---

## Getting Started

### Add your CoinGecko API key

The real API key is never committed. A template is provided to guide the one-time setup:

Open `Secret.xcconfig` and replace the placeholder:

```
COINGECKO_API_KEY = <YOUR_COINGECKO_API_KEY>
```
---

## API

All data comes from the [CoinGecko REST API v3](https://docs.coingecko.com/reference/introduction) (free Demo tier).

| Endpoint | Used by |
|---|---|
| `GET /simple/price` | Live price card + live details screen |
| `GET /coins/{id}/market_chart` | 14-day price history |
| `GET /coins/{id}/history` | Historical detail for a specific date |

The API key is sent as the `x-cg-demo-api-key` request header by `APIKeyAuthorizer`.

---

## Design Decisions

### 1. Clean Architecture with strict layer boundaries

The codebase is split into three layers — Domain, Data, Presentation — and each layer only depends on the one below it through **protocols**, never through concrete types.

- The Domain layer is pure Swift with zero framework imports. It defines entities, use-case protocols, and the repository protocol.
- The Data layer imports `Foundation` for networking and JSON decoding, but nothing from SwiftUI or Combine.
- The Presentation layer imports SwiftUI and Combine, but only ever calls into Domain protocols.

This means a complete networking stack swap (e.g. replacing `URLSession` with a third-party HTTP library) would touch exactly one file — `NetworkCryptoPriceRepository` — without any change to view models or use cases.

---

### 2. Protocol-per-use-case instead of a single service interface

Each use case has its own protocol (`CryptoCurrentPriceUseCase`, `CryptoLivePriceDetailsUseCase`, etc.) rather than grouping all operations into a single service protocol.

**Why:** View models declare only the capability they actually need. `CryptoHistoryItemsViewModel` injects `CryptoPriceHistoryUseCase` and nothing else. This keeps the dependency surface minimal, reduces the scope of test mocks to a single method, and makes the separation of concerns explicit in every constructor signature.

**Trade-off:** More protocol declarations. The project accepts this cost in exchange for fine-grained testability and the ability to independently replace any single operation.

---

### 3. `LivePriceCardViewModel` manages its own refresh loop with Swift Concurrency

The auto-refresh is implemented as a single `Task` that loops indefinitely, sleeping with `Task.sleep` between refreshes.

---

### 4. Dependency injection through SwiftUI `Environment`

`DependencyContainer` is constructed once at app startup and propagated through the SwiftUI environment object, rather than using a singleton or passing it through `init` parameters at every level.

---

### 5. Swift Testing instead of XCTest

All unit tests use Apple's [Swift Testing](https://developer.apple.com/documentation/testing/) framework (`import Testing`, `@Suite`, `@Test`, `#expect`, `#require`) rather than `XCTestCase`.

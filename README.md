# FXTM Forex Tracker App

## Overview

The FXTM Forex Tracker App is designed to display real-time forex prices for selected currency pairs. When a user taps on a currency pair, they are navigated to a detail page showing historical price data with an interactive graph.

---

## Getting Started

### Prerequisites

- **Flutter SDK:** Ensure you have Flutter installed on your machine. [Install Flutter](https://flutter.dev/docs/get-started/install)
- **Finnhub API Key:** Sign up for a free API key from [Finnhub](https://finnhub.io/).

### Setup Instructions

1. **Clone the Repository**

   ```bash
   git clone https://github.com/engineerdeep/fxtm-app-assessment.git
   ```

2. **Navigate to the Project Directory**

   ```bash
   cd fxtm_forex_tracker
   ```

3. **Install Dependencies**

   ```bash
   flutter pub get
   ```

4. **Create a `.env` file in the root directory with the following content:**

   ```
   FINNHUB_API_KEY=your_api_key_here
   FINNHUB_BASE_URL=https://finnhub.io/api/v1
   FINNHUB_WS_URL=wss://ws.finnhub.io
   ```

5. **Run the App**

   - **Android:**

     ```bash
     flutter run -d android
     ```

   - **iOS:**

     ```bash
     flutter run -d ios
     ```

   - **Web:**

     ```bash
     flutter run -d chrome
     ```

6. **Test the App**

   ```bash
   cd packages/finnhub_api
   flutter test
   ```

   ```bash
   cd packages/forex_repository
   flutter test
   ```

---

## Project Structure

```
├── lib
│   ├── core
│   │   └── config
│   ├── forex_pairs
│   │   ├── bloc
│   │   ├── view
│   │   └── widgets
│   ├── historical_data
│   │   ├── bloc
│   │   └── view
│   └── pages
├── packages
│   ├── finnhub_api
│   │   ├── lib
│   │   │   └── src
│   │   │       ├── config
│   │   │       ├── enums
│   │   │       ├── models
│   │   │       └── services
│   │   └── test
│   └── forex_repository
│       ├── lib
│       │   └── src
│       └── test

```

**The application is separated into three layers:**

- Presentation Layer
- Business Logic Layer
- Data Layer
  - Repository
  - Data Provider

The app consists of isolated features in it's own directories. This approach makes the app scalable as it allows you to work on a feature in isolation and multiple developers can work on different features simultaneously.

This project consists of two features

- Forex Pairs
- Historical Data

Each feature will consist of it's own

- bloc/cubit folder: contains the business logic and state related to the respective feature
- view folder: contains the main pages that make the feature
- widgets: reusable widgets used for this feature

#### Presentation Layer

The presentation layer is located in the **view** folder of a feature, this will be the user facing UI.

#### Business Logic Layer

The business logic layer (related to the respective feature) is colocated within the feature itself along with the view.

#### Data Layer

The Data Layer consists of two parts

- Repository
- Data Provider

The Data Provider is the furthest from the user. The data providers responsibility is to fetch and provide raw data from asynchronous data sources using network requests.

The Repository is an intermediate layer between the Business logic layer and the data provider and is responsible to collate the data from one or more data providers and pass it to the business logic layer.

---

### Finnhub Api

Finnhub api provides realtime RESTful api's and WebSockets to get stock data.

Since this is a 3rd party data provider, We've leveraged Dart Packages as they're easy to maintain, extend, and test. The dart package can also then be reused across other dart projects as a mini library.

### Forex Repository

Forex repository is also a reusable Dart package. The repository acts as the data provider for the UI and by doing so, completely isolates the data source from the frontend. This allows us to swap the Finnhub Api with any other data source without touching the repository or the app.

---

### Features Implemented

- Finnhub Api package
  - Used to consume finnhub restful api and websocket for live forex data.
- Forex Repository package
  - Used to interface between the Finnhub api package and Business logic layer.
- Forex Pairs Screen
  - Implemented websocket connection to fetch live data from the Finnhub api.
- Historical Data
  - Implemented chart to showcase historical data for a forex pair.

---

### State Management And Caching

The state management solution used for the app is BloC library and caching solution used is Hydrated Bloc.
All of the UI state is managed by BloC which gracefully updates the stateless widgets consuming the bloc.
In case of connection issues, the cached data will take over and populate the screen making the app offline ready.

### Enhanced UI and Responsiveness

The app is designed as per current forex platforms and can be run on mobile devices (android and iOS), tablet and desktop.

### Testing

The app consists of unit tests for the data layer, which includes the finnhub api package and the forex repository.

### Notes

- To simulate the change in forex prices, I've added a minor variation **on top of** the prices returned via the WebSocket as when the stock market is closed the data returned is same.
- The websocket connection currently does not allow to subscribe to alot of pairs, hence I've limited the subscription to only first 20 pairs.
- The websocket has a retry mechanism upto 5 times with a delay between each retry (2 seconds).
- The app avoids subscribing to the same pair if already subscribed.
- The app unsubscribes to the subscribed symbols before disconnecting.
- The candle api to be used is a _premium_ api and hence the response is hardcoded in the app. The implementation is done in a way to allow swapping the hardcoded data with the real api and it'll work right off the bat.

---

### Scope for improvement

- Due to the dependency on a third party data provider (finnhub), when a WebSocket connection is established, the app just waits until the data arrives and this can take upto 30 seconds sometimes. For now, the app shows a loading indicator (shimmer) when the data has not arrived for a better user experience. Once the data arrives, it's automatically cached and the subsequent experience is much smoother as the data gets fetched directly from cache until it actually arrives. An improvement here would be to fetch an initial price list (an http request), populate the initial data with that while the data arrives via the websocket connection.
- Implementing a unified app theme, ideally as a separate dart package, that would contain the font sizes, border radius, spacing, light mode, dark mode etc. Having it as a separate dart package would leverage having a consistent design system across all projects.
- Currently the project contains minimal test coverage.
- An extended view of the chart in landscape mode in mobile devices.

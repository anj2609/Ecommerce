# ShopVibe - Flutter E-Commerce App

A clean and scalable Flutter E-Commerce application demonstrating practical mid-level Flutter development skills including API integration, Firebase authentication, state management, pagination, cart handling, offline support, and responsive UI.

## Features

- **Google Authentication** - Firebase-based Google Sign-In with persistent sessions
- **Product Listing** - Grid display with image, title, price, discount, rating, brand, stock status
- **Product Details** - Image carousel, full product info, pricing with discounts
- **Cart Management** - Add/remove products, quantity control, dynamic price calculation
- **Pagination** - Infinite scrolling with lazy loading and pull-to-refresh
- **Search & Filter** - Debounced search, category filtering, sort by price/rating
- **Location Display** - GPS-based human-readable address with permission handling
- **Offline Support** - Connectivity listener, cached products, persistent cart
- **Dark Mode** - Full dark/light theme toggle
- **Shimmer Loading** - Skeleton loading states for better UX

## Architecture

This project follows **Clean Architecture** with a feature-based folder structure:

```
lib/
├── core/
│   ├── constants/          # API and storage constants
│   ├── network/            # Dio client, connectivity service
│   ├── router/             # GoRouter configuration
│   ├── storage/            # Hive local storage wrapper
│   ├── theme/              # App theme and theme provider
│   └── widgets/            # Shared widgets (shimmer, error, connectivity)
├── features/
│   ├── auth/
│   │   ├── data/           # Data sources and repository implementation
│   │   ├── domain/         # Repository interface
│   │   └── presentation/   # Providers, screens, widgets
│   ├── cart/
│   │   ├── data/           # Local data source and repository
│   │   ├── domain/         # Cart entities and repository interface
│   │   └── presentation/   # Cart provider, screen, widgets
│   ├── dashboard/
│   │   └── presentation/   # Dashboard screen
│   ├── location/
│   │   ├── data/           # Location data source
│   │   └── presentation/   # Location provider
│   └── products/
│       ├── data/           # Remote/local data sources, models, repository
│       ├── domain/         # Product entity, repository interface
│       └── presentation/   # Product provider, screens, widgets
└── main.dart
```

Each feature has three layers:
- **Data Layer** - Data sources (remote/local) and repository implementations
- **Domain Layer** - Entities and repository interfaces
- **Presentation Layer** - Providers (state management), screens, and widgets

## State Management

**Riverpod** is used as the state management solution.

- `StateNotifierProvider` for complex state (Auth, Products, Cart, Location)
- `FutureProvider.family` for product details
- `StreamProvider` for connectivity status and auth state changes
- `Provider` for dependency injection (repositories, data sources)

State synchronization is maintained across screens - cart updates reflect instantly on product listing, product details, and cart screen.

## API Integration

- **Base URL**: `https://dummyjson.com`
- **Products**: `/products` with pagination (`limit` & `skip` params)
- **Search**: `/products/search?q={query}`
- **Categories**: `/products/categories` and `/products/category/{slug}`
- **Dio** HTTP client with configurable timeouts and interceptors

## Third-Party Libraries

| Library | Purpose |
|---------|---------|
| `firebase_core` | Firebase initialization |
| `firebase_auth` | Firebase Authentication |
| `google_sign_in` | Google Sign-In |
| `flutter_riverpod` | State management |
| `dio` | HTTP networking |
| `cached_network_image` | Image caching |
| `shimmer` | Loading skeleton animations |
| `geolocator` | GPS location access |
| `geocoding` | Reverse geocoding |
| `hive_flutter` | Local storage (cart, session, cache) |
| `connectivity_plus` | Network status monitoring |
| `go_router` | Declarative routing |
| `google_fonts` | Typography (Inter font) |

## Setup Steps

### Prerequisites
- Flutter SDK (latest stable)
- Android Studio / VS Code
- Firebase project configured

### Firebase Configuration

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
2. Add an Android app with package name `com.ecommerce.ecommerce_app`
3. Download `google-services.json` and place it in `android/app/`
4. Generate SHA-1 key:
   ```bash
   cd android && ./gradlew signingReport
   ```
5. Add SHA-1 to Firebase project settings
6. Enable Google Sign-In in Firebase Authentication

### iOS Configuration (if needed)
1. Add iOS app in Firebase Console
2. Download `GoogleService-Info.plist` and place in `ios/Runner/`
3. Add URL scheme from plist to `ios/Runner/Info.plist`

### Run the App

```bash
flutter pub get
flutter run
```

## Assumptions

- The app targets Android and iOS platforms
- Portrait orientation only (locked)
- Products API from DummyJSON is always available
- Cart data persists locally using Hive
- User session is managed by Firebase Auth (auto-login)
- Location permission is requested at runtime on dashboard load
- Minimum Android SDK is 23 (Android 6.0)

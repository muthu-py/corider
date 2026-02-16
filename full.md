# CoRider Full Project Documentation

## 1. Project Overview
CoRider is a Flutter + Supabase ride-sharing app with two primary user roles:
- Driver: create rides, manage own rides, view passenger bookings.
- Passenger: search rides by route/time constraints, book seats, view own bookings.

The repository also contains a small FastAPI backend (`backend/`) for ride create/read endpoints, though the Flutter app currently uses Supabase directly for most production behavior.

## 2. Implemented Feature Set

### Authentication & Session
- Google Sign-In (`AuthService.signInWithGoogle`) with:
  - Native flow on Android/iOS.
  - OAuth browser + localhost callback flow on desktop.
- Session-aware splash redirect:
  - Signed-in -> `/role_selection`
  - Signed-out -> `/login`
- Sign out from drawer.

### Theming
- Light/Dark theme support via singleton `ThemeController` (`ValueNotifier<ThemeMode>`).
- Theme toggle available across multiple screens and drawer.

### Driver Features
- Create ride with:
  - Source & destination autocomplete (Nominatim/OpenStreetMap).
  - Departure date/time.
  - Seat count.
  - UI-only preferences/chips and price field.
- Publish ride to Supabase `rides` table.
- My Rides screen:
  - Lists current user’s rides.
  - Cancel ride (status -> `CANCELLED`).
  - Displays booked seats count from `ride_bookings` (`CONFIRMED` only).
  - Shows passenger contacts (name + phone) via bottom sheet and copy action.

### Passenger Features
- Search rides with filters:
  - From/To location autocomplete.
  - Desired departure datetime.
  - Time window (± minutes).
  - Required seats.
  - Internal distance filter radius (hidden in UI).
- Results screen:
  - Shows matched rides.
  - Displays source/drop distance deltas.
  - Book ride CTA with loading/error/success handling.
- Booking flow:
  - Uses Supabase RPC `book_ride` (transaction-safe server logic expected).
  - Refreshes updated ride state after booking.
- My Bookings screen:
  - Lists passenger’s booked rides from `ride_bookings`.
  - Shows driver contact phone and copy action.

### Contact / Phone Feature
- Drawer has “My Phone Number” option.
- User can upsert phone number into `users.phone`.
- Driver and passenger can view each other’s phone number from booking-linked views and copy it.

## 3. Runtime Architecture

### Frontend Stack
- Flutter (Material 3).
- Supabase Flutter SDK.
- `http` for OpenStreetMap search API.
- `google_sign_in` for native OAuth.

### Backend Stack (Optional/Secondary)
- FastAPI + SQLAlchemy + Pydantic for minimal ride endpoints.

## 4. Data Model (Current App Expectations)

### `rides`
Expected fields (used by app):
- `id` (uuid)
- `driver_id` (uuid)
- `source_name`, `source_lat`, `source_lon`
- `destination_name`, `destination_lat`, `destination_lon`
- `departure_time`
- `total_seats`
- `available_seats`
- `status` (`ACTIVE`, `FULL`, `STARTED`, `COMPLETED`, `CANCELLED`)
- `created_at`

### `ride_bookings`
Expected fields:
- `id` (uuid)
- `ride_id` -> `rides.id`
- `passenger_id` -> auth user id
- `seats_booked` (int > 0)
- `status` (e.g., `CONFIRMED`)
- `created_at`

### `users`
Expected fields for contact/profile lookup:
- `id` (uuid, same as auth.uid)
- `full_name`
- `email`
- `phone`

## 5. Navigation Map
`MaterialApp.routes` in `lib/main.dart`:
- `/login` -> `LoginScreen`
- `/role_selection` -> `RoleSelectionScreen`
- `/create_ride` -> `CreateRideScreen`
- `/active_ride_dashboard` -> `ActiveRideDashboardScreen`
- `/search_rides` -> `SearchRidesScreen`
- `/ride_results` -> `RideResultsScreen`
- `/ride_details` -> `RideDetailsScreen`
- `/my_rides` -> `MyRidesScreen`
- `/my_bookings` -> `MyBookingsScreen`

Initial `home` is `SplashScreen`.

## 6. Complete Codebase Breakdown

### `lib/main.dart`
- App bootstrap.
- Loads `.env` and initializes Supabase.
- Wires themes and route table.

### `lib/models/location_suggestion.dart`
- DTO for Nominatim location result (`name`, `lat`, `lon`).

### `lib/models/ride.dart`
- Ride domain model and enum `RideStatus`.
- `fromJson`, `toJson`, and `copyWith`.

### `lib/models/ride_booking.dart`
- Passenger-side booking view model:
  - booking metadata + linked `Ride` + optional `driverName/driverPhone`.

### `lib/models/ride_passenger_booking.dart`
- Driver-side passenger booking view model:
  - booking metadata + optional `passengerName/passengerPhone`.

### `lib/services/auth_service.dart`
- Auth operations:
  - `signInWithGoogle`, `signOut`, auth stream/current user.
- Profile utilities:
  - `getCurrentUserPhone`
  - `updateCurrentUserPhone`
  - `syncCurrentUserProfile`

### `lib/services/location_service.dart`
- Calls Nominatim search API.
- Returns max 5 location suggestions.

### `lib/services/ride_service.dart`
- Ride CRUD/queries and booking-related data:
  - `createRide`
  - `getRidesForDriver`
  - `cancelRide`
  - `searchRides` (status/seats/time + distance matching/ranking)
  - `bookRide` via RPC `book_ride`
  - `getBookingCountsForRideIds`
  - `getBookingsForPassenger`
  - `getPassengerBookingsForRideIds`
  - `_getUserProfilesByIds`

### `lib/widgets/location_autocomplete_field.dart`
- Reusable location autocomplete field with overlay suggestions.
- Includes debounce, selection/race guards, and deterministic overlay dismissal.

### `lib/widgets/app_drawer.dart`
- Global navigation drawer.
- Entries: Home, My Rides, My Bookings, My Phone Number, Theme toggle, Sign Out.
- Phone dialog supports read/update/copy.

### `lib/screens/splash_screen.dart`
- Branded splash + delayed redirect by session.

### `lib/screens/login_screen.dart`
- Google login entry.
- Auth listener-driven navigation.
- Syncs user profile row on successful login.

### `lib/screens/role_selection_screen.dart`
- Driver vs Passenger entry choice.
- Hosts app drawer.

### `lib/screens/create_ride_screen.dart`
- Driver ride creation form.
- Validates source/destination selection + date/time before enabling publish.

### `lib/screens/search_rides_screen.dart`
- Passenger search form matching driver-style route UI.
- Hidden internal distance radius.
- Sends `RideResultsArgs` to results page.

### `lib/screens/ride_results_screen.dart`
- Search result renderer and booking action surface.
- Handles per-item booking loading state and seat insufficiency state.

### `lib/screens/my_rides_screen.dart`
- Driver ride management list.
- Cancel action.
- Booking count badge and passenger contact bottom sheet.

### `lib/screens/my_bookings_screen.dart`
- Passenger booking history list.
- Driver contact visibility with copy action.

### `lib/screens/active_ride_dashboard_screen.dart`
- Rich static/illustrative active-trip dashboard UI.

### `lib/screens/ride_details_screen.dart`
- Rich static ride details visual screen.

### `lib/theme/light_theme.dart`, `lib/theme/dark_theme.dart`
- App `ThemeData` variants using Manrope font.

### `lib/theme/theme_controller.dart`
- Global theme state singleton.

### `lib/theme/primary_colors.dart`
- Shared color constants for selected screens.

### `backend/app/main.py`
- FastAPI app setup + router registration + health endpoint.

### `backend/app/database.py`
- SQLAlchemy engine/session/base setup.

### `backend/app/models/ride.py`
- SQLAlchemy `Ride` table model.

### `backend/app/schemas/ride.py`
- Pydantic request/response schemas.

### `backend/app/services/ride_service.py`
- Backend service functions for create ride and get active ride.

### `backend/app/routes/rides.py`
- API endpoints:
  - `POST /api/rides`
  - `GET /api/rides/active?driver_id=...`

### `UI/`
- Design reference assets (light/dark HTML + screenshots), not runtime Flutter code.

## 7. Widget Tree (Whole Project)

## 7.1 App Root Tree
```text
main()
└─ MyApp
   └─ ValueListenableBuilder<ThemeMode>
      └─ MaterialApp
         ├─ theme/darkTheme/themeMode
         ├─ home: SplashScreen
         └─ routes
```

## 7.2 Route-Level Widget Trees

### Splash (`SplashScreen`)
```text
Scaffold
└─ InkWell
   └─ SafeArea
      └─ Stack
         ├─ Positioned decorative circles
         ├─ Center
         │  └─ Column (logo/title/tagline)
         └─ Positioned bottom loader/version
```

### Login (`LoginScreen`)
```text
Scaffold
└─ Stack
   ├─ Positioned background circles
   └─ SafeArea
      └─ Center
         └─ Column
            ├─ App icon/title/subtitle
            └─ Google sign-in button or loader
```

### Role Selection (`RoleSelectionScreen`)
```text
Scaffold (drawer: AppDrawer)
├─ AppBar
└─ SafeArea
   └─ CustomScrollView
      └─ SliverFillRemaining
         └─ Column
            ├─ Intro text
            ├─ Driver role card
            └─ Passenger role card
```

### Drawer (`AppDrawer`)
```text
Drawer
└─ Column
   ├─ UserAccountsDrawerHeader
   ├─ Home tile
   ├─ My Rides tile
   ├─ My Bookings tile
   ├─ My Phone Number tile (dialog)
   ├─ Theme tile
   └─ Sign Out tile
```

### Create Ride (`CreateRideScreen`)
```text
Scaffold
└─ Stack
   ├─ SafeArea
   │  └─ Column
   │     ├─ Header row
   │     └─ Expanded
   │        └─ ListView
   │           ├─ Map preview card
   │           ├─ Form card
   │           │  ├─ Route section
   │           │  │  ├─ Timeline icons
   │           │  │  └─ 2x LocationAutocompleteField
   │           │  ├─ Departure time picker
   │           │  ├─ Seats selector + price field
   │           │  └─ Preference chips
   │           └─ Info row
   └─ Positioned bottom publish action bar
```

### Search Rides (`SearchRidesScreen`)
```text
Scaffold
├─ AppBar
└─ ListView
   ├─ Route/search card
   │  ├─ Timeline icons
   │  ├─ From LocationAutocompleteField
   │  └─ To LocationAutocompleteField
   ├─ Departure time selector
   ├─ Time window dropdown
   ├─ Passenger seats dropdown
   └─ Find Rides button
```

### Ride Results (`RideResultsScreen`)
```text
Scaffold
├─ AppBar
└─ Column
   ├─ Search summary text
   └─ Expanded
      └─ ListView.separated
         └─ Ride card
            ├─ Time + seats badge
            ├─ Source and destination labels
            ├─ Distance diagnostics
            └─ Book Ride button (loading/disabled states)
```

### My Rides (`MyRidesScreen`)
```text
Scaffold
├─ AppBar
└─ Body state
   ├─ Loading spinner
   ├─ Error text
   ├─ Empty text
   └─ RefreshIndicator
      └─ ListView
         └─ Ride card
            ├─ Status chip + datetime
            ├─ Route rows
            ├─ Seats label
            ├─ "X booked" button (opens passenger contacts)
            └─ Cancel action
```

### My Bookings (`MyBookingsScreen`)
```text
Scaffold
├─ AppBar
└─ Body state
   ├─ Loading spinner
   ├─ Error text
   ├─ Empty text
   └─ RefreshIndicator
      └─ ListView
         └─ Booking card
            ├─ Ride time + booked seats
            ├─ Route rows
            ├─ Booking metadata
            └─ Driver phone + copy action
```

### Active Dashboard (`ActiveRideDashboardScreen`)
```text
Scaffold
└─ Stack
   ├─ SafeArea
   │  └─ Column
   │     ├─ Top bar
   │     └─ Expanded ListView
   │        ├─ Active ride status chip
   │        ├─ Main trip card (map/eta/timeline/passengers)
   │        └─ Stats row
   └─ Positioned bottom action bar (call + navigate)
```

### Ride Details (`RideDetailsScreen`)
```text
Scaffold
└─ Stack
   ├─ Top map section
   ├─ Overlay top controls
   └─ Bottom sheet-like details container
      └─ ListView
         ├─ Fare/time section
         ├─ Route timeline
         ├─ Driver info
         └─ Action area
```

## 8. Booking & Contact Data Flow

### Passenger Books Ride
1. Passenger searches rides (`searchRides`).
2. In results, taps `Book Ride`.
3. App calls `RideService.bookRide`.
4. Service invokes Supabase RPC `book_ride(p_ride_id, p_seats)`.
5. RPC writes booking row + updates ride seats/status atomically.
6. App refetches updated `rides` row and updates UI card.

### Passenger Sees Driver Contact
1. `MyBookingsScreen` calls `getBookingsForPassenger`.
2. Service loads booking rows + corresponding rides + driver profiles (`users`).
3. UI displays `driverPhone` and copy action.

### Driver Sees Passenger Contact
1. `MyRidesScreen` loads own rides.
2. Service loads `ride_bookings` for those ride IDs and profile rows for passengers.
3. UI shows `X booked`; tap opens list of passenger contacts with copy action.

## 9. Supabase / Backend Dependencies

### Required Supabase Tables
- `rides`
- `ride_bookings`
- `users`

### Required Supabase Function
- `book_ride(uuid, int)` must exist and enforce seat-safe booking transaction logic.

### Required RLS Behavior
- Passengers can insert/view own `ride_bookings`.
- Drivers can view bookings for rides they own.
- `users` select policy must allow linked passenger-driver visibility for contact sharing.
- Each user must be able to upsert/update own `users` row.

## 10. Notes / Constraints
- Several screens (`ActiveRideDashboardScreen`, `RideDetailsScreen`) are currently largely static UI.
- Contact action is copy-to-clipboard (not direct dial intent launcher yet).
- `CreateRideScreen` currently captures price and preferences in UI but they are not persisted in `Ride` model/table.
- Project includes both direct Supabase client operations and an optional FastAPI backend; production path currently favors Supabase for ride/booking operations.

## 11. Quick File Inventory

### Frontend (`lib`)
- `main.dart`
- `models/`
  - `location_suggestion.dart`
  - `ride.dart`
  - `ride_booking.dart`
  - `ride_passenger_booking.dart`
- `services/`
  - `auth_service.dart`
  - `location_service.dart`
  - `ride_service.dart`
- `widgets/`
  - `app_drawer.dart`
  - `location_autocomplete_field.dart`
- `screens/`
  - `splash_screen.dart`
  - `login_screen.dart`
  - `role_selection_screen.dart`
  - `create_ride_screen.dart`
  - `search_rides_screen.dart`
  - `ride_results_screen.dart`
  - `my_rides_screen.dart`
  - `my_bookings_screen.dart`
  - `active_ride_dashboard_screen.dart`
  - `ride_details_screen.dart`
- `theme/`
  - `light_theme.dart`
  - `dark_theme.dart`
  - `theme_controller.dart`
  - `primary_colors.dart`

### Backend (`backend/app`)
- `main.py`
- `config.py`
- `database.py`
- `models/ride.py`
- `schemas/ride.py`
- `services/ride_service.py`
- `routes/rides.py`

### Design Reference (`UI`)
- Light/Dark static HTML and screenshot references for each major screen.

---
This document reflects the current repository implementation and route wiring at the time of generation.

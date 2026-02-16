# CoRider Project Model

## 1. Project Summary
CoRider is a multi-platform Flutter app with Google/Supabase authentication and a small FastAPI backend for ride creation/lookup.

- Frontend: Flutter (`lib/`) for Android, iOS, Linux, macOS, Windows, and Web.
- Auth/Data platform: Supabase Auth (Google sign-in).
- Backend API: FastAPI + SQLAlchemy + PostgreSQL (`backend/`).

Primary intent of the current codebase:
- Deliver polished UI flows for driver/passenger ride experience.
- Support login via Google.
- Support backend endpoints for creating a ride and fetching a driver's active ride.

## 2. Tech Stack

### Frontend
- Flutter SDK `^3.10.8`
- Key packages:
  - `supabase_flutter`
  - `google_sign_in`
  - `flutter_dotenv`
  - `google_fonts`

### Backend
- Python FastAPI app
- SQLAlchemy ORM
- PostgreSQL (UUID-based ride records)
- Pydantic schemas

## 3. Repository Structure

- `lib/main.dart`: App bootstrapping, Supabase init, route table.
- `lib/screens/`: App UI screens.
- `lib/services/auth_service.dart`: Google sign-in/sign-out logic via Supabase.
- `lib/theme/`: Light/dark theme and theme controller.
- `backend/app/main.py`: FastAPI app entrypoint.
- `backend/app/routes/rides.py`: Ride API routes.
- `backend/app/services/ride_service.py`: Ride business logic.
- `backend/app/models/ride.py`: SQLAlchemy `Ride` model.
- `backend/app/schemas/ride.py`: Request/response contracts.
- `backend/app/database.py`: Engine/session/base setup.
- `backend/app/config.py`: DB connection string from env.
- `UI/`: Light/dark design references and generated HTML previews.

## 4. Frontend Architecture and Flow

### App Startup
`lib/main.dart` does:
1. `WidgetsFlutterBinding.ensureInitialized()`
2. Load `.env`
3. Initialize Supabase using:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
4. Start `MaterialApp` with named routes.

### Routing
Configured named routes:
- `/login`
- `/role_selection`
- `/create_ride`
- `/active_ride_dashboard`
- `/search_rides`
- `/ride_results`
- `/ride_details`

Home route is `SplashScreen`.

### Auth Flow
- `SplashScreen` waits ~2s, checks `Supabase.instance.client.auth.currentSession`.
- If session exists -> `/role_selection`; else -> `/login`.
- `LoginScreen` uses `AuthService.signInWithGoogle()` and listens to auth state changes.
- On successful auth session -> navigate to `/role_selection`.
- `RoleSelectionScreen` logout triggers `AuthService.signOut()` then returns to `/login`.

### Platform-specific Google Sign-In behavior
In `AuthService`:
- Android/iOS: native `google_sign_in` -> Supabase `signInWithIdToken`.
- Desktop (Linux/Windows/macOS): OAuth via local callback server on `localhost:54321` and `exchangeCodeForSession`.
- Web: Supabase OAuth redirect flow.

### UI Status (important)
Most ride-related screens are currently UI-first and mostly static/mock data:
- `create_ride_screen.dart`
- `search_rides_screen.dart`
- `ride_results_screen.dart`
- `ride_details_screen.dart`
- `active_ride_dashboard_screen.dart`

These are styled flows with navigation, but they are not yet deeply integrated with live backend ride APIs.

## 5. Theme System
- `ThemeController` is a `ValueListenable` used by `MaterialApp.themeMode`.
- Toggling is wired into multiple screens via icon buttons.
- Light/dark themes are defined in `lib/theme/light_theme.dart` and `lib/theme/dark_theme.dart`.

## 6. Backend Architecture

### FastAPI App
`backend/app/main.py`:
- Creates `FastAPI(title="CoRider Backend")`
- Includes ride router (`/api/rides`)
- Calls `Base.metadata.create_all(bind=engine)` at startup
- Health check endpoint: `GET /health` -> `{ "status": "ok" }`

### DB Configuration
`backend/app/config.py` composes `DATABASE_URL` from:
- `DB_USER`
- `DB_PASSWORD`
- `DB_HOST`
- `DB_PORT`
- `DB_NAME`

`backend/app/database.py` creates SQLAlchemy engine/session/base.

### Ride Data Model
`backend/app/models/ride.py` table: `rides`
- `id` (UUID, PK)
- `driver_id` (UUID)
- `source_name`, `source_lat`, `source_lon`
- `destination_name`, `destination_lat`, `destination_lon`
- `departure_time` (DateTime)
- `available_seats` (int)
- `status` (string, default `ACTIVE`)
- `created_at` (server timestamp)

### API Contracts
From `backend/app/schemas/ride.py`:

- `Location`
  - `name: str`
  - `lat: float` (-90..90)
  - `lon: float` (-180..180)

- `RideCreateRequest`
  - `driver_id: UUID`
  - `source: Location`
  - `destination: Location`
  - `departure_time: datetime`
  - `available_seats: int (>0)`

- `RideResponse`
  - `ride_id: UUID`
  - `status: str`
  - `message: str`

- `ActiveRideResponse`
  - `ride_id: UUID`
  - `source: Location`
  - `destination: Location`
  - `departure_time: datetime`
  - `available_seats: int`
  - `status: str`

### API Endpoints
`backend/app/routes/rides.py`:

1. `POST /api/rides`
- Body: `RideCreateRequest`
- Response: `RideResponse`
- Behavior: creates a new ride with status `ACTIVE`.

2. `GET /api/rides/active?driver_id=<uuid>`
- Response: `ActiveRideResponse`
- 404 if no active ride for driver.

## 7. Environment Variables

### Frontend (`.env` at repo root)
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

### Backend (expected by `backend/app/config.py`)
- `DB_USER`
- `DB_PASSWORD`
- `DB_HOST`
- `DB_PORT`
- `DB_NAME`

## 8. Current Integration State
- Auth is integrated with Supabase and route guards at splash/login level.
- Backend ride APIs exist and are functional by code structure.
- Frontend ride screens are mostly static and currently do not fully consume backend endpoints.
- No backend dependency lock/requirements file is currently present in `backend/`.

## 9. How an AI Assistant Should Work With This Project
When modifying this project, assume:
- Flutter UI and UX quality is a primary goal.
- Authentication should remain Supabase-first.
- Backend should stay RESTful and SQLAlchemy-based unless explicitly asked to change.

Recommended AI workflow:
1. Read `lib/main.dart` and `lib/services/auth_service.dart` first.
2. Confirm whether task is frontend-only, backend-only, or integration.
3. For ride features, align `lib/screens/*` with `backend/app/schemas/ride.py` contracts.
4. Keep route names and theme toggling behavior intact unless refactor is requested.
5. Avoid introducing breaking auth flow changes across desktop/mobile/web without explicit testing notes.

## 10. Suggested Next Improvements
- Connect `CreateRideScreen` form submission to `POST /api/rides`.
- Replace static ride result cards with backend-driven search/matching endpoint.
- Add Python dependency manifest (`requirements.txt` or `pyproject.toml`).
- Add backend migration tool (Alembic) instead of `create_all` for production.
- Add unit/integration tests for `ride_service` and API routes.

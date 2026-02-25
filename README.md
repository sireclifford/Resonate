# Resonate 📖🎵

## Production-Grade iOS Hymnal App (SwiftUI)

**Resonate** is a fully architected iOS application built using
**SwiftUI, MVVM, and service-based dependency injection**.

The project demonstrates production-level state management,
deterministic UI rendering, structured domain modeling, scalable audio
architecture, smart notifications, deep-link navigation, and analytics
instrumentation.

------------------------------------------------------------------------

## 🚀 Engineering Goals

Resonate was designed to demonstrate:

-   Clean dependency injection\
-   Modular service architecture\
-   Deterministic UI behavior\
-   Deep-link navigation via state\
-   Smart notification scheduling\
-   Offline-first audio handling\
-   Strongly-typed analytics instrumentation\
-   Scalable feature expansion

------------------------------------------------------------------------

# 🧠 Architecture

Resonate uses a modular dependency container:

    AppEnvironment (Dependency Container)
     ├── HymnService
     ├── TuneService
     ├── AudioPlaybackService
     ├── FavouritesService
     ├── RecentlyViewedService
     ├── NotificationService
     ├── LastAppOpenService
     ├── AnalyticsService
     ├── SearchViewModel
     ├── CategoryViewModel
     └── HymnStoryService

### Architectural Principles

-   Explicit dependency injection\
-   MVVM separation of concerns\
-   Service isolation\
-   Reactive state propagation\
-   Deterministic behavior\
-   Type-safe navigation\
-   Feature scalability

------------------------------------------------------------------------

# 📚 Structured Hymn Engine

## Hymn Modeling

-   JSON-driven hymn data\
-   Structured verses & chorus separation\
-   Metadata normalization\
-   Scripture references (USFM codes)\
-   Historical companion content

## Deterministic Hymn of the Day

Daily hymn rotation is computed using:

``` swift
let index = daysSinceEpoch % hymnCount
```

Benefits:

-   Device consistency\
-   Predictable behavior\
-   No randomization bugs\
-   Stable analytics tracking

------------------------------------------------------------------------

# 🔎 Intelligent Search

-   Debounced search input\
-   Numeric hymn quick-jump\
-   Title matching\
-   Verse-level lyric search\
-   Category filtering\
-   Efficient index-based filtering

Business logic lives inside `SearchViewModel`.

------------------------------------------------------------------------

# 🎼 Audio System

## AudioPlaybackService

-   AVAudioPlayer-based playback\
-   Background audio support\
-   Global floating MiniPlayer\
-   Deterministic audio availability detection\
-   Haptic feedback integration\
-   Auto-stop on navigation (configurable)

### State Model

    AudioPlaybackService
     ├── @Published currentHymnID
     ├── @Published isPlaying
     ├── AVAudioPlayer instance
     └── Analytics hooks

Designed to evolve into:

-   Remote streaming\
-   On-demand downloads\
-   Offline caching\
-   Background fetch

------------------------------------------------------------------------

# 🔔 Smart Notification System

## Capabilities

-   User-selectable daily reminder time\
-   Suppresses reminder if app already opened that day\
-   Deep-link navigation to hymn detail\
-   Intelligent non-repeating scheduling\
-   Foreground banner support\
-   State-driven routing via environment container

------------------------------------------------------------------------

# 📊 Analytics

Integrated Firebase Analytics with strongly-typed event definitions.

Tracked events:

-   hymn_opened\
-   hymn_favourited / hymn_unfavourited\
-   category_opened\
-   tab_switched\
-   audio_played / audio_paused\
-   reminder_enabled / reminder_disabled

No personal user data is collected.

------------------------------------------------------------------------

# 🔐 Privacy & Compliance

-   Explicit notification permission request\
-   Privacy policy hosted via GitHub Pages\
-   Terms of use\
-   API attribution (YouVersion)\
-   Firebase keys removed from repository history\
-   No invasive tracking

------------------------------------------------------------------------

# 📱 Tech Stack

-   SwiftUI\
-   Combine\
-   AVFoundation\
-   UserNotifications\
-   Firebase Analytics\
-   MVVM\
-   Service-based dependency injection\
-   JSON content modeling

------------------------------------------------------------------------

# 📈 Scalability Roadmap

Prepared for:

-   Remote audio streaming\
-   Offline download manager\
-   Cross-device sync\
-   Cloud content updates\
-   Widgets\
-   Apple Watch support\
-   AI-powered hymn discovery

------------------------------------------------------------------------

# 👨🏾‍💻 Author

Clifford Owusu\
iOS Engineer

------------------------------------------------------------------------

# 📌 Status

Currently distributed via TestFlight.\
App Store release in preparation.

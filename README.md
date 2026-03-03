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
-   Sacred first-launch onboarding flow
-   Retention loop instrumentation (Trigger → Open → Read → Reflect → Return)
-   Session lifecycle tracking
-   Context-aware notification suppression
-   Structured event logging framework

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

## Retention Architecture

Resonate is instrumented around a structured spiritual habit loop:

    Trigger → Open → Read → Reflect → Return

This is supported by:

-   First-launch onboarding gate
-   Contextual notification permission flow
-   Deterministic Hymn of the Day routing
-   Session lifecycle tracking
-   Engagement depth measurement
-   Structured analytics events with typed parameters

Retention is treated as a product system, not a feature.

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

-   Contextual permission request during onboarding
-   User-selectable daily reminder time
-   Date-aware same-day suppression (prevents duplicate post-onboarding triggers)
-   Deterministic non-repeating scheduling
-   Deep-link navigation to Hymn Detail
-   State-driven routing via AppEnvironment
-   Robust cancellation with stable notification identifiers

------------------------------------------------------------------------

# 📊 Analytics

Integrated Firebase Analytics using a strongly-typed event layer.

## Instrumented Event Layers

### 1. Lifecycle
-   app_opened
-   session_started
-   session_ended

### 2. Onboarding
-   onboarding_shown
-   onboarding_begin_worship_tapped
-   onboarding_notification_cta_tapped
-   onboarding_dismissed

### 3. Notification
-   notification_scheduled
-   notification_opened
-   reminder_enabled / reminder_disabled

### 4. Home & Entry
-   home_viewed
-   start_here_tapped
-   category_opened
-   tab_switched

### 5. Engagement Depth
-   hymn_opened (with source attribution)
-   hymn_story_expanded
-   hymn_audio_played / paused / completed
-   hymn_favourited / hymn_unfavourited

## Design Principles

-   Strongly-typed event definitions
-   Structured parameter injection
-   Source attribution on navigation
-   Session-scoped context
-   No personal user data collected

Analytics are used to measure spiritual engagement patterns and retention health, not behavioral exploitation.

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

-   Habit formation dashboards & retention cohort analysis
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

# Resonate

Resonate is a devotional iOS hymnal app built with SwiftUI. It combines hymn reading, hymn-of-the-day discovery, curated categories, worship flow, story content, reminders, favourites, and accompaniment playback in a calmer, more editorial interface.

## What Resonate Does

- Browse a structured hymn library by theme or full catalog
- Open hymns by title, number, or lyric search
- Follow a daily Hymn of the Day rhythm
- Save hymns to your personal library
- Read hymn background stories and supporting context
- Enter a guided worship flow for reflection and singing
- Download accompaniment audio for offline playback
- Schedule daily reminder notifications

## Current Product Focus

This version focuses on:

- A more intentional visual language across the app
- Faster and cleaner search behavior
- A refined hymn reading and story experience
- Better support for Dynamic Type
- Persistent accompaniment playback with a mini player
- Improved settings feedback for downloaded audio management

## Feature Overview

### Home

- Devotional welcome experience
- Hymn of the Day hero
- Start Here guidance
- Curated category pathways

### Browse

- Theme-based exploration
- All-hymns browsing
- Grid and list presentation
- Category detail navigation

### Search

- Title search
- Hymn number jump
- Lyric matching
- Recent and frequent hymn suggestions

### Library

- Personal saved hymns collection
- Lens-based filtering
- Featured return hymn presentation

### Hymn Detail

- Reading controls
- Favourite toggle
- Story access
- Accompaniment playback
- Download and delete accompaniment actions

### Worship Flow

- Guided devotional sequence
- Verse and reflection slides
- Audio-assisted worship entry

### Settings

- Theme controls
- Reader controls
- Audio preferences
- Notification preferences
- Downloaded audio management

## Architecture

Resonate is built around a service-oriented app environment with SwiftUI views and feature-specific view models.

Core architectural patterns:

- SwiftUI-first UI composition
- MVVM for feature state
- Service-based dependency injection through `AppEnvironment`
- Local JSON-driven hymn content
- Strongly typed domain models
- Published state propagation for playback, settings, and reminders

Primary systems include:

- `HymnService`
- `CategoryViewModel`
- `SearchViewModel`
- `FavouritesService`
- `RecentlyViewedService`
- `AccompanimentPlaybackService`
- `AccompanimentCacheService`
- `ReminderSettingsViewModel`
- `NavigationService`
- `AnalyticsService`

## Tech Stack

- SwiftUI
- Combine
- AVFoundation
- UserNotifications
- Firebase Analytics
- JSON content storage

## Product Notes

- Hymn of the Day uses deterministic rotation for consistency
- Accompaniment playback supports offline caching
- Notification flows are permission-aware and settings-driven
- The app is designed for iterative refinement rather than one large monolith release

## Status

Active iOS project.

Current release line:

- visual refinement pass complete
- search performance improved
- dynamic type support broadened
- settings feedback improved

## Author

Clifford Owusu

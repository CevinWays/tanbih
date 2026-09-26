# Privacy Policy — Tanbih

Effective: 26 September 2026

Tanbih is a prayer time reminder app. This document explains what data the
app touches and what happens to it. In short: **this app has no server, and
sends none of your data anywhere.**

## Location

Tanbih uses your device location to compute prayer times, because prayer
times depend on geographic position.

- The calculation runs **on your device**, using an astronomy library
  bundled inside the app
- Your coordinates are **never sent to any server**, including to the
  developer
- The most recent coordinates are kept in the app's local storage so the
  schedule still works without a connection, and are removed when the app is
  uninstalled
- The app does **not** request background location. Location is read only
  while the app is open

You may refuse location permission entirely and still use the app by picking
a city by hand from the bundled list.

## City search (optional)

If you type a city name into search, that text is sent to the OpenStreetMap
geocoding service (Nominatim) to look up its coordinates. Only the text you
typed is sent — not your location, and nothing identifying you.

This is optional. With no connection, search falls back to the list of
Indonesian cities stored inside the app.

## What is not collected

Tanbih does not collect, store, or transmit:

- Your identity, name, email, or phone number
- Contacts, photos, or files
- Usage history, analytics, or behavioural data
- Advertising identifiers

There are no ads, no third-party trackers, and no accounts.

## Permissions and why

| Permission | Purpose |
|---|---|
| Location (coarse & fine) | Compute prayer times where you are |
| Notifications | Show a reminder when a prayer time begins |
| Exact alarms | So the adhan sounds on time rather than batched late |
| Run at startup | Re-arm the schedule after the device restarts |
| Foreground service | Play the full adhan while the app is closed |

## Storage

All settings, the last known location, and the schedule live in the app's
local storage on your device. Uninstalling the app removes them. There is no
copy anywhere else.

## Children

This app is not directed at children and collects no data from anyone,
children included.

## Changes

If this policy changes, the date above is updated and the new version is
published at the same address.

## Contact

Questions about this policy can be sent to the developer through the app's
Google Play listing.

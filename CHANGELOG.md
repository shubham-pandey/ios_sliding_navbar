## 0.0.2

* Added interactive Demo GIF for visual understanding.
* `SlidingSegmentedNavbar` — iOS-style sliding pill indicator with:
  * Real-time 1:1 drag tracking with the user's finger.
  * Pop-out lift physics on drag start (scale + shadow elevation).
  * Velocity-aware flick detection snapping to the next or previous tab.
  * `PageController` sync for proportional page drag mirroring.
  * `TabController` sync for `TabBarView` integration.
  * Controlled mode via `currentIndex` for state-management compatibility.
  * Icon + badge support via `SlidingNavItem`.
  * Fully customisable colours, borders, shadows, border radii, and text styles.
  * Accessibility semantics (button role, selected state, custom labels).

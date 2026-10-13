# ios_sliding_navbar

[![pub.dev](https://img.shields.io/pub/v/ios_sliding_navbar.svg)](https://pub.dev/packages/ios_sliding_navbar)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-≥3.0.0-blue.svg)](https://flutter.dev)

A highly polished **iOS-style sliding segmented navbar** for Flutter featuring real-time drag tracking, pop-out lift physics, velocity-aware flick gestures, and seamless `PageController`/`TabController` sync.

---

## ✨ Features

- 🎯 **Real-time 1:1 drag tracking** — pill center follows your finger instantly
- 🫧 **Pop-out lift physics** — pill scales up (×1.10) with elevated shadow on drag start, settling smoothly on release
- ⚡ **Velocity-aware flick** — fast swipes snap to the next/previous tab intelligently
- 📄 **`PageController` sync** — pill mirrors `PageView` drag proportionally in real time
- 📑 **`TabController` sync** — works seamlessly with `TabBarView`
- 🎛️ **Controlled mode** — drive index externally via `currentIndex` (BLoC / Riverpod / setState)
- 🔔 **Badges** — dot badges on icons via `SlidingNavItem`
- 🎨 **Fully customisable** — colors, borders, border radii, shadows, text styles
- ♿ **Accessible** — semantic button roles, selected state, custom labels

---

## 🚀 Getting Started

Add to your `pubspec.yaml`:

```yaml
dependencies:
  ios_sliding_navbar: ^0.0.1
```

Then run:

```bash
flutter pub get
```

---

## 📖 Usage

### Simple segmented control (string labels)

```dart
import 'package:ios_sliding_navbar/ios_sliding_navbar.dart';

SlidingSegmentedNavbar(
  items: const ['Pickup', 'Delivery', 'Dine-in'],
  onTabChanged: (index) => print('Selected: $index'),
)
```

### With icons and badges (`SlidingNavItem`)

```dart
SlidingSegmentedNavbar(
  navItems: const [
    SlidingNavItem(label: 'Home',    icon: Icons.home_rounded),
    SlidingNavItem(label: 'Orders',  icon: Icons.receipt_long, showBadge: true),
    SlidingNavItem(label: 'Profile', icon: Icons.person_rounded),
  ],
  onTabChanged: (index) => setState(() => _index = index),
)
```

### Synced with `PageView`

```dart
final _pageController = PageController();

SlidingSegmentedNavbar(
  items: const ['Feed', 'Explore', 'Inbox'],
  pageController: _pageController,
  onTabChanged: (i) => setState(() {}),
),

Expanded(
  child: PageView(
    controller: _pageController,
    children: [FeedPage(), ExplorePage(), InboxPage()],
  ),
),
```

### Controlled mode (external state)

```dart
SlidingSegmentedNavbar(
  items: const ['Tab A', 'Tab B'],
  currentIndex: _currentIndex,
  onTabChanged: (i) => setState(() => _currentIndex = i),
)
```

---

## 🎨 Customisation

| Parameter | Type | Default | Description |
|---|---|---|---|
| `items` | `List<String>?` | — | Simple string labels |
| `navItems` | `List<SlidingNavItem>?` | — | Icon + label + badge items |
| `customItemBuilder` | `Widget Function(ctx, i, selected)?` | — | Fully custom item widget |
| `currentIndex` | `int?` | — | Controlled index |
| `initialIndex` | `int` | `0` | Initial tab for uncontrolled use |
| `onTabChanged` | `ValueChanged<int>?` | — | Callback on tab change |
| `pageController` | `PageController?` | — | Sync with `PageView` |
| `tabController` | `TabController?` | — | Sync with `TabBarView` |
| `height` | `double` | `44.0` | Total widget height |
| `padding` | `EdgeInsetsGeometry` | `EdgeInsets.all(4)` | Inner track padding |
| `itemMargin` | `EdgeInsetsGeometry` | `EdgeInsets.zero` | Margin per indicator pill |
| `backgroundColor` | `Color` | `#1B221E` | Track background color |
| `indicatorColor` | `Color` | `#0D4A36` | Sliding pill color |
| `activeTextColor` | `Color` | `Colors.white` | Active label/icon color |
| `inactiveTextColor` | `Color` | `#9EABA2` | Inactive label/icon color |
| `animationDuration` | `Duration` | `380ms` | Snap animation duration |
| `animationCurve` | `Curve` | `easeInOutCubic` | Snap animation curve |
| `border` | `BoxBorder?` | — | Outer track border |
| `borderRadius` | `BorderRadiusGeometry?` | pill | Outer track border radius |
| `indicatorBorder` | `BoxBorder?` | — | Pill border |
| `indicatorBorderRadius` | `BorderRadiusGeometry?` | pill | Pill border radius |
| `indicatorBoxShadow` | `List<BoxShadow>?` | soft glow | Pill resting shadow |
| `labelStyle` | `TextStyle?` | Plus Jakarta Sans | Base text style |

---

## 📁 Example

A full runnable example is in the [`example/`](example/) folder.

---

## 🐛 Issues & Contributions

Found a bug or want a feature? Open an issue or PR on [GitHub](https://github.com/shubham3327/ios_sliding_navbar).

---

## 📄 License

MIT © 2026 Shubham

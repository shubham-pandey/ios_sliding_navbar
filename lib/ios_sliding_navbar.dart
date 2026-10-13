import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Item descriptor for navigation-oriented segmented bars with icons and badges.
class SlidingNavItem {
  final String label;
  final IconData? icon;
  final bool showBadge;
  final Color? badgeColor;
  final String? semanticsLabel;

  const SlidingNavItem({
    required this.label,
    this.icon,
    this.showBadge = false,
    this.badgeColor,
    this.semanticsLabel,
  });
}

/// iOS-style sliding segmented navbar with interactive physical drag tracking and pop-out lift physics.
/// Features:
/// 1. Pop-out on drag start: pill smoothly scales up (1.10) with increased elevation shadow.
/// 2. 1:1 real-time finger tracking: pill center follows touch position in real time.
/// 3. Settle on release: pill smoothly glides to destination tab while easing back to resting scale with liquid ease.
/// 4. Continuous fractional offset tracking ([0.0] to [tabCount - 1]) clamped strictly to track bounds.
/// 5. Velocity-aware flick detection on release, snapping to target with [AnimationController].
/// 6. Slow, smooth, non-snappy animations with fluid easing ([Curves.easeInOutCubic]).
/// 7. Controlled reactive sync with external [currentIndex], [PageController], or [TabController].
class SlidingSegmentedNavbar extends StatefulWidget {
  /// Simple string labels for classic segmented control (e.g. ['Pickup', 'Delivery']).
  final List<String>? items;

  /// Navigation items with icons, labels, and badges for bottom navigation bars.
  final List<SlidingNavItem>? navItems;

  /// Custom item builder for maximum flexibility.
  final Widget Function(BuildContext context, int index, bool isSelected)?
  customItemBuilder;

  /// Controlled active index from external state management.
  final int? currentIndex;

  /// Initial tab index for uncontrolled usage.
  final int initialIndex;

  /// Triggered whenever an item is selected or released.
  final ValueChanged<int>? onTabChanged;

  /// Optional [PageController] for proportional real-time horizontal drag sync.
  final PageController? pageController;

  /// Optional [TabController] for TabBarView sync.
  final TabController? tabController;

  /// Total height of the segmented bar.
  final double height;

  /// Inner padding of the bar enclosing the indicator track.
  final EdgeInsetsGeometry padding;

  /// Margin applied specifically to each tab item / indicator pill.
  final EdgeInsetsGeometry itemMargin;

  /// Background color of the segmented bar track.
  final Color backgroundColor;

  /// Border for the outer segmented bar track.
  final BoxBorder? border;

  /// Border radius for the outer segmented bar track.
  final BorderRadiusGeometry? borderRadius;

  /// Fill color of the sliding pill indicator.
  final Color indicatorColor;

  /// Border for the sliding pill indicator.
  final BoxBorder? indicatorBorder;

  /// Border radius of the sliding pill indicator.
  final BorderRadiusGeometry? indicatorBorderRadius;

  /// Shadows cast by the sliding pill indicator.
  final List<BoxShadow>? indicatorBoxShadow;

  /// Text color for the active item.
  final Color activeTextColor;

  /// Text color for inactive items.
  final Color inactiveTextColor;

  /// Icon color for the active item (defaults to [activeTextColor]).
  final Color? activeIconColor;

  /// Icon color for inactive items (defaults to [inactiveTextColor]).
  final Color? inactiveIconColor;

  /// Custom text style for labels.
  final TextStyle? labelStyle;

  /// Duration of indicator snap animation.
  final Duration animationDuration;

  /// Curve of indicator snap animation.
  final Curve animationCurve;

  const SlidingSegmentedNavbar({
    super.key,
    this.items,
    this.navItems,
    this.customItemBuilder,
    this.currentIndex,
    this.initialIndex = 0,
    this.onTabChanged,
    this.pageController,
    this.tabController,
    this.height = 44.0,
    this.padding = const EdgeInsets.all(4.0),
    this.itemMargin = EdgeInsets.zero,
    this.backgroundColor = const Color(0xFF1B221E),
    this.border,
    this.borderRadius,
    this.indicatorColor = const Color(0xFF0D4A36),
    this.indicatorBorder,
    this.indicatorBorderRadius,
    this.indicatorBoxShadow,
    this.activeTextColor = Colors.white,
    this.inactiveTextColor = const Color(0xFF9EABA2),
    this.activeIconColor,
    this.inactiveIconColor,
    this.labelStyle,
    this.animationDuration = const Duration(milliseconds: 380),
    this.animationCurve = Curves.easeInOutCubic,
  }) : assert(
         items != null || navItems != null || customItemBuilder != null,
         'Must provide either items, navItems, or customItemBuilder',
       );

  int get itemCount => navItems?.length ?? items?.length ?? 0;

  @override
  State<SlidingSegmentedNavbar> createState() => _SlidingSegmentedNavbarState();
}

class _SlidingSegmentedNavbarState extends State<SlidingSegmentedNavbar>
    with TickerProviderStateMixin {
  late int _currentIndex;
  late double _currentPosition;
  late AnimationController _animController;
  late Animation<double> _animation;

  /// Controls the pop-out elevation and scale (0.0 = resting, 1.0 = popped out)
  late AnimationController _popAnimController;

  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = (widget.currentIndex ?? widget.initialIndex).clamp(
      0,
      widget.itemCount > 0 ? widget.itemCount - 1 : 0,
    );
    _currentPosition = _currentIndex.toDouble();

    // Horizontal position snap animation controller
    _animController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _animation = Tween<double>(begin: _currentPosition, end: _currentPosition)
        .animate(
          CurvedAnimation(
            parent: _animController,
            curve: widget.animationCurve,
          ),
        );

    // Pop-out elevation and scale controller
    _popAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _animController.addListener(_onInternalAnimTick);
    _attachExternalListeners();
  }

  void _attachExternalListeners() {
    widget.pageController?.addListener(_onExternalTick);
    widget.tabController?.animation?.addListener(_onExternalTick);
  }

  void _detachExternalListeners() {
    widget.pageController?.removeListener(_onExternalTick);
    widget.tabController?.animation?.removeListener(_onExternalTick);
  }

  void _onInternalAnimTick() {
    if (mounted) {
      setState(() {
        _currentPosition = _animation.value;
      });
    }
  }

  void _onExternalTick() {
    if (!_isDragging && mounted) {
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(covariant SlidingSegmentedNavbar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.pageController != widget.pageController ||
        oldWidget.tabController != widget.tabController) {
      oldWidget.pageController?.removeListener(_onExternalTick);
      oldWidget.tabController?.animation?.removeListener(_onExternalTick);
      _attachExternalListeners();
    }

    if (!_isDragging &&
        widget.currentIndex != null &&
        widget.currentIndex != _currentIndex) {
      final safeTarget = widget.currentIndex!.clamp(
        0,
        widget.itemCount > 0 ? widget.itemCount - 1 : 0,
      );
      _snapTo(safeTarget, widget.itemCount, notify: false);
    }
  }

  @override
  void dispose() {
    _detachExternalListeners();
    _animController.removeListener(_onInternalAnimTick);
    _animController.dispose();
    _popAnimController.dispose();
    super.dispose();
  }

  double _getRenderPosition(int count) {
    if (count <= 1) return 0.0;
    final maxIndex = (count - 1).toDouble();

    if (_isDragging || _animController.isAnimating) {
      return _currentPosition.clamp(0.0, maxIndex);
    }

    final pageCtrl = widget.pageController;
    if (pageCtrl != null &&
        pageCtrl.hasClients &&
        pageCtrl.position.hasContentDimensions) {
      return (pageCtrl.page ?? _currentPosition).clamp(0.0, maxIndex);
    }

    final tabCtrl = widget.tabController;
    if (tabCtrl != null) {
      return (tabCtrl.animation?.value ?? tabCtrl.index.toDouble()).clamp(
        0.0,
        maxIndex,
      );
    }

    return _currentPosition.clamp(0.0, maxIndex);
  }

  void _updatePositionFromTouch(
    double localDx,
    double tabWidth,
    double paddingLeft,
    int count,
  ) {
    if (tabWidth <= 0 || count <= 1) return;
    final touchX = localDx - paddingLeft;
    final maxIndex = (count - 1).toDouble();
    // Instantly center pill directly under the finger's position
    final fractionalPosition = ((touchX - tabWidth / 2) / tabWidth).clamp(
      0.0,
      maxIndex,
    );

    setState(() {
      _currentPosition = fractionalPosition;
    });

    final pageCtrl = widget.pageController;
    if (pageCtrl != null &&
        pageCtrl.hasClients &&
        pageCtrl.position.hasContentDimensions) {
      final targetPageOffset =
          fractionalPosition * pageCtrl.position.viewportDimension;
      pageCtrl.jumpTo(
        targetPageOffset.clamp(
          pageCtrl.position.minScrollExtent,
          pageCtrl.position.maxScrollExtent,
        ),
      );
    }
  }

  void _handleDragDown(
    DragDownDetails details,
    double tabWidth,
    double paddingLeft,
    int count,
  ) {
    if (tabWidth <= 0 || count <= 1) return;

    if (_animController.isAnimating) {
      _animController.stop();
    }

    final touchX = details.localPosition.dx - paddingLeft;
    final maxIndex = (count - 1).toDouble();
    final targetFraction = ((touchX - tabWidth / 2) / tabWidth).clamp(
      0.0,
      maxIndex,
    );

    final start = _currentPosition;
    final distance = (targetFraction - start).abs();

    if (distance > 0.001) {
      final totalMs = widget.animationDuration.inMilliseconds.toDouble();
      final durationMs = (totalMs * (0.65 + 0.35 * distance.clamp(0.0, 1.0)))
          .round()
          .clamp((totalMs * 0.65).round(), totalMs.toInt());

      _animController.duration = Duration(milliseconds: durationMs);
      _animation = Tween<double>(begin: start, end: targetFraction).animate(
        CurvedAnimation(parent: _animController, curve: widget.animationCurve),
      );
      _animController
        ..reset()
        ..forward();
    }
  }

  void _handleDragStart(
    DragStartDetails details,
    double tabWidth,
    double paddingLeft,
    int count,
  ) {
    _isDragging = true;
    // Animate pill pop-out (scale up + lifted shadow) smoothly
    _popAnimController.animateTo(
      1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
    );
  }

  void _handleDragUpdate(
    DragUpdateDetails details,
    double tabWidth,
    double paddingLeft,
    int count,
  ) {
    if (_animController.isAnimating) {
      _animController.stop();
    }
    if (!_isDragging) _isDragging = true;
    _updatePositionFromTouch(
      details.localPosition.dx,
      tabWidth,
      paddingLeft,
      count,
    );
  }

  void _handleDragEnd(DragEndDetails details, int count) {
    _isDragging = false;
    if (count <= 1) return;

    // Settle pill back down smoothly to resting scale & shadow
    _popAnimController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );

    final velocity = details.primaryVelocity ?? 0.0;
    const velocityThreshold = 300.0; // Flick threshold in px/sec
    int targetIndex;

    if (velocity > velocityThreshold) {
      // Fast flick to the right
      targetIndex = (_currentPosition.floor() + 1).clamp(0, count - 1);
    } else if (velocity < -velocityThreshold) {
      // Fast flick to the left
      targetIndex = (_currentPosition.ceil() - 1).clamp(0, count - 1);
    } else {
      // Released slowly: snap to nearest tab
      targetIndex = _currentPosition.round().clamp(0, count - 1);
    }

    _snapTo(targetIndex, count, notify: true);
  }

  void _handleDragCancel(int count) {
    _isDragging = false;
    _popAnimController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
    if (count <= 1) return;
    final targetIndex = _currentPosition.round().clamp(0, count - 1);
    _snapTo(targetIndex, count, notify: true);
  }

  void _handleTapUp(
    TapUpDetails details,
    double tabWidth,
    double paddingLeft,
    int count,
  ) {
    if (tabWidth <= 0 || count <= 1) return;
    final localX = details.localPosition.dx - paddingLeft;
    final targetIndex = (localX / tabWidth).floor().clamp(0, count - 1);
    _snapTo(targetIndex, count, notify: true);
  }

  void _snapTo(int targetIndex, int count, {bool notify = true}) {
    final start = _currentPosition;
    final end = targetIndex.toDouble();

    if (_animController.isAnimating) {
      _animController.stop();
    }

    if ((end - start).abs() < 0.001 && !_animController.isAnimating) {
      _currentIndex = targetIndex;
      if (notify) {
        widget.onTabChanged?.call(targetIndex);
      }
      return;
    }

    final distance = (end - start).abs();
    final totalMs = widget.animationDuration.inMilliseconds.toDouble();
    final durationMs = (totalMs * (0.65 + 0.35 * distance.clamp(0.0, 1.0)))
        .round()
        .clamp((totalMs * 0.65).round(), totalMs.toInt());

    _animController.duration = Duration(milliseconds: durationMs);
    _animation = Tween<double>(begin: start, end: end).animate(
      CurvedAnimation(parent: _animController, curve: widget.animationCurve),
    );

    _animController
      ..reset()
      ..forward();

    _currentIndex = targetIndex;

    if (notify) {
      widget.onTabChanged?.call(targetIndex);
    }

    final pageCtrl = widget.pageController;
    if (pageCtrl != null && pageCtrl.hasClients) {
      pageCtrl.animateToPage(
        targetIndex,
        duration: Duration(milliseconds: durationMs),
        curve: widget.animationCurve,
      );
    } else if (widget.tabController != null) {
      widget.tabController!.animateTo(targetIndex);
    }
  }

  Widget _buildItemContent(BuildContext context, int index, bool isSelected) {
    if (widget.customItemBuilder != null) {
      return widget.customItemBuilder!(context, index, isSelected);
    }

    final effectiveActiveIconColor =
        widget.activeIconColor ?? widget.activeTextColor;
    final effectiveInactiveIconColor =
        widget.inactiveIconColor ?? widget.inactiveTextColor;

    if (widget.navItems != null && index < widget.navItems!.length) {
      final navItem = widget.navItems![index];
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (navItem.icon != null) ...[
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Icon(
                  navItem.icon,
                  size: 21,
                  color: isSelected
                      ? effectiveActiveIconColor
                      : effectiveInactiveIconColor,
                ),
                if (navItem.showBadge)
                  Positioned(
                    top: -1,
                    right: -3,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: navItem.badgeColor ?? const Color(0xFFE5A93C),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.backgroundColor,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
          ],
          Text(
            navItem.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style:
                (widget.labelStyle ??
                        GoogleFonts.plusJakartaSans(fontSize: 10.5))
                    .copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w600,
                      color: isSelected
                          ? widget.activeTextColor
                          : widget.inactiveTextColor,
                      letterSpacing: -0.2,
                    ),
          ),
        ],
      );
    }

    final label = (widget.items != null && index < widget.items!.length)
        ? widget.items![index]
        : '';

    return Center(
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOutCubic,
        style: (widget.labelStyle ?? GoogleFonts.plusJakartaSans(fontSize: 13))
            .copyWith(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected
                  ? widget.activeTextColor
                  : widget.inactiveTextColor,
            ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.itemCount;
    if (count == 0) return const SizedBox.shrink();

    final resolvedPadding = widget.padding.resolve(Directionality.of(context));
    final resolvedItemMargin = widget.itemMargin.resolve(
      Directionality.of(context),
    );
    final effectiveBorderRadius =
        widget.borderRadius ?? BorderRadius.circular(widget.height / 2);

    return Container(
      width: double.infinity,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: effectiveBorderRadius,
        border: widget.border,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth - resolvedPadding.horizontal;
          final tabWidth = totalWidth / count;
          final renderPos = _getRenderPosition(count);

          final indicatorLeft =
              resolvedPadding.left +
              (renderPos * tabWidth) +
              resolvedItemMargin.left;
          final indicatorWidth = (tabWidth - resolvedItemMargin.horizontal)
              .clamp(0.0, double.infinity);
          final indicatorHeight =
              (constraints.maxHeight -
                      resolvedPadding.vertical -
                      resolvedItemMargin.vertical)
                  .clamp(0.0, double.infinity);

          final effectiveIndicatorRadius =
              widget.indicatorBorderRadius ??
              BorderRadius.circular(indicatorHeight / 2);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragDown: (details) =>
                _handleDragDown(details, tabWidth, resolvedPadding.left, count),
            onHorizontalDragStart: (details) => _handleDragStart(
              details,
              tabWidth,
              resolvedPadding.left,
              count,
            ),
            onHorizontalDragUpdate: (details) => _handleDragUpdate(
              details,
              tabWidth,
              resolvedPadding.left,
              count,
            ),
            onHorizontalDragEnd: (details) => _handleDragEnd(details, count),
            onHorizontalDragCancel: () => _handleDragCancel(count),
            onTapUp: (details) =>
                _handleTapUp(details, tabWidth, resolvedPadding.left, count),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Sliding Pill Indicator with Pop-out Scale & Shadow
                Positioned(
                  left: indicatorLeft,
                  top: resolvedPadding.top + resolvedItemMargin.top,
                  width: indicatorWidth,
                  height: indicatorHeight,
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _popAnimController,
                      builder: (context, child) {
                        final popProgress = _popAnimController.value;
                        final scale = 1.0 + (0.10 * popProgress);
                        final shadowProgress = popProgress.clamp(0.0, 1.0);

                        final normalShadow =
                            widget.indicatorBoxShadow ??
                            [
                              BoxShadow(
                                color: widget.indicatorColor.withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ];

                        final liftedShadow = [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.26),
                            blurRadius: 18,
                            offset: const Offset(0, 7),
                            spreadRadius: 1.2,
                          ),
                          BoxShadow(
                            color: widget.indicatorColor.withValues(alpha: 0.50),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                            spreadRadius: 0.5,
                          ),
                        ];

                        final currentShadow = BoxShadow.lerpList(
                          normalShadow,
                          liftedShadow,
                          shadowProgress,
                        );

                        return Transform.scale(
                          scale: scale,
                          alignment: Alignment.center,
                          child: Container(
                            decoration: BoxDecoration(
                              color: widget.indicatorColor,
                              borderRadius: effectiveIndicatorRadius,
                              border: widget.indicatorBorder,
                              boxShadow: currentShadow,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Interactive Labels / Items aligned to the exact same track bounds
                Positioned.fill(
                  left: resolvedPadding.left,
                  right: resolvedPadding.right,
                  top: resolvedPadding.top,
                  bottom: resolvedPadding.bottom,
                  child: Row(
                    children: List.generate(count, (index) {
                      final isSelected = renderPos.round() == index;
                      final semanticsLabel =
                          widget.navItems != null &&
                              index < widget.navItems!.length
                          ? (widget.navItems![index].semanticsLabel ??
                                widget.navItems![index].label)
                          : (widget.items != null &&
                                    index < widget.items!.length
                                ? widget.items![index]
                                : 'Tab $index');

                      return Expanded(
                        child: Semantics(
                          button: true,
                          selected: isSelected,
                          label: semanticsLabel,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: _buildItemContent(
                                context,
                                index,
                                isSelected,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

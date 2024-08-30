import 'package:flutter/material.dart';

/// Flutter widget for displaying fading edges at the start and end of scroll views
class FadingEdgeScrollView extends StatefulWidget {
  /// The child widget that should be wrapped by the fading edge
  final Widget child;

  /// The scroll controller of the child widget
  ///
  /// Look for more documentation at [ScrollView.scrollController]
  final ScrollController scrollController;

  /// Whether the scroll view scrolls in the reading direction.
  ///
  /// Look for more documentation at [ScrollView.reverse]
  final bool reverse;

  /// The axis along which the child view scrolls
  ///
  /// Look for more documentation at [ScrollView.scrollDirection]
  final Axis scrollDirection;

  /// What part of the screen on the start half should be covered by fading edge gradient
  ///
  /// [gradientFractionOnStart] must be 0 <= [gradientFractionOnStart] <= 1
  /// 0 means no gradient, 1 means the gradient on the start half of the widget fully covers it
  final double gradientFractionOnStart;

  /// What part of the screen on the end half should be covered by fading edge gradient
  ///
  /// [gradientFractionOnEnd] must be 0 <= [gradientFractionOnEnd] <= 1
  /// 0 means no gradient, 1 means the gradient on the end half of the widget fully covers it
  final double gradientFractionOnEnd;

  /// Set to true if you want the scrollController passed to the widget to be disposed of when the widget's state is disposed of
  final bool shouldDisposeScrollController;

  const FadingEdgeScrollView._internal({
    Key? key,
    required this.child,
    required this.scrollController,
    required this.reverse,
    required this.scrollDirection,
    required this.gradientFractionOnStart,
    required this.gradientFractionOnEnd,
    required this.shouldDisposeScrollController,
  })  : assert(gradientFractionOnStart >= 0 && gradientFractionOnStart <= 1),
        assert(gradientFractionOnEnd >= 0 && gradientFractionOnEnd <= 1),
        super(key: key);

  /// Constructor for creating [FadingEdgeScrollView] with [ScrollView] as a child
  /// The child must have [ScrollView.controller] set
  factory FadingEdgeScrollView.fromScrollView({
    Key? key,
    required ScrollView child,
    double gradientFractionOnStart = 0.1,
    double gradientFractionOnEnd = 0.1,
    bool shouldDisposeScrollController = false,
  }) {
    final ScrollController? controller = child.controller as ScrollController?;
    if (controller == null) {
      throw Exception("Child must have a controller set");
    }

    return FadingEdgeScrollView._internal(
      key: key,
      child: child,
      scrollController: controller,
      scrollDirection: child.scrollDirection,
      reverse: child.reverse,
      gradientFractionOnStart: gradientFractionOnStart,
      gradientFractionOnEnd: gradientFractionOnEnd,
      shouldDisposeScrollController: shouldDisposeScrollController,
    );
  }

  /// Constructor for creating [FadingEdgeScrollView] with [SingleChildScrollView] as a child
  /// The child must have [SingleChildScrollView.controller] set
  factory FadingEdgeScrollView.fromSingleChildScrollView({
    Key? key,
    required SingleChildScrollView child,
    double gradientFractionOnStart = 0.1,
    double gradientFractionOnEnd = 0.1,
    bool shouldDisposeScrollController = false,
  }) {
    final ScrollController? controller = child.controller as ScrollController?;
    if (controller == null) {
      throw Exception("Child must have a controller set");
    }

    return FadingEdgeScrollView._internal(
      key: key,
      child: child,
      scrollController: controller,
      scrollDirection: child.scrollDirection,
      reverse: child.reverse,
      gradientFractionOnStart: gradientFractionOnStart,
      gradientFractionOnEnd: gradientFractionOnEnd,
      shouldDisposeScrollController: shouldDisposeScrollController,
    );
  }

  /// Constructor for creating [FadingEdgeScrollView] with [PageView] as a child
  /// The child must have [PageView.controller] set
  factory FadingEdgeScrollView.fromPageView({
    Key? key,
    required PageView child,
    double gradientFractionOnStart = 0.1,
    double gradientFractionOnEnd = 0.1,
    bool shouldDisposeScrollController = false,
  }) {
    final ScrollController? controller = child.controller as ScrollController?;
    if (controller == null) {
      throw Exception("Child must have a controller set");
    }

    return FadingEdgeScrollView._internal(
      key: key,
      child: child,
      scrollController: controller,
      scrollDirection: child.scrollDirection,
      reverse: child.reverse,
      gradientFractionOnStart: gradientFractionOnStart,
      gradientFractionOnEnd: gradientFractionOnEnd,
      shouldDisposeScrollController: shouldDisposeScrollController,
    );
  }

  @override
  _FadingEdgeScrollViewState createState() => _FadingEdgeScrollViewState();
}

class _FadingEdgeScrollViewState extends State<FadingEdgeScrollView> {
  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: widget.scrollDirection == Axis.horizontal
              ? Alignment.centerLeft
              : Alignment.topCenter,
          end: widget.scrollDirection == Axis.horizontal
              ? Alignment.centerRight
              : Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(widget.gradientFractionOnStart),
            Colors.black.withOpacity(widget.gradientFractionOnEnd),
            Colors.transparent,
          ],
          stops: [
            0.0,
            widget.gradientFractionOnStart,
            1.0 - widget.gradientFractionOnEnd,
            1.0,
          ],
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    if (widget.shouldDisposeScrollController) {
      widget.scrollController.dispose();
    }
    super.dispose();
  }
}

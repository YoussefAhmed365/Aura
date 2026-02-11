import 'package:flutter/material.dart';

class ScrollingText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextDirection? textDirection;
  final TextAlign? textAlign;
  final bool isMiniPlayer;

  const ScrollingText({super.key, required this.text, this.style, this.textDirection, this.textAlign, this.isMiniPlayer = false});

  @override
  State<ScrollingText> createState() => _ScrollingTextState();
}

class _ScrollingTextState extends State<ScrollingText> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  late Animation<double> _animation;

  bool _needsScrolling = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20), // Speed of one cycle
    );

    // Initial check for scrolling need
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAndAnimate());
  }

  @override
  void didUpdateWidget(ScrollingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _animationController.reset();
      // Wait for layout to update before checking size again
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkAndAnimate());
    }
  }

  void _checkAndAnimate() {
    if (!_scrollController.hasClients) return;

    final double maxScroll = _scrollController.position.maxScrollExtent;

    if (maxScroll > 0) {
      // Text is longer than the container, start animation
      setState(() => _needsScrolling = true);

      // Setup ease-in-out animation that reverses (Infinity loop)
      final CurvedAnimation curvedAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);

      _animation = Tween<double>(begin: 0.0, end: maxScroll).animate(curvedAnimation);

      _animation.addListener(() {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_animation.value);
        }
      });

      // Start the ping-pong animation (Forward -> Backward -> Repeat)
      _animationController.repeat(reverse: true);
    } else {
      // Text fits, no animation needed
      if (_needsScrolling) {
        setState(() => _needsScrolling = false);
        _animationController.stop();
      }
    }
  }

  // Detect if text contains Arabic characters
  bool _isArabic(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine resolved text direction: explicit prop wins, otherwise auto-detect
    final TextDirection resolvedDirection = widget.textDirection ?? (_isArabic(widget.text) ? TextDirection.rtl : TextDirection.ltr);
    Widget resolvedAlign = _isArabic(widget.text)
        ? Align(
            alignment: widget.isMiniPlayer ? Alignment.centerLeft : (_needsScrolling ? Alignment.centerRight : Alignment.center),
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Text(widget.text, style: widget.style, textAlign: TextAlign.center),
            ),
          )
        : Align(
            alignment: widget.isMiniPlayer ? Alignment.centerLeft : (_needsScrolling ? Alignment.centerLeft : Alignment.center),
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Text(widget.text, style: widget.style, textAlign: TextAlign.center),
            ),
          );

    return SizedBox(
      height: 40, // Height constraint to prevent layout shifts
      child: Directionality(textDirection: resolvedDirection, child: resolvedAlign),
    );
  }
}

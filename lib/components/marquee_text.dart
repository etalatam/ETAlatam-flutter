import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final double width;
  final double velocity;
  final Duration pauseAfterRound;
  final double blankSpace;
  final bool autoStart;

  const MarqueeText({
    super.key,
    required this.text,
    this.style,
    required this.width,
    this.velocity = 50.0,
    this.pauseAfterRound = const Duration(seconds: 2),
    this.blankSpace = 50.0,
    this.autoStart = true,
  });

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText> {
  bool _shouldScroll = false;
  String _displayText = '';
  final GlobalKey _marqueeKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _displayText = widget.text;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfScrollNeeded();
    });
  }

  void _checkIfScrollNeeded() {
    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    
    setState(() {
      _shouldScroll = textPainter.width > widget.width;
      if (_shouldScroll) {
        _displayText = widget.text;
      }
    });
  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.style?.fontSize != null 
          ? (widget.style!.fontSize! * 1.5) 
          : 24,
      child: _shouldScroll
          ? Marquee(
              key: _marqueeKey,
              text: _displayText,
              style: widget.style,
              scrollAxis: Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.start,
              blankSpace: widget.blankSpace,
              velocity: widget.velocity,
              pauseAfterRound: widget.pauseAfterRound,
              startPadding: 0,
              accelerationDuration: Duration.zero,
              accelerationCurve: Curves.linear,
              decelerationDuration: Duration.zero,
              decelerationCurve: Curves.linear,
            )
          : Text(
              widget.text,
              style: widget.style,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
    );
  }
}
import 'dart:async';
import 'package:flutter/material.dart';

class UndoRedoButton extends StatefulWidget {
  final Widget icon;
  final VoidCallback onTap;
  final VoidCallback onHold;

  const UndoRedoButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.onHold,
  });

  @override
  State<UndoRedoButton> createState() => _UndoRedoButtonState();
}

class _UndoRedoButtonState extends State<UndoRedoButton> {
  Timer? _initialHoldDelay;
  Timer? _holdRepeatTimer;
  // ignore: unused_field
  bool _isHolding = false;
  bool _holdStarted = false;

  void _handleTapDown(TapDownDetails details) {
    _isHolding = true;
    _holdStarted = false;

    _initialHoldDelay = Timer(const Duration(milliseconds: 400), () {
      _holdStarted = true;
      widget.onHold(); 
      _holdRepeatTimer = Timer.periodic(const Duration(milliseconds: 150), (_) {
        widget.onHold();
      });
    });
  }

  void _handleTapUp(TapUpDetails details) {
    if (!_holdStarted) {
      widget.onTap(); 
    }
    _cancelTimers();
  }

  void _handleTapCancel() {
    _cancelTimers();
  }

  void _cancelTimers() {
    _isHolding = false;
    _initialHoldDelay?.cancel();
    _holdRepeatTimer?.cancel();
    _initialHoldDelay = null;
    _holdRepeatTimer = null;
    _holdStarted = false;
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        borderRadius: BorderRadius.circular(24),
        splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: widget.icon,
        ),
      ),
    );
  }
}



class TransformFlip extends StatelessWidget {
  final bool flipX;
  final bool flipY;
  final Widget child;
  final Alignment alignment;

  const TransformFlip({
    super.key,
    this.flipX = false,
    this.flipY = false,
    required this.child,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final scaleX = flipX ? -1.0 : 1.0;
    final scaleY = flipY ? -1.0 : 1.0;

    return Transform(
      alignment: alignment,
      transform: Matrix4.identity()..scale(scaleX, scaleY),
      child: child,
    );
  }
}


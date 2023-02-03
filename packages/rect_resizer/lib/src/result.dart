import 'enums.dart';
import 'geometry.dart';

class ResizeResult {
  /// The new [Rect] of the node after the resize.
  final Rect newRect;

  /// The old [Rect] of the node before the resize.
  final Rect oldRect;

  /// The [Flip] of the node after the resize.
  final Flip flip;

  /// The [ResizeMode] of the node after the resize.
  final ResizeMode resizeMode;

  /// The delta used to resize the node.
  final Offset delta;

  /// The new [Size] of the node after the resize. Unlike [newRect], this
  /// reflects flip state. For example, if the node is flipped horizontally,
  /// the width of the [newSize] will be negative.
  final Size newSize;

  /// Creates a [ResizeResult] object.
  ResizeResult({
    required this.newRect,
    required this.oldRect,
    required this.flip,
    required this.resizeMode,
    required this.delta,
    required this.newSize,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ResizeResult &&
        other.newRect == newRect &&
        other.oldRect == oldRect &&
        other.flip == flip &&
        other.resizeMode == resizeMode &&
        other.delta == delta &&
        other.newSize == newSize;
  }

  @override
  int get hashCode =>
      Object.hash(newRect, oldRect, flip, resizeMode, delta, newSize);

  @override
  String toString() {
    return 'ResizeResult(newRect: $newRect, oldRect: $oldRect, flip: $flip, resizeMode: $resizeMode, delta: $delta, newSize: $newSize)';
  }
}
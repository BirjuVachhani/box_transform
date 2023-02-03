import 'enums.dart';
import 'geometry.dart';
import 'result.dart';

/// main entry point.
class RectResizer {
  ResizeResult resize({
    required Rect initialRect,
    required Offset initialLocalPosition,
    required Offset localPosition,
    required HandlePosition handle,
    required ResizeMode resizeMode,
    required Flip initialFlip,
  }) {
    final Flip currentFlip =
        getFlipForRect(initialRect, localPosition, handle, resizeMode);

    Offset delta = localPosition - initialLocalPosition;

    if (resizeMode.hasSymmetry) delta = delta.scale(2, 2);

    final Size newSize = _calculateNewSize(
      initialRect,
      handle,
      delta,
      currentFlip,
      resizeMode,
    );
    double newWidth = newSize.width.abs();
    double newHeight = newSize.height.abs();
    final Rect newRect;

    if (resizeMode.hasSymmetry) {
      newRect = Rect.fromCenter(
          center: initialRect.center, width: newWidth, height: newHeight);
    } else {
      Rect rect = Rect.fromLTWH(
        handle.isLeft ? initialRect.right - newWidth : initialRect.left,
        handle.isTop ? initialRect.bottom - newHeight : initialRect.top,
        newWidth,
        newHeight,
      );
      newRect = flipRect(rect, currentFlip, handle);
    }

    return ResizeResult(
      newRect: newRect,
      oldRect: initialRect,
      flip: currentFlip * initialFlip,
      resizeMode: resizeMode,
      delta: delta,
      newSize: newSize,
    );
  }

  /// Flips the given [rect] with given [flip] with [handle] being the
  /// pivot point.
  Rect flipRect(Rect rect, Flip flip, HandlePosition handle) {
    switch (handle) {
      case HandlePosition.topLeft:
        return rect.translate(flip.isHorizontal ? rect.width : 0,
            flip.isVertical ? rect.height : 0);
      case HandlePosition.topRight:
        return rect.translate(flip.isHorizontal ? -rect.width : 0,
            flip.isVertical ? rect.height : 0);
      case HandlePosition.bottomLeft:
        return rect.translate(flip.isHorizontal ? rect.width : 0,
            flip.isVertical ? -rect.height : 0);
      case HandlePosition.bottomRight:
        return rect.translate(flip.isHorizontal ? -rect.width : 0,
            flip.isVertical ? -rect.height : 0);
    }
  }

  /// Calculates flip state of the given [rect] w.r.t [localPosition] and
  /// [handle]. It uses [handle] and [localPosition] to determine the quadrant
  /// of the [rect] and then checks if the [rect] is flipped in that quadrant.
  Flip getFlipForRect(
    Rect rect,
    Offset localPosition,
    HandlePosition handle,
    ResizeMode resizeMode,
  ) {
    final double widthFactor = resizeMode.hasSymmetry ? 0.5 : 1;
    final double heightFactor = resizeMode.hasSymmetry ? 0.5 : 1;

    final double effectiveWidth = rect.width * widthFactor;
    final double effectiveHeight = rect.height * heightFactor;

    final double handleXFactor = handle.isLeft ? -1 : 1;
    final double handleYFactor = handle.isTop ? -1 : 1;

    final double posX = effectiveWidth + localPosition.dx * handleXFactor;
    final double posY = effectiveHeight + localPosition.dy * handleYFactor;

    return Flip.fromValue(posX, posY);
  }

  Size _calculateNewSize(
    Rect initialRect,
    HandlePosition handle,
    Offset delta,
    Flip flip,
    ResizeMode resizeMode,
  ) {
    final aspectRatio = initialRect.width / initialRect.height;
    final double newWidth;
    final double newHeight;

    initialRect = flipRect(initialRect, flip, handle);
    Rect rect;
    rect = Rect.fromLTRB(
      initialRect.left + (handle.isLeft ? delta.dx : 0),
      initialRect.top + (handle.isTop ? delta.dy : 0),
      initialRect.right + (handle.isRight ? delta.dx : 0),
      initialRect.bottom + (handle.isBottom ? delta.dy : 0),
    );
    if (resizeMode.hasSymmetry) {
      final widthDelta = (initialRect.width - rect.width) / 2;
      final heightDelta = (initialRect.height - rect.height) / 2;
      rect = Rect.fromLTRB(
        initialRect.left + widthDelta,
        initialRect.top + heightDelta,
        initialRect.right - widthDelta,
        initialRect.bottom - heightDelta,
      );
    }

    final newAspectRatio = rect.width / rect.height;

    if (resizeMode.isScalable) {
      if (newAspectRatio.abs() < aspectRatio.abs()) {
        newHeight = rect.height;
        newWidth = newHeight * aspectRatio;
      } else {
        newWidth = rect.width;
        newHeight = newWidth / aspectRatio;
      }
    } else {
      newWidth = rect.width;
      newHeight = rect.height;
    }

    return Size(
      newWidth.abs() * (flip.isHorizontal ? -1 : 1),
      newHeight.abs() * (flip.isVertical ? -1 : 1),
    );
  }
}

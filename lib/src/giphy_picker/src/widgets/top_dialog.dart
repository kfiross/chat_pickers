import 'package:flutter/material.dart';

enum DialogPosition {
  TOP,
  BOTTOM,
}

class PositionedDialog extends StatelessWidget {
  /// Creates a dialog.
  ///
  /// Typically used in conjunction with [showDialog].
  const PositionedDialog({
    Key? key,
    this.backgroundColor,
    this.elevation,
    this.insetAnimationDuration = const Duration(milliseconds: 100),
    this.insetAnimationCurve = Curves.decelerate,
    this.shape,
    this.content,
    this.actions,
    this.title,
    this.position = DialogPosition.TOP,
  }) : super(key: key);

  /// {@template flutter.material.dialog.backgroundColor}
  /// The background color of the surface of this [Dialog].
  ///
  /// This sets the [Material.color] on this [Dialog]'s [Material].
  ///
  /// If `null`, [ThemeData.cardColor] is used.
  /// {@endtemplate}
  final Color? backgroundColor;

  /// {@template flutter.material.dialog.elevation}
  /// The z-coordinate of this [Dialog].
  ///
  /// If null then [DialogTheme.elevation] is used, and if that's null then the
  /// dialog's elevation is 24.0.
  /// {@endtemplate}
  /// {@macro flutter.material.material.elevation}
  final double? elevation;

  /// {@template flutter.material.dialog.insetAnimationDuration}
  /// The duration of the animation to show when the system keyboard intrudes
  /// into the space that the dialog is placed in.
  ///
  /// Defaults to 100 milliseconds.
  /// {@endtemplate}
  final Duration insetAnimationDuration;

  /// {@template flutter.material.dialog.insetAnimationCurve}
  /// The curve to use for the animation shown when the system keyboard intrudes
  /// into the space that the dialog is placed in.
  ///
  /// Defaults to [Curves.decelerate].
  /// {@endtemplate}
  final Curve insetAnimationCurve;

  /// {@template flutter.material.dialog.shape}
  /// The shape of this dialog's border.
  ///
  /// Defines the dialog's [Material.shape].
  ///
  /// The default shape is a [RoundedRectangleBorder] with a radius of 2.0.
  /// {@endtemplate}
  final ShapeBorder? shape;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.child}
  final Widget? content;

  final List<Widget>? actions;

  final Widget? title;

  final DialogPosition position;

  static const RoundedRectangleBorder _defaultDialogShape =
      RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4.0)));
  static const double _defaultElevation = 24.0;

  @override
  Widget build(BuildContext context) {
    final DialogTheme dialogTheme = DialogTheme.of(context);

    Widget? actionsWidget;
    if (actions != null)
      actionsWidget = Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: ButtonBar(
            children: actions!,
          ),
        ),
      );

    AlignmentGeometry? alignment;
    switch (position) {
      case DialogPosition.TOP:
        alignment = Alignment.topCenter;
        break;
      case DialogPosition.BOTTOM:
        alignment = Alignment.bottomCenter;
        break;
    }

    return AnimatedPadding(
      padding: MediaQuery.of(context).viewInsets +
          const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      duration: insetAnimationDuration,
      curve: insetAnimationCurve,
      child: MediaQuery.removeViewInsets(
        removeLeft: true,
        removeTop: true,
        removeRight: true,
        removeBottom: false,
        context: context,
        child: Container(
          alignment: alignment,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                child: Material(
                    color: backgroundColor ??
                        dialogTheme.backgroundColor ??
                        Theme.of(context).dialogBackgroundColor,
                    elevation:
                        elevation ?? dialogTheme.elevation ?? _defaultElevation,
                    shape: shape ?? dialogTheme.shape ?? _defaultDialogShape,
                    type: MaterialType.card,
                    child: Column(
                      // todo: fix this
                    //   children: <Widget>[
                    //     Container(
                    //             child: title,
                    //             margin: const EdgeInsets.only(
                    //                 top: 10, bottom: 18)) ??
                    //         Container(),
                    //     content,
                    //     actionsWidget ?? Container()
                    //   ]) as List<Widget>,
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class RoundIconButton extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final double size;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final double? iconSize;

  final Widget label;

  RoundIconButton.large(
      this.icon, {this.iconColor, this.onPressed, this.backgroundColor, this.iconSize})
      : size = 60.0,
        label = Container();

  RoundIconButton.small(
      this.icon, {this.iconColor, this.onPressed, this.backgroundColor, this.iconSize})
      : size = 50.0,
        label = Container();

  RoundIconButton(
      this.icon, {this.iconColor, this.size = 50.0, this.onPressed, this.backgroundColor, this.iconSize})
      : label = Container();

  RoundIconButton.label(
      this.icon, {
        this.iconColor,
      this.size = 50.0,
      this.onPressed,
      this.backgroundColor,
      this.iconSize,
      required this.label});

  @override
  Widget build(BuildContext context) {
    var _iconColor = onPressed!=null ?
        (iconColor ?? Colors.white) :
        (iconColor?.withOpacity(0.3) ?? Colors.grey);


    return Container(
      width: size,
      height: size,
//      decoration: BoxDecoration(
//        shape: BoxShape.circle,
//        color: backgroundColor ?? Colors.black,
//        boxShadow: <BoxShadow>[
//          BoxShadow(
//            color: Colors.grey.withOpacity(0.1),
//            blurRadius: 1,
//            offset: Offset(0, 2),
//          ),
//        ],
//      ),
//      child: RawMaterialButton(
//        shape: CircleBorder(),
//        elevation: 15.0,
//        child: Icon(
//          icon,
//          color: iconColor,
//        ),
//        onPressed: onPressed,
//      ),
      child: RaisedButton(
        padding: const EdgeInsets.all(0),
        shape: CircleBorder(),
        color: backgroundColor ?? Colors.white,
        elevation: 5.0,
        child: label == null
            ? Icon(icon, color: _iconColor, size: iconSize ?? size * 0.5)
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(icon, color: _iconColor, size: iconSize ?? size * 0.5),
                  label,
                ],
              ),
        onPressed: onPressed,
      ),
    );
  }
}

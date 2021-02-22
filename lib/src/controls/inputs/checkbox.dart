import 'package:flutter/rendering.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:fluentui_icons/fluentui_icons.dart';

class Checkbox extends StatelessWidget {
  const Checkbox({
    Key key,
    @required this.checked,
    @required this.onChanged,
    this.style,
    this.semanticsLabel,
    this.focusNode,
  }) : super(key: key);

  final bool checked;
  final ValueChanged<bool> onChanged;

  final CheckboxStyle style;

  final String semanticsLabel;

  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    debugCheckHasFluentTheme(context);
    final style = context.theme.checkboxStyle.copyWith(this.style);
    final double size = 22;
    return HoverButton(
      semanticsLabel: semanticsLabel,
      margin: style.margin,
      focusNode: focusNode,
      cursor: (_, state) => style.cursor?.call(state),
      onPressed: onChanged == null
          ? null
          : () => onChanged(checked == null ? null : !checked),
      builder: (context, state) {
        return AnimatedContainer(
          alignment: Alignment.center,
          duration: style.animationDuration,
          curve: style.animationCurve,
          padding: style.padding,
          height: size,
          width: size,
          decoration: () {
            if (checked == null)
              return style.thirdstateDecoration(state);
            else if (checked)
              return style.checkedDecoration(state);
            else
              return style.uncheckedDecoration(state);
          }(),
          child: Icon(
            style.icon,
            size: 18,
            color: () {
              if (checked == null)
                return style.thirdstateIconColor(state);
              else if (checked)
                return style.checkedIconColor(state);
              else
                return style.uncheckedIconColor(state);
            }(),
          ),
        );
      },
    );
  }
}

class CheckboxStyle {
  final ButtonState<Decoration> checkedDecoration;
  final ButtonState<Decoration> uncheckedDecoration;
  final ButtonState<Decoration> thirdstateDecoration;

  final IconData icon;
  final ButtonState<Color> checkedIconColor;
  final ButtonState<Color> uncheckedIconColor;
  final ButtonState<Color> thirdstateIconColor;

  final ButtonState<MouseCursor> cursor;

  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  final Duration animationDuration;
  final Curve animationCurve;

  const CheckboxStyle({
    this.checkedDecoration,
    this.uncheckedDecoration,
    this.thirdstateDecoration,
    this.cursor,
    this.padding,
    this.margin,
    this.icon,
    this.checkedIconColor,
    this.uncheckedIconColor,
    this.thirdstateIconColor,
    this.animationDuration,
    this.animationCurve,
  });

  static CheckboxStyle defaultTheme(Style style, [Brightness brightness]) {
    final radius = BorderRadius.circular(3);
    final Color accent = style.accentColor ?? Colors.blue;
    final Color unselected = () {
      if (brightness == null || brightness == Brightness.light)
        return Colors.black;
      return Colors.white;
    }();
    return CheckboxStyle(
      cursor: buttonCursor,
      checkedDecoration: (state) => BoxDecoration(
        borderRadius: radius,
        color: inputColor(accent, state),
        border: Border.all(style: BorderStyle.none),
      ),
      uncheckedDecoration: (state) => BoxDecoration(
        border: Border.all(
          width: 0.6,
          color: state.isDisabled ? kDefaultButtonDisabledColor : unselected,
        ),
        color: Colors.transparent,
        borderRadius: radius,
      ),
      thirdstateDecoration: (state) => BoxDecoration(
        borderRadius: radius,
        border: Border.all(width: 6.5, color: inputColor(accent, state)),
      ),
      checkedIconColor: (_) => Colors.white,
      uncheckedIconColor: (state) {
        if (state.isHovering || state.isPressing)
          return unselected.withOpacity(0.8);
        return Colors.transparent;
      },
      thirdstateIconColor: (_) => Colors.transparent,
      margin: EdgeInsets.all(4),
      icon: FluentSystemIcons.ic_fluent_checkmark_regular,
      animationDuration: Duration(milliseconds: 200),
      animationCurve: Curves.linear,
    );
  }

  CheckboxStyle copyWith(CheckboxStyle style) {
    if (style == null) return this;
    return CheckboxStyle(
      margin: style?.margin ?? margin,
      padding: style?.padding ?? padding,
      cursor: style?.cursor ?? cursor,
      icon: style?.icon ?? icon,
      checkedIconColor: style?.checkedIconColor ?? checkedIconColor,
      uncheckedIconColor: style?.uncheckedIconColor ?? uncheckedIconColor,
      animationCurve: style?.animationCurve ?? animationCurve,
      animationDuration: style?.animationDuration ?? animationDuration,
      checkedDecoration: style?.checkedDecoration ?? checkedDecoration,
      uncheckedDecoration: style?.uncheckedDecoration ?? uncheckedDecoration,
      thirdstateDecoration: style?.thirdstateDecoration ?? thirdstateDecoration,
      thirdstateIconColor: style?.thirdstateIconColor ?? thirdstateIconColor,
    );
  }
}

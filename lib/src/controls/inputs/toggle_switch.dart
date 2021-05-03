import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

/// The toggle switch represents a physical switch that allows users to
/// turn things on or off, like a light switch. Use toggle switch controls
/// to present users with two mutually exclusive options (such as on/off),
/// where choosing an option provides immediate results.
///
/// Use a toggle switch for binary operations that take effect right after
/// the user flips the toggle switch
///
/// ![ToggleSwitch Preview](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/toggleswitches01.png)
///
/// Think of the toggle switch as a physical power switch for a device: you
/// flip it on or off when you want to enable or disable the action performed
/// by the device.
///
/// See also:
///   - [Checkbox]
///   - [RadioButton]
///   - [ToggleButton]
///   - [RadioButton]
class ToggleSwitch extends StatefulWidget {
  /// Creates a toggle switch.
  const ToggleSwitch({
    Key? key,
    required this.checked,
    required this.onChanged,
    this.style,
    this.semanticLabel,
    this.thumb,
    this.focusNode,
    this.autofocus = false,
  }) : super(key: key);

  /// Whether the [ToggleSwitch] is checked
  final bool checked;

  /// Called when the value of the [ToggleSwitch] should change.
  ///
  /// This callback passes a new value, but doesn't update its state
  /// internally.
  ///
  /// If this callback is null, the ToggleSwitch is disabled.
  final ValueChanged<bool>? onChanged;

  /// The thumb of this [ToggleSwitch]. If this is null, defaults to [DefaultToggleSwitchThumb]
  final Widget? thumb;

  /// The style of this [ToggleSwitch].
  ///
  /// This style is mescled with [ThemeData.toggleSwitchThemeData]
  final ToggleSwitchThemeData? style;

  /// The `semanticLabel` of this [ToggleSwitch]
  final String? semanticLabel;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagProperty(
      'checked',
      value: checked,
      ifFalse: 'unchecked',
    ));
    properties.add(ObjectFlagProperty(
      'onChanged',
      onChanged,
      ifNull: 'disabled',
    ));
    properties.add(FlagProperty(
      'autofocus',
      value: autofocus,
      ifFalse: 'manual focus',
    ));
    properties.add(DiagnosticsProperty<ToggleSwitchThemeData>('style', style));
    properties.add(StringProperty('semanticLabel', semanticLabel));
    properties.add(ObjectFlagProperty<FocusNode>.has('focusNode', focusNode));
  }

  @override
  _ToggleSwitchState createState() => _ToggleSwitchState();
}

class _ToggleSwitchState extends State<ToggleSwitch> {
  bool get isDisabled => widget.onChanged == null;

  Alignment? _alignment;

  void _handleAlignmentChanged(
      Offset localPosition, double sliderGestureWidth) {
    setState(() {
      _alignment = Alignment(
        (localPosition.dx / sliderGestureWidth).clamp(-1, 1),
        0,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final style = ToggleSwitchThemeData.standard(context.theme).copyWith(
      context.theme.toggleSwitchTheme.copyWith(this.widget.style),
    );
    final sliderGestureWidth = 45.0 + (style.padding?.horizontal ?? 0.0);
    return HoverButton(
      autofocus: widget.autofocus,
      semanticLabel: widget.semanticLabel,
      margin: style.margin,
      focusNode: widget.focusNode,
      cursor: style.cursor,
      onPressed: isDisabled ? null : () => widget.onChanged!(!widget.checked),
      onHorizontalDragStart: (e) {
        if (isDisabled) return;
        _handleAlignmentChanged(e.localPosition, sliderGestureWidth);
      },
      onHorizontalDragUpdate: (e) {
        if (isDisabled) return;
        _handleAlignmentChanged(e.localPosition, sliderGestureWidth);
      },
      onHorizontalDragEnd: (e) {
        if (isDisabled) return;
        if (_alignment != null) {
          if (_alignment!.x >= 0.5) {
            widget.onChanged!(true);
          } else {
            widget.onChanged!(false);
          }
          setState(() => _alignment = null);
        }
      },
      builder: (context, state) {
        Widget child = AnimatedContainer(
          alignment: _alignment ??
              (widget.checked ? Alignment.centerRight : Alignment.centerLeft),
          height: 20,
          width: 45,
          duration: style.animationDuration ?? Duration.zero,
          curve: style.animationCurve ?? Curves.linear,
          padding: style.padding,
          decoration: widget.checked
              ? style.checkedDecoration?.call(state)
              : style.uncheckedDecoration?.call(state),
          child: widget.thumb ??
              DefaultToggleSwitchThumb(
                checked: widget.checked,
                style: style,
                state: state,
              ),
        );
        return Semantics(
          child: FocusBorder(
            child: child,
            focused: state.isFocused,
          ),
          checked: widget.checked,
        );
      },
    );
  }
}

class DefaultToggleSwitchThumb extends StatelessWidget {
  const DefaultToggleSwitchThumb({
    Key? key,
    required this.checked,
    required this.style,
    required this.state,
  }) : super(key: key);

  final bool checked;
  final ToggleSwitchThemeData? style;
  final ButtonStates state;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: style?.animationDuration ?? Duration.zero,
      curve: style?.animationCurve ?? Curves.linear,
      constraints: BoxConstraints(
        minHeight: 8,
        minWidth: 8,
        maxHeight: 12,
        maxWidth: 12,
      ),
      decoration: checked
          ? style?.checkedThumbDecoration?.call(state)
          : style?.uncheckedThumbDecoration?.call(state),
    );
  }
}

@immutable
class ToggleSwitchThemeData with Diagnosticable {
  final ButtonState<Decoration>? checkedThumbDecoration;
  final ButtonState<Decoration>? uncheckedThumbDecoration;

  final ButtonState<MouseCursor>? cursor;

  final ButtonState<Decoration>? checkedDecoration;
  final ButtonState<Decoration>? uncheckedDecoration;

  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  final Duration? animationDuration;
  final Curve? animationCurve;

  const ToggleSwitchThemeData({
    this.cursor,
    this.padding,
    this.margin,
    this.animationDuration,
    this.animationCurve,
    this.checkedThumbDecoration,
    this.uncheckedThumbDecoration,
    this.checkedDecoration,
    this.uncheckedDecoration,
  });

  factory ToggleSwitchThemeData.standard(ThemeData style) {
    final defaultThumbDecoration = BoxDecoration(shape: BoxShape.circle);

    final defaultDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(30),
    );

    return ToggleSwitchThemeData(
      cursor: style.inputMouseCursor,
      checkedDecoration: (state) => defaultDecoration.copyWith(
        color: ButtonThemeData.checkedInputColor(style, state),
        border: Border.all(style: BorderStyle.none),
      ),
      uncheckedDecoration: (state) {
        return defaultDecoration.copyWith(
          color: ButtonThemeData.uncheckedInputColor(style, state),
          border: Border.all(
            width: 0.8,
            color: state.isNone || state.isFocused
                ? style.inactiveColor
                : ButtonThemeData.uncheckedInputColor(style, state),
          ),
        );
      },
      padding: EdgeInsets.symmetric(horizontal: 3, vertical: 4),
      margin: EdgeInsets.all(4),
      animationDuration: style.fastAnimationDuration,
      animationCurve: style.animationCurve,
      checkedThumbDecoration: (_) => defaultThumbDecoration.copyWith(color: () {
        if (style.brightness == Brightness.light)
          return style.activeColor;
        else
          return style.inactiveColor;
      }()),
      uncheckedThumbDecoration: (_) => defaultThumbDecoration.copyWith(
        color: style.inactiveColor,
      ),
    );
  }

  ToggleSwitchThemeData copyWith(ToggleSwitchThemeData? style) {
    return ToggleSwitchThemeData(
      margin: style?.margin ?? margin,
      padding: style?.padding ?? padding,
      cursor: style?.cursor ?? cursor,
      animationCurve: style?.animationCurve ?? animationCurve,
      animationDuration: style?.animationDuration ?? animationDuration,
      checkedThumbDecoration:
          style?.checkedThumbDecoration ?? checkedThumbDecoration,
      uncheckedThumbDecoration:
          style?.uncheckedThumbDecoration ?? uncheckedThumbDecoration,
      checkedDecoration: style?.checkedDecoration ?? checkedDecoration,
      uncheckedDecoration: style?.uncheckedDecoration ?? uncheckedDecoration,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry?>('margin', margin));
    properties
        .add(DiagnosticsProperty<EdgeInsetsGeometry?>('padding', padding));
    properties.add(ObjectFlagProperty<ButtonState<MouseCursor>?>.has(
      'cursor',
      cursor,
    ));
    properties
        .add(DiagnosticsProperty<Curve?>('animationCurve', animationCurve));
    properties.add(
        DiagnosticsProperty<Duration?>('animationDuration', animationDuration));
    properties.add(ObjectFlagProperty<ButtonState<Decoration>?>.has(
      'checkedDecoration',
      checkedDecoration,
    ));
    properties.add(ObjectFlagProperty<ButtonState<Decoration>?>.has(
      'uncheckedDecoration',
      uncheckedDecoration,
    ));
    properties.add(ObjectFlagProperty<ButtonState<Decoration>?>.has(
      'checkedThumbDecoration',
      checkedThumbDecoration,
    ));
    properties.add(ObjectFlagProperty<ButtonState<Decoration>?>.has(
      'uncheckedThumbDecoration',
      uncheckedThumbDecoration,
    ));
  }
}

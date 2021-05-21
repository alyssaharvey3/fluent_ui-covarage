part of 'view.dart';

const _kCompactNavigationPanelWidth = 50.0;
const _kOpenNavigationPanelWidth = 320.0;

/// You can use the PaneDisplayMode property to configure different
/// navigation styles, or display modes, for the NavigationView
///
/// ![Display Modes](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/displaymode-auto.png)
enum PaneDisplayMode {
  /// The pane is positioned above the content.
  ///
  /// Use top navigation when:
  ///   * You have 5 or fewer top-level navigation categories that
  ///     are equally important, and any additional top-level navigation
  ///     categories that end up in the dropdown overflow menu are
  ///     considered less important.
  ///   * You need to show all navigation options on screen.
  ///   * You want more space for your app content.
  ///   * Icons cannot clearly describe your app's navigation categories.
  ///
  /// ![Top Display Mode](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/displaymode-top.png)
  top,

  /// The pane is expanded and positioned to the left of the content.
  ///
  /// Use open navigation when:
  ///   * You have 5-10 equally important top-level navigation categories.
  ///   * You want navigation categories to be very prominent, with less
  ///     space for other app content.
  ///
  /// ![Open Display Mode](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/displaymode-left.png)
  open,

  /// The pane shows only icons until opened and is positioned to the left
  /// of the content.
  ///
  /// ![Compact Display Mode](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/displaymode-leftcompact.png)
  compact,

  /// Only the menu button is shown until the pane is opened. When opened,
  /// it's positioned to the left of the content.
  ///
  /// ![Minimal Display Mode](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/displaymode-leftminimal.png)
  minimal,

  /// Let the [NavigationPane] decide what display mode should be used
  /// based on the width. This is used by default on [NavigationPanel].
  /// In Auto mode, the [NavigationPane] adapts between [minimal] when
  /// the window is narrow, to [compact], and then [open] as the window
  /// gets wider.
  ///
  /// ![Automatic Display Mode](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/displaymode-auto.png)
  auto,
}

class NavigationPaneItem with Diagnosticable {
  final GlobalKey itemKey = GlobalKey();

  NavigationPaneItem();
}

/// The item used by [NavigationView] to display the tiles.
///
/// On [PaneDisplayMode.compact], only [item] is displayed, and [title] is
/// used as a tooltip. On the other display modes, [item] and [title] are
/// displayed in a [Row].
///
/// See also:
///   * [PaneItemSeparator], used to group navigation items
///   * [PaneItemHeader], used to label groups of items.
class PaneItem extends NavigationPaneItem {
  /// Creates a pane item.
  PaneItem({required this.icon, this.title = ''});

  /// The title used by this item. If the display mode is top
  /// or compact, this is shown as a tooltip. If it's open, this
  /// is shown by the side of the [icon].
  ///
  /// The text style is fetched from the closest [NavigationPaneThemeData]
  ///
  /// This is also used by [Semantics] to allow screen readers to
  /// read the screen.
  final String title;

  /// The icon used by this item.
  ///
  /// Usually an [Icon] widget
  final Widget icon;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('title', title, ifEmpty: 'no title'));
  }

  static Widget buildPaneItemButton(
    BuildContext context,
    PaneItem item,
    PaneDisplayMode displayMode,
    bool selected,
    VoidCallback onPressed, {
    bool showTextOnTop = true,
  }) {
    assert(displayMode != PaneDisplayMode.auto);
    final bool isTop = displayMode == PaneDisplayMode.top;
    final bool isCompact = displayMode == PaneDisplayMode.compact;
    final bool isOpen =
        [PaneDisplayMode.open, PaneDisplayMode.minimal].contains(displayMode);
    final style = NavigationPaneThemeData.of(context);

    Widget result = SizedBox(
      key: item.itemKey,
      height: !isTop ? 41.0 : null,
      width: isCompact ? _kCompactNavigationPanelWidth : null,
      child: HoverButton(
        onPressed: onPressed,
        cursor: style.cursor,
        builder: (context, state) {
          final textStyle = selected
              ? style.selectedTextStyle!(state)
              : style.unselectedTextStyle!(state);
          final textResult = item.title.isNotEmpty
              ? Padding(
                  padding: style.labelPadding ?? EdgeInsets.zero,
                  child: Text(item.title, style: textStyle),
                )
              : SizedBox.shrink();
          Widget child = Flex(
            direction: isTop ? Axis.vertical : Axis.horizontal,
            textDirection: isTop ? ui.TextDirection.ltr : ui.TextDirection.rtl,
            children: [
              if (isOpen) Expanded(child: textResult),
              () {
                final icon = Padding(
                  padding: style.iconPadding ?? EdgeInsets.zero,
                  child: IconTheme(
                    data: IconThemeData(
                      color: selected
                          ? style.selectedIconColor!(state)
                          : style.unselectedIconColor!(state),
                    ),
                    child: item.icon,
                  ),
                );
                if (isOpen) return icon;
                return Expanded(child: icon);
              }(),
            ],
          );
          if (isTop && showTextOnTop)
            child = Row(mainAxisSize: MainAxisSize.min, children: [
              child,
              textResult,
            ]);
          child = AnimatedContainer(
            duration: style.animationDuration ?? Duration.zero,
            curve: style.animationCurve ?? standartCurve,
            color: style.tileColor?.call(state),
            child: child,
          );
          return Semantics(
            label: item.title,
            selected: selected,
            child: FocusBorder(
              child: child,
              focused: state.isFocused,
              renderOutside: false,
            ),
          );
        },
      ),
    );
    if (((isTop && !showTextOnTop) || isCompact) && item.title.isNotEmpty)
      return Tooltip(message: item.title, child: result);
    return result;
  }
}

/// Separators for grouping navigation items. Set the color property to
/// [Colors.transparent] to render the separator as space. Uses a [Divider]
/// under the hood, consequently uses the closest [DividerThemeData].
///
/// See also:
///   * [PaneItem], the item used by [NavigationView] to render tiles
///   * [PaneItemHeader], used to label groups of items.
class PaneItemSeparator extends NavigationPaneItem {
  /// Creates an item separator.
  PaneItemSeparator({this.color, this.thickness});

  /// The color used by the [Divider].
  final Color? color;

  /// The separator thickness. Defaults to 1.0
  final double? thickness;

  Widget build(BuildContext context, Axis direction) {
    return Divider(
      key: itemKey,
      direction: direction,
      style: DividerThemeData(
        thickness: thickness,
        decoration: color != null ? BoxDecoration(color: color) : null,
        margin: (axis) {
          switch (axis) {
            case Axis.vertical:
              return EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 10.0,
              );
            case Axis.horizontal:
              return EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 10.0,
              );
          }
        },
      ),
    );
  }
}

/// Headers for labeling groups of items. This is not displayed if the display
/// mode is [PaneDisplayMode.compact]
///
/// See also:
///   * [PaneItem], the item used by [NavigationView] to render tiles
///   * [PaneItemSeparator], used to group navigation items
class PaneItemHeader extends NavigationPaneItem {
  /// Creates a pane header.
  PaneItemHeader({required this.header});

  /// The header. The default style is [NavigationPaneThemeData.itemHeaderTextStyle],
  /// but can be overriten by [Text.style].
  ///
  /// Usually a [Text] widget.
  final Widget header;

  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = NavigationPaneThemeData.of(context);
    return Padding(
      key: itemKey,
      padding: theme.iconPadding ?? EdgeInsets.zero,
      child: DefaultTextStyle(
        style: theme.itemHeaderTextStyle ?? TextStyle(),
        child: header,
        softWrap: false,
        maxLines: 1,
        overflow: TextOverflow.fade,
        textAlign: TextAlign.left,
      ),
    );
  }
}

extension ItemsExtension on List<NavigationPaneItem> {
  /// Get the all the item offets in this list
  List<Offset> getPaneItemsOffsets() {
    return map((e) {
      final context = e.itemKey.currentContext;
      if (context == null) return Offset.zero;
      final box = context.findRenderObject()! as RenderBox;
      return box.localToGlobal(Offset.zero);
    }).toList();
  }

  /// Get all the item sizes in this list
  List<Size> getPaneItemsSizes() {
    return map((e) {
      final context = e.itemKey.currentContext;
      if (context == null) return Size.zero;
      final box = context.findRenderObject()! as RenderBox;
      return box.size;
    }).toList();
  }
}

/// The pane used by [NavigationView].
///
/// The [NavigationView] doesn't perform any navigation tasks automatically.
/// When the user taps on a navigation item, [onChanged], if non-null, is called.
///
/// See also:
///   * [NavigationView], used alongside this to navigate through pages
///   * [PaneDisplayMode], that defines how this pane is rendered
///   * [NavigationBody], the widget that implement transitions to the pages
class NavigationPane with Diagnosticable {
  /// Creates a navigation pane.
  ///
  /// If [selected] is non-null, [selected] must be greater or equal to 0
  NavigationPane({
    this.key,
    this.selected,
    this.onChanged,
    this.header,
    this.items = const [],
    this.footerItems = const [],
    this.autoSuggestBox,
    this.autoSuggestBoxReplacement,
    this.displayMode = PaneDisplayMode.auto,
    this.onDisplayModeRequested,
    this.menuButton,
    this.scrollController,
    this.indicatorBuilder = _defaultNavigationIndicator,
  }) : assert(selected == null || selected >= 0);

  final Key? key;

  final GlobalKey paneKey = GlobalKey();

  /// Use this property to customize how the pane will be displayed.
  /// [PaneDisplayMode.auto] is used by default.
  final PaneDisplayMode displayMode;

  /// Whenever the display mode was requested to be changed. This can be
  /// called from [PaneDisplayMode.open] to [PaneDisplayMode.compact], or
  /// vice-versa.
  final ValueChanged<PaneDisplayMode>? onDisplayModeRequested;

  /// The menu button used by this pane. If null and [onDisplayModeRequested]
  /// is null
  final Widget? menuButton;

  /// The header of the pane.
  ///
  /// Usually a [Text] or an [Image].
  ///
  /// ![Top Pane Header](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/navview-freeform-header-top.png)
  /// ![Left Pane Header](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/navview-freeform-header-left.png)
  final Widget? header;

  /// The items used by this panel. These items are displayed before
  /// [autoSuggestBox] and [footerItems].
  ///
  /// Only [PaneItem], [PaneItemSeparator] and [PaneItemHeader] are
  /// accepted types. If other type is detected, an [UnsupportedError]
  /// is thrown.
  final List<NavigationPaneItem> items;

  /// The footer items used by this panel. These items are displayed at
  /// the end of the panel and they can't be overflown.
  ///
  /// Only [PaneItem], [PaneItemSeparator] and [PaneItemHeader] are
  /// accepted types. If other type is detected, an [UnsupportedError]
  /// is thrown.
  ///
  /// | Top | Left |
  /// | --- | --- |
  /// | ![Top Footer](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/navview-freeform-footer-top.png) | ![Left Footer](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/navview-freeform-footer-left.png) |
  final List<NavigationPaneItem> footerItems;

  /// An optional control to allow for app-level search. Usually
  /// an [AutoSuggestBox]
  final Widget? autoSuggestBox;

  /// Used when the current display mode is [PaneDisplayMode.compact]
  /// as a replacement to [autoSuggestBox]. It's only displayed if
  /// [autoSuggestBox] is non-null.
  ///
  /// It's usually an [Icon] with [Icons.search] as the icon.
  final Widget? autoSuggestBoxReplacement;

  /// The current selected index.
  ///
  /// If null, none of the items is selected. If non-null, it must be
  /// a positive number.
  ///
  /// This property is called as the index of [allItems], that means it
  /// must be in the range of 0 to [allItems.length]
  ///
  /// See also:
  ///   * [allItems], a getter that merge [items] + [footerItems] into
  ///     a single list
  final int? selected;

  /// Called when the current index changes.
  final ValueChanged<int>? onChanged;

  /// The scroll controller used by the pane when [displayMode]
  /// is [PaneDisplayMode.compact] and [PaneDisplayMode.open].
  ///
  /// If null, a local scroll controller is created to control
  /// the scrolling and keep the state of the scroll when the
  /// display mode is toggled.
  final ScrollController? scrollController;

  final NavigationIndicatorBuilder indicatorBuilder;

  static Widget _defaultNavigationIndicator({
    required BuildContext context,
    int? index,
    double? y,
    required List<Offset> Function() offsets,
    required List<Size> Function() sizes,
    required Axis axis,
    required Widget child,
  }) {
    if (index == null) return child;
    assert(debugCheckHasFluentTheme(context));
    final theme = NavigationPaneThemeData.of(context);

    final left = theme.iconPadding?.left ?? theme.labelPadding?.left ?? 0;
    final right = theme.labelPadding?.right ?? theme.iconPadding?.right ?? 0;

    return StickyNavigationIndicator(
      index: index,
      offsets: offsets,
      sizes: sizes,
      child: child,
      color: theme.highlightColor,
      curve: theme.animationCurve ?? Curves.linear,
      axis: axis,
      topPadding: EdgeInsets.only(left: left, right: right),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty('displayMode', displayMode));
    properties.add(IterableProperty('items', items));
    properties.add(IterableProperty('footerItems', footerItems));
    properties.add(IntProperty('selected', selected));
    properties
        .add(ObjectFlagProperty('onChanged', onChanged, ifNull: 'disabled'));
    properties.add(DiagnosticsProperty<ScrollController>(
      'scrollController',
      scrollController,
    ));
  }

  /// A list of all of the items displayed on this pane.
  List<NavigationPaneItem> get allItems {
    return items + footerItems;
  }

  List<NavigationPaneItem> get effectiveItems {
    return (allItems..removeWhere((i) => i is! PaneItem));
  }

  /// Check if the provided [item] is selected on not.
  bool isSelected(NavigationPaneItem item) {
    return effectiveIndexOf(item) == selected;
  }

  /// Get the effective index of the navigation pane.
  int effectiveIndexOf(NavigationPaneItem item) {
    return effectiveItems.indexOf(item);
  }

  static Widget buildMenuButton(
    BuildContext context,
    String itemTitle,
    NavigationPane pane, {
    EdgeInsetsGeometry padding = EdgeInsets.zero,
    required VoidCallback onPressed,
  }) {
    if (pane.menuButton != null) return pane.menuButton!;
    if (pane.onDisplayModeRequested != null)
      return Container(
        width: _kCompactNavigationPanelWidth,
        margin: padding,
        child: PaneItem.buildPaneItemButton(
          context,
          PaneItem(title: itemTitle, icon: Icon(Icons.menu)),
          PaneDisplayMode.compact,
          false,
          onPressed,
        ),
      );
    return SizedBox.shrink();
  }
}

double _getIndicatorY(BuildContext context) {
  return NavigationView.of(context).widget.appBar?.height ?? 0;
}

/// Creates a top navigation pane.
///
/// ![Top Pane Anatomy](https://docs.microsoft.com/en-us/windows/uwp/design/controls-and-patterns/images/navview-pane-anatomy-horizontal.png)
class _TopNavigationPane extends StatelessWidget {
  _TopNavigationPane({required this.pane, this.listKey}) : super(key: pane.key);

  final NavigationPane pane;
  final Key? listKey;

  Widget _buildItem(BuildContext context, NavigationPaneItem item) {
    if (item is PaneItemHeader) {
      return item.build(context);
    } else if (item is PaneItemSeparator) {
      return item.build(context, Axis.vertical);
    } else if (item is PaneItem) {
      final selected = pane.isSelected(item);
      return PaneItem.buildPaneItemButton(
        context,
        item,
        pane.displayMode,
        selected,
        () {
          pane.onChanged?.call(pane.effectiveIndexOf(item));
        },
        showTextOnTop: !pane.footerItems.contains(item),
      );
    } else {
      throw UnsupportedError(
        '${item.runtimeType} is not a supported pane item type.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = NavigationPaneThemeData.of(context);
    Widget topBar = Acrylic(
      height: kOneLineTileHeight,
      color: theme.backgroundColor,
      child: pane.indicatorBuilder(
        context: context,
        index: pane.selected,
        offsets: pane.effectiveItems.getPaneItemsOffsets,
        sizes: pane.effectiveItems.getPaneItemsSizes,
        axis: Axis.vertical,
        y: _getIndicatorY(context),
        child: Row(children: [
          Expanded(
            child: Row(children: [
              NavigationAppBar.buildLeading(context, NavigationAppBar()),
              if (pane.header != null)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                  child: pane.header!,
                ),
              Expanded(
                child: Scrollbar(
                  isAlwaysShown: false,
                  // A single child scroll view is used instead of a ListView
                  // because the Row implies the cross axis alignment to center,
                  // but ListView implies to top
                  child: SingleChildScrollView(
                    key: listKey,
                    primary: true,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: pane.items.map((item) {
                        return _buildItem(context, item);
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ]),
          ),
          if (pane.autoSuggestBox != null)
            Container(
              margin: const EdgeInsets.only(left: 50.0),
              constraints: BoxConstraints(
                minWidth: 215.0,
                maxWidth: _kOpenNavigationPanelWidth,
              ),
              child: pane.autoSuggestBox!,
            ),
          ...pane.footerItems.map((item) {
            return _buildItem(context, item);
          }),
        ]),
      ),
    );
    return topBar;
  }
}

class _CompactNavigationPane extends StatelessWidget {
  _CompactNavigationPane({
    required this.pane,
    this.paneKey,
    this.listKey,
  }) : super(key: pane.key);

  final NavigationPane pane;
  final Key? paneKey;
  final Key? listKey;

  Widget _buildItem(BuildContext context, NavigationPaneItem item) {
    assert(debugCheckHasFluentTheme(context));
    if (item is PaneItemHeader) {
      /// Item Header is not visible on compact pane
      return SizedBox();
    } else if (item is PaneItemSeparator) {
      return item.build(context, Axis.horizontal);
    } else if (item is PaneItem) {
      final selected = pane.isSelected(item);
      return PaneItem.buildPaneItemButton(
        context,
        item,
        pane.displayMode,
        selected,
        () {
          pane.onChanged?.call(pane.effectiveIndexOf(item));
        },
      );
    } else {
      throw UnsupportedError(
        '${item.runtimeType} is not a supported pane item type.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = NavigationPaneThemeData.of(context);
    const EdgeInsetsGeometry topPadding = const EdgeInsets.only(bottom: 6.0);
    final bool showReplacement =
        pane.autoSuggestBox != null && pane.autoSuggestBoxReplacement != null;
    return Acrylic(
      key: paneKey,
      width: _kCompactNavigationPanelWidth,
      animationDuration: theme.animationDuration ?? Duration.zero,
      animationCurve: theme.animationCurve ?? Curves.linear,
      color: theme.backgroundColor,
      child: pane.indicatorBuilder(
        context: context,
        index: pane.selected,
        offsets: pane.effectiveItems.getPaneItemsOffsets,
        sizes: pane.effectiveItems.getPaneItemsSizes,
        axis: Axis.horizontal,
        y: _getIndicatorY(context),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          () {
            if (pane.menuButton != null) return pane.menuButton!;
            if (pane.onDisplayModeRequested != null)
              return NavigationPane.buildMenuButton(
                context,
                FluentLocalizations.of(context).openNavigationTooltip,
                pane,
                onPressed: () {
                  pane.onDisplayModeRequested?.call(PaneDisplayMode.open);
                },
                padding: showReplacement ? EdgeInsets.zero : topPadding,
              );
            return SizedBox.shrink();
          }(),
          if (showReplacement)
            Padding(
              padding: topPadding,
              child: PaneItem.buildPaneItemButton(
                context,
                PaneItem(
                  title: FluentLocalizations.of(context).clickToSearch,
                  icon: pane.autoSuggestBoxReplacement!,
                ),
                pane.displayMode,
                false,
                () {
                  pane.onDisplayModeRequested?.call(PaneDisplayMode.open);
                },
              ),
            ),
          Expanded(
            child: Scrollbar(
              isAlwaysShown: false,
              child: ListView(key: listKey, primary: true, children: [
                ...pane.items.map((item) {
                  return _buildItem(context, item);
                }),
              ]),
            ),
          ),
          ...pane.footerItems.map((item) {
            return _buildItem(context, item);
          }),
        ]),
      ),
    );
  }
}

class _OpenNavigationPane extends StatelessWidget {
  _OpenNavigationPane({
    required this.pane,
    this.paneKey,
    this.listKey,
  }) : super(key: pane.key);

  final NavigationPane pane;
  final Key? paneKey;
  final Key? listKey;

  static Widget buildItem(
    BuildContext context,
    NavigationPane pane,
    NavigationPaneItem item, [
    VoidCallback? onChanged,
  ]) {
    if (item is PaneItemHeader) {
      return item.build(context);
    } else if (item is PaneItemSeparator) {
      return item.build(context, Axis.horizontal);
    } else if (item is PaneItem) {
      final selected = pane.isSelected(item);
      return PaneItem.buildPaneItemButton(
        context,
        item,
        pane.displayMode,
        selected,
        () {
          pane.onChanged?.call(pane.effectiveIndexOf(item));
          onChanged?.call();
        },
      );
    } else {
      throw UnsupportedError(
        '${item.runtimeType} is not a supported pane item type.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = NavigationPaneThemeData.of(context);
    const EdgeInsetsGeometry topPadding = const EdgeInsets.only(bottom: 6.0);
    final menuButton = () {
      if (pane.menuButton != null) return pane.menuButton!;
      if (pane.onDisplayModeRequested != null)
        return NavigationPane.buildMenuButton(
          context,
          FluentLocalizations.of(context).closeNavigationTooltip,
          pane,
          onPressed: () {
            pane.onDisplayModeRequested?.call(PaneDisplayMode.compact);
          },
        );
      return SizedBox.shrink();
    }();
    return Acrylic(
      key: paneKey,
      color: theme.backgroundColor,
      width: _kOpenNavigationPanelWidth,
      animationDuration: theme.animationDuration ?? Duration.zero,
      animationCurve: theme.animationCurve ?? Curves.linear,
      child: pane.indicatorBuilder(
        context: context,
        index: pane.selected,
        offsets: pane.effectiveItems.getPaneItemsOffsets,
        sizes: pane.effectiveItems.getPaneItemsSizes,
        axis: Axis.horizontal,
        y: _getIndicatorY(context),
        child: Column(children: [
          Container(
            margin: pane.autoSuggestBox != null ? EdgeInsets.zero : topPadding,
            height: kOneLineTileHeight,
            child: () {
              if (pane.header != null)
                return Row(children: [
                  menuButton,
                  Expanded(
                    child: Align(
                      child: pane.header!,
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                ]);
              else
                return menuButton;
            }(),
          ),
          if (pane.autoSuggestBox != null)
            Container(
              padding: theme.iconPadding ?? EdgeInsets.zero,
              height: 41.0,
              alignment: Alignment.center,
              margin: topPadding,
              child: pane.autoSuggestBox!,
            ),
          Expanded(
            child: Scrollbar(
              isAlwaysShown: false,
              child: ListView(key: listKey, primary: true, children: [
                ...pane.items.map((item) {
                  return buildItem(context, pane, item);
                }),
              ]),
            ),
          ),
          ...pane.footerItems.map((item) {
            return buildItem(context, pane, item);
          }),
        ]),
      ),
    );
  }
}

class _MinimalNavigationPane extends StatefulWidget {
  _MinimalNavigationPane({
    required this.pane,
    required this.animationDuration,
    required this.entry,
    this.y = 0,
  }) : super(key: pane.key);

  final NavigationPane pane;

  /// This duration can't be fetched from the theme when the state is
  /// initialized, so it needs to be fetched from the parent
  final Duration animationDuration;

  /// This entry is used to remove the entry from the overlay list
  /// when tapped outside.
  final OverlayEntry entry;

  /// Usually the top bar height
  final double y;

  @override
  __MinimalNavigationPaneState createState() => __MinimalNavigationPaneState();
}

class __MinimalNavigationPaneState extends State<_MinimalNavigationPane>
    with SingleTickerProviderStateMixin<_MinimalNavigationPane> {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget _buildItem(BuildContext context, NavigationPaneItem item) {
    return _OpenNavigationPane.buildItem(
      context,
      widget.pane,
      item,
      removeEntry,
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = NavigationPaneThemeData.of(context);
    const EdgeInsetsGeometry topPadding = const EdgeInsets.only(bottom: 6.0);
    final menuButton = SizedBox(
      width: _kCompactNavigationPanelWidth,
      child: PaneItem.buildPaneItemButton(
        context,
        PaneItem(
          title: FluentLocalizations.of(context).closeNavigationTooltip,
          icon: Icon(Icons.menu),
        ),
        PaneDisplayMode.compact,
        false,
        removeEntry,
      ),
    );
    Widget minimalPane = SizeTransition(
      sizeFactor: CurvedAnimation(
        parent: controller,
        curve: theme.animationCurve ?? Curves.linear,
      ),
      axis: Axis.horizontal,
      child: Acrylic(
        color: theme.backgroundColor,
        width: _kOpenNavigationPanelWidth,
        animationDuration: theme.animationDuration ?? Duration.zero,
        animationCurve: theme.animationCurve ?? Curves.linear,
        child: widget.pane.indicatorBuilder(
          context: context,
          index: widget.pane.selected,
          offsets: widget.pane.effectiveItems.getPaneItemsOffsets,
          sizes: widget.pane.effectiveItems.getPaneItemsSizes,
          axis: Axis.horizontal,
          y: widget.y,
          child: Column(children: [
            Padding(
              padding: widget.pane.autoSuggestBox != null
                  ? EdgeInsets.zero
                  : topPadding,
              child: () {
                if (widget.pane.header != null)
                  return Row(children: [
                    menuButton,
                    Expanded(
                      child: Align(
                        child: widget.pane.header!,
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                  ]);
                else
                  return menuButton;
              }(),
            ),
            if (widget.pane.autoSuggestBox != null)
              Container(
                padding: theme.iconPadding,
                height: 41.0,
                alignment: Alignment.center,
                margin: topPadding,
                child: widget.pane.autoSuggestBox!,
              ),
            Expanded(
              child: Scrollbar(
                isAlwaysShown: false,
                child: ListView(primary: true, children: [
                  ...widget.pane.items.map((item) {
                    return _buildItem(context, item);
                  }),
                ]),
              ),
            ),
            ...widget.pane.footerItems.map((item) {
              return _buildItem(context, item);
            }),
          ]),
        ),
      ),
    );
    return Stack(children: [
      Positioned.fill(
        child: GestureDetector(
          onTap: removeEntry,
          child: AbsorbPointer(
            child: Semantics(
              label: FluentLocalizations.of(context).modalBarrierDismissLabel,
              child: Container(
                constraints: BoxConstraints.expand(),
                color: Colors.black.withOpacity(0.03),
              ),
            ),
          ),
        ),
      ),
      Positioned(top: 0, left: 0, bottom: 0, child: minimalPane),
    ]);
  }

  void removeEntry() async {
    await controller.reverse();
    widget.entry.remove();
  }
}

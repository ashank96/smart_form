// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:smart_form/src/smart_form.dart';

class SmartDropdownButtonFormField<T> extends SmartFormField<T> {
  /// Creates a [DropdownButton] widget that is a [SmartFormField], wrapped in an
  /// [InputDecorator].
  ///
  /// For a description of the `onSaved`, `validator`, or `autovalidate`
  /// parameters, see [SmartFormField]. For the rest (other than [decoration]), see
  /// [DropdownButton].
  ///
  /// The `items`, `elevation`, `iconSize`, `isDense`, `isExpanded`,
  /// `autofocus`, and `decoration`  parameters must not be null.
  SmartDropdownButtonFormField({
    Key key,
    @required List<DropdownMenuItem<T>> items,
    DropdownButtonBuilder selectedItemBuilder,
    T value,
    Widget hint,
    Widget disabledHint,
    @required this.onChanged,
    int elevation = 8,
    TextStyle style,
    Widget icon,
    Color iconDisabledColor,
    Color iconEnabledColor,
    double iconSize = 24.0,
    bool isDense = true,
    bool isExpanded = false,
    double itemHeight,
    Color focusColor,
    FocusNode focusNode,
    bool autofocus = false,
    InputDecoration decoration,
    FormFieldSetter<T> onSaved,
    FormFieldValidator<T> validator,
    bool autovalidate = false,
  })  : assert(
  items == null ||
      items.isEmpty ||
      value == null ||
      items.where((DropdownMenuItem<T> item) {
        return item.value == value;
      }).length ==
          1,
  "There should be exactly one item with [DropdownButton]'s value: "
      '$value. \n'
      'Either zero or 2 or more [DropdownMenuItem]s were detected '
      'with the same value',
  ),
        assert(elevation != null),
        assert(iconSize != null),
        assert(isDense != null),
        assert(isExpanded != null),
        assert(itemHeight == null || itemHeight >= kMinInteractiveDimension),
        assert(autofocus != null),
        decoration = decoration ?? InputDecoration(focusColor: focusColor),
        super(
        key: key,
        onSaved: onSaved,
        initialValue: value,
        validator: validator,
        autovalidate: autovalidate,
        builder: (SmartFormFieldState<T> field) {
          final _DropdownButtonFormFieldState<T> state =
          field as _DropdownButtonFormFieldState<T>;
          final InputDecoration decorationArg =
              decoration ?? InputDecoration(focusColor: focusColor);
          final InputDecoration effectiveDecoration =
          decorationArg.applyDefaults(
            Theme.of(field.context).inputDecorationTheme,
          );
          // An unfocusable Focus widget so that this widget can detect if its
          // descendants have focus or not.
          return Focus(
            canRequestFocus: false,
            skipTraversal: true,
            child: Builder(builder: (BuildContext context) {
              return InputDecorator(
                decoration:
                effectiveDecoration.copyWith(errorText: field.errorText),
                isEmpty: state.value == null,
                isFocused: Focus.of(context).hasFocus,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<T>(
                    items: items,
                    selectedItemBuilder: selectedItemBuilder,
                    value: state.value,
                    hint: hint,
                    disabledHint: disabledHint,
                    onChanged: onChanged == null ? null : state.didChange,
                    elevation: elevation,
                    style: style,
                    icon: icon,
                    iconDisabledColor: iconDisabledColor,
                    iconEnabledColor: iconEnabledColor,
                    iconSize: iconSize,
                    isDense: isDense,
                    isExpanded: isExpanded,
                    itemHeight: itemHeight,
                    focusColor: focusColor,
                    focusNode: focusNode,
                    autofocus: autofocus,
                  ),
                ),
              );
            }),
          );
        },
      );

  /// {@macro flutter.material.dropdownButton.onChanged}
  final ValueChanged<T> onChanged;

  /// The decoration to show around the dropdown button form field.
  ///
  /// By default, draws a horizontal line under the dropdown button field but
  /// can be configured to show an icon, label, hint text, and error text.
  ///
  /// If not specified, an [InputDecorator] with the `focusColor` set to the
  /// supplied `focusColor` (if any) will be used.
  final InputDecoration decoration;

  @override
  SmartFormFieldState<T> createState() => _DropdownButtonFormFieldState<T>();
}

class _DropdownButtonFormFieldState<T> extends SmartFormFieldState<T> {
  @override
  SmartDropdownButtonFormField<T> get widget =>
      super.widget as SmartDropdownButtonFormField<T>;

  @override
  void didChange(T value) {
    super.didChange(value);
    assert(widget.onChanged != null);
    widget.onChanged(value);
  }
}

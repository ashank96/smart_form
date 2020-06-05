// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

/// An optional container for grouping together multiple form field widgets
/// (e.g. [TextField] widgets).
///
/// Each individual form field should be wrapped in a [SmartFormField] widget, with
/// the [SmartForm] widget as a common ancestor of all of those. Call methods on
/// [SmartFormState] to save, reset, or validate each [SmartFormField] that is a
/// descendant of this [SmartForm]. To obtain the [SmartFormState], you may use [SmartForm.of]
/// with a context whose ancestor is the [SmartForm], or pass a [GlobalKey] to the
/// [SmartForm] constructor and call [GlobalKey.currentState].
///
/// {@tool dartpad --template=stateful_widget_scaffold}
/// This example shows a [SmartForm] with one [TextFormField] to enter an email
/// address and a [RaisedButton] to submit the form. A [GlobalKey] is used here
/// to identify the [SmartForm] and validate input.
///
/// ![](https://flutter.github.io/assets-for-api-docs/assets/widgets/form.png)
///
/// ```dart
/// final _formKey = GlobalKey<SmartFormState>();
///
/// @override
/// Widget build(BuildContext context) {
///   return SmartForm(
///     key: _formKey,
///     child: Column(
///       crossAxisAlignment: CrossAxisAlignment.start,
///       children: <Widget>[
///         SmartTextFormField(
///           decoration: const InputDecoration(
///             hintText: 'Enter your email',
///           ),
///           validator: (value) {
///             if (value.isEmpty) {
///               return 'Please enter some text';
///             }
///             return null;
///           },
///         ),
///         Padding(
///           padding: const EdgeInsets.symmetric(vertical: 16.0),
///           child: RaisedButton(
///             onPressed: () {
///               // Validate will return true if the form is valid, or false if
///               // the form is invalid.
///               if (_formKey.currentState.validate()) {
///                 // Process data.
///               }
///             },
///             child: Text('Submit'),
///           ),
///         ),
///       ],
///     ),
///   );
/// }
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [GlobalKey], a key that is unique across the entire app.
///  * [SmartFormField], a single form field widget that maintains the current state.
///  * [SmartTextFormField], a convenience widget that wraps a [TextField] widget in a [SmartFormField].
class SmartForm extends StatefulWidget {
  /// Creates a container for form fields.
  ///
  /// The [child] argument must not be null.
  const SmartForm({
    Key key,
    @required this.child,
    this.autovalidate = false,
    this.onWillPop,
    this.onChanged,
  })  : assert(child != null),
        super(key: key);

  /// Returns the closest [SmartFormState] which encloses the given context.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// SmartFormState form = SmartForm.of(context);
  /// form.save();
  /// ```
  static SmartFormState of(BuildContext context) {
    final _FormScope scope =
    context.dependOnInheritedWidgetOfExactType<_FormScope>();
    return scope?._formState;
  }

  /// The widget below this widget in the tree.
  ///
  /// This is the root of the widget hierarchy that contains this form.
  ///
  /// {@macro flutter.widgets.child}
  final Widget child;

  /// If true, form fields will validate and update their error text
  /// immediately after every change. Otherwise, you must call
  /// [SmartFormState.validate] to validate.
  final bool autovalidate;

  /// Enables the form to veto attempts by the user to dismiss the [ModalRoute]
  /// that contains the form.
  ///
  /// If the callback returns a Future that resolves to false, the form's route
  /// will not be popped.
  ///
  /// See also:
  ///
  ///  * [WillPopScope], another widget that provides a way to intercept the
  ///    back button.
  final WillPopCallback onWillPop;

  /// Called when one of the form fields changes.
  ///
  /// In addition to this callback being invoked, all the form fields themselves
  /// will rebuild.
  final VoidCallback onChanged;

  @override
  SmartFormState createState() => SmartFormState();
}

/// State associated with a [SmartForm] widget.
///
/// A [SmartFormState] object can be used to [save], [reset], and [validate] every
/// [SmartFormField] that is a descendant of the associated [SmartForm].
///
/// Typically obtained via [SmartForm.of].
class SmartFormState extends State<SmartForm> {
  int _generation = 0;
  final Set<SmartFormFieldState<dynamic>> _fields =
  <SmartFormFieldState<dynamic>>{};

  // Called when a form field has changed. This will cause all form fields
  // to rebuild, useful if form fields have interdependencies.
  void _fieldDidChange() {
    if (widget.onChanged != null) {
      widget.onChanged();
    }
    _forceRebuild();
  }

  void _forceRebuild() {
    setState(() {
      ++_generation;
    });
  }

  void _register(SmartFormFieldState<dynamic> field) {
    _fields.add(field);
  }

  void _unregister(SmartFormFieldState<dynamic> field) {
    _fields.remove(field);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.autovalidate) {
      _validate();
    }
    return WillPopScope(
      onWillPop: widget.onWillPop,
      child: _FormScope(
        formState: this,
        generation: _generation,
        child: widget.child,
      ),
    );
  }

  /// Saves every [SmartFormField] that is a descendant of this [SmartForm].
  void save() {
    for (final SmartFormFieldState<dynamic> field in _fields) {
      field.save();
    }
  }

  /// Resets every [SmartFormField] that is a descendant of this [SmartForm] back to its
  /// [SmartFormField.initialValue].
  ///
  /// The [SmartForm.onChanged] callback will be called.
  ///
  /// If the form's [SmartForm.autovalidate] property is true, the fields will all be
  /// revalidated after being reset.
  void reset() {
    for (final SmartFormFieldState<dynamic> field in _fields) {
      field.reset();
    }
    _fieldDidChange();
  }

  /// Validates every [SmartFormField] that is a descendant of this [SmartForm], and
  /// returns true if there are no errors.
  ///
  /// The form will rebuild to report the results.
  bool validate() {
    _forceRebuild();
    return _validate();
  }

  bool _validate() {
    bool hasError = false;
    for (final SmartFormFieldState<dynamic> field in _fields) {
      hasError = !field.validate() || hasError;
    }
    return !hasError;
  }
}

class _FormScope extends InheritedWidget {
  const _FormScope({
    Key key,
    Widget child,
    SmartFormState formState,
    int generation,
  })  : _formState = formState,
        _generation = generation,
        super(key: key, child: child);

  final SmartFormState _formState;

  /// Incremented every time a form field has changed. This lets us know when
  /// to rebuild the form.
  final int _generation;

  /// The [SmartForm] associated with this widget.
  SmartForm get form => _formState.widget;

  @override
  bool updateShouldNotify(_FormScope old) => _generation != old._generation;
}

/// Signature for validating a form field.
///
/// Returns an error string to display if the input is invalid, or null
/// otherwise.
///
/// Used by [SmartFormField.validator].
typedef SmartFormFieldValidator<T> = String Function(T value);

/// Signature for being notified when a form field changes value.
///
/// Used by [SmartFormField.onSaved].
typedef SmartFormFieldSetter<T> = void Function(T newValue);

/// Signature for building the widget representing the form field.
///
/// Used by [SmartFormField.builder].
typedef SmartFormFieldBuilder<T> = Widget Function(
    SmartFormFieldState<T> field);

/// A single form field.
///
/// This widget maintains the current state of the form field, so that updates
/// and validation errors are visually reflected in the UI.
///
/// When used inside a [SmartForm], you can use methods on [SmartFormState] to query or
/// manipulate the form data as a whole. For example, calling [SmartFormState.save]
/// will invoke each [SmartFormField]'s [onSaved] callback in turn.
///
/// Use a [GlobalKey] with [SmartFormField] if you want to retrieve its current
/// state, for example if you want one form field to depend on another.
///
/// A [SmartForm] ancestor is not required. The [SmartForm] simply makes it easier to
/// save, reset, or validate multiple fields at once. To use without a [SmartForm],
/// pass a [GlobalKey] to the constructor and use [GlobalKey.currentState] to
/// save or reset the form field.
///
/// See also:
///
///  * [SmartForm], which is the widget that aggregates the form fields.
///  * [TextField], which is a commonly used form field for entering text.
class SmartFormField<T> extends StatefulWidget {
  /// Creates a single form field.
  ///
  /// The [builder] argument must not be null.
  const SmartFormField({
    Key key,
    @required this.builder,
    this.onSaved,
    this.validator,
    this.initialValue,
    this.autovalidate = false,
    this.enabled = true,
  })  : assert(builder != null),
        super(key: key);

  /// An optional method to call with the final value when the form is saved via
  /// [SmartFormState.save].
  final SmartFormFieldSetter<T> onSaved;

  /// An optional method that validates an input. Returns an error string to
  /// display if the input is invalid, or null otherwise.
  ///
  /// The returned value is exposed by the [SmartFormFieldState.errorText] property.
  /// The [TextFormField] uses this to override the [InputDecoration.errorText]
  /// value.
  ///
  /// Alternating between error and normal state can cause the height of the
  /// [TextFormField] to change if no other subtext decoration is set on the
  /// field. To create a field whose height is fixed regardless of whether or
  /// not an error is displayed, either wrap the  [TextFormField] in a fixed
  /// height parent like [SizedBox], or set the [TextFormField.helperText]
  /// parameter to a space.
  final SmartFormFieldValidator<T> validator;

  /// Function that returns the widget representing this form field. It is
  /// passed the form field state as input, containing the current value and
  /// validation state of this field.
  final SmartFormFieldBuilder<T> builder;

  /// An optional value to initialize the form field to, or null otherwise.
  final T initialValue;

  /// If true, this form field will validate and update its error text
  /// immediately after every change. Otherwise, you must call
  /// [SmartFormFieldState.validate] to validate. If part of a [SmartForm] that
  /// auto-validates, this value will be ignored.
  final bool autovalidate;

  /// Whether the form is able to receive user input.
  ///
  /// Defaults to true. If [autovalidate] is true, the field will be validated.
  /// Likewise, if this field is false, the widget will not be validated
  /// regardless of [autovalidate].
  final bool enabled;

  @override
  SmartFormFieldState<T> createState() => SmartFormFieldState<T>();
}

/// The current state of a [SmartFormField]. Passed to the [SmartFormFieldBuilder] method
/// for use in constructing the form field's widget.
class SmartFormFieldState<T> extends State<SmartFormField<T>> {
  T _value;
  String _errorText;

  /// True when state becomes dirty for the first time, i.e. [ didChange(value) ] is called
  ///
  /// This ensures that [SmartForm.autovalidate] only works once the state is modified at least once
  bool _isStateDirty = false;

  /// The current value of the form field.
  T get value => _value;

  /// The current validation error returned by the [SmartFormField.validator]
  /// callback, or null if no errors have been triggered. This only updates when
  /// [validate] is called.
  String get errorText => _errorText;

  /// True if this field has any validation errors.
  bool get hasError => _errorText != null;

  /// True if the current value is valid.
  ///
  /// This will not set [errorText] or [hasError] and it will not update
  /// error display.
  ///
  /// See also:
  ///
  ///  * [validate], which may update [errorText] and [hasError].
  bool get isValid => widget.validator?.call(_value) == null;

  /// Calls the [SmartFormField]'s onSaved method with the current value.
  void save() {
    if (widget.onSaved != null) {
      widget.onSaved(value);
    }
  }

  /// Resets the field to its initial value.
  void reset() {
    setState(() {
      _isStateDirty = false;
      _value = widget.initialValue;
      _errorText = null;
    });
  }

  /// Calls [SmartFormField.validator] to set the [errorText]. Returns true if there
  /// were no errors.
  ///
  /// See also:
  ///
  ///  * [isValid], which passively gets the validity without setting
  ///    [errorText] or [hasError].
  bool validate() {
    setState(() {
      _validate();
    });
    return !hasError;
  }

  void _validate() {
    if (widget.validator != null) {
      _errorText = widget.validator(_value);
    }
  }

  /// Updates this field's state to the new value. Useful for responding to
  /// child widget changes, e.g. [Slider]'s [Slider.onChanged] argument.
  ///
  /// Triggers the [SmartForm.onChanged] callback and, if the [SmartForm.autovalidate]
  /// field is set, revalidates all the fields of the form.
  void didChange(T value) {
    _isStateDirty = true;
    setState(() {
      _value = value;
    });
    SmartForm.of(context)?._fieldDidChange();
  }

  /// Sets the value associated with this form field.
  ///
  /// This method should be only be called by subclasses that need to update
  /// the form field value due to state changes identified during the widget
  /// build phase, when calling `setState` is prohibited. In all other cases,
  /// the value should be set by a call to [didChange], which ensures that
  /// `setState` is called.
  @protected
  void setValue(T value) {
    _value = value;
  }

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  void deactivate() {
    SmartForm.of(context)?._unregister(this);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    // Only autovalidate if the widget is also enabled and state value has changed at least once
    if (widget.autovalidate && widget.enabled && _isStateDirty) {
      _validate();
    }
    SmartForm.of(context)?._register(this);
    return widget.builder(this);
  }
}
// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:smart_form/smart_form.dart';

void main() {
  testWidgets(
      'autovalidate functions only when state value changes atleast once',
      (WidgetTester tester) async {
    final GlobalKey<SmartFormState> formKey = GlobalKey<SmartFormState>();
    final GlobalKey<SmartFormFieldState<String>> fieldKey =
        GlobalKey<SmartFormFieldState<String>>();
    // Input 2's validator depends on a input 1's value.
    String errorText(String input) => '${fieldKey.currentState.value}/error';

    Widget builder() {
      return MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(devicePixelRatio: 1.0),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Center(
              child: Material(
                child: SmartForm(
                  key: formKey,
                  autovalidate: true,
                  child: ListView(
                    children: <Widget>[
                      SmartTextFormField(
                        key: fieldKey,
                        autovalidate: true,
                        validator: errorText,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    await tester.pumpWidget(builder());

    Future<void> checkErrorText(String testValue) async {
      // state value was not changed yet
      expect(find.text(testValue + '/error'), findsNothing);

      // state value changes now
      await tester.enterText(find.byType(SmartTextFormField).first, testValue);
      await tester.pump();

      //autovalidate functions after state changed at least once
      expect(find.text(testValue + '/error'), findsOneWidget);
      return;
    }

    await checkErrorText('Test');
    await checkErrorText('');
  });

  testWidgets('Multiple SmartTextFormFields communicate',
      (WidgetTester tester) async {
    final GlobalKey<SmartFormState> formKey = GlobalKey<SmartFormState>();
    final GlobalKey<SmartFormFieldState<String>> fieldKey =
        GlobalKey<SmartFormFieldState<String>>();
    // Input 2's validator depends on a input 1's value.
    String errorText(String input) => '${fieldKey.currentState.value}/error';

    Widget builder() {
      return MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(devicePixelRatio: 1.0),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Center(
              child: Material(
                child: SmartForm(
                  key: formKey,
                  autovalidate: true,
                  child: ListView(
                    children: <Widget>[
                      SmartTextFormField(
                        key: fieldKey,
                      ),
                      SmartTextFormField(
                        validator: errorText,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    await tester.pumpWidget(builder());

    Future<void> checkErrorText(String testValue) async {
      await tester.enterText(find.byType(SmartTextFormField).first, testValue);
      await tester.pump();

      //now autovalidate functions only when state value of the field changes at least once
      //hence setting some text to the last SmartTextformField
      await tester.enterText(find.byType(SmartTextFormField).last, testValue);
      await tester.pump();

      // Check for a new Text widget with our error text.
      expect(find.text(testValue + '/error'), findsOneWidget);
      return;
    }

    await checkErrorText('Test');
    await checkErrorText('');
  });
}

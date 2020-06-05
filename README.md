# smart_form
A modified variant package of <b>Form</b> widget in flutter as <b>SmartForm</b>, with freedom of using auto-validation 
feature only when the form field state is changed at least once, opposite to the usual scenario wherein 
the auto validation starts as soon as the Form is initialised, and even if nothing is entered in the form yet. 

This is pretty unwanted behavior for most of the product UX designs, wherein you would only want to validate when the 
user tries to do at least some change in the form field.

This form can be used to wrap any type of widget and use all the default features of the form on them. 
The package also modifies the TextFormField and DropDownButtonFormField for flexibility with auto-validation. 

The package also consists of the required auto validation tests in the test folder.

Looking forward to add more features to the smart_form if required.
Suggestions will be appreciated.

#Related Issues/PRs

A couple of developers including me have already raised some <b>issues/PRs</b> for the same, to the official Flutter git repository, as below:
<a href='https://github.com/flutter/flutter/pull/56132'> #56132 </a> 
<a href='https://github.com/flutter/flutter/issues/36154'> #36154 </a> 
<a href='https://github.com/flutter/flutter/pull/48876'> #48876 </a>

*PS:
The code of the package uses most of the default flutter form widget code, with some changes, just for auto-validate 
to trigger only when the state of the FormField changes at least once. 
The flutter community is working on the related issues for the same which may take sometime to merge, 
to stable or beta channel.
Till then you can make use of this package.*

# Getting Started
If you want to use smart_form directly as a package, just click https://pub.dev/packages/smart_form#-installing-tab-


# How to use SmartForm ?

Same as you use your very own Form widget.

```dart
SmartForm buildForm(BuildContext context) {
    return SmartForm(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // here this Form Field will start to auto validate only when the text field value is entered or changed at least once
          SmartTextFormField(
                  autovalidate: true,
                  initialValue: 'John Doe',
                  decoration: InputDecoration(
                    labelText: 'Enter Name',
                  ),
                  onSaved: (value) => your_save_method,             
                  validator: (value) => your_validation_method
                ),
          // Custom Form Field 
          SmartFormField(
                  autovalidate: true,
                  builder: (state) {
                    // This Search Text Field can be wrapping your default TextField internally
                    return MyCustomSearchTextField(
                      controller: my_text_edit_controller,
                      label: label,
                      errorText: state.errorText,
                    );
                  },
                  onSaved: (value) => your_save_method,
                  validator: (value) =>
                      your_validation_method,
                )
        ],
      ),
    );
  }
```

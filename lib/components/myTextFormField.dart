import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class MyTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String name;
  final dynamic validator;
  final dynamic onSaved;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? minLines;
  final int? maxLines;
  final String? value;
  final dynamic onChange;

  MyTextFormField({
    this.controller,
    required this.name,
    required this.validator,
    this.onSaved,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.minLines,
    this.maxLines,
    this.value,
    this.onChange
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      initialValue: value,
      onChanged: onChange,
      onSaved: onSaved,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        fillColor: Colors.transparent,
        filled: true,
        hintText: name,
        hintStyle: TextStyle(
          color: Colors.grey[500],
          fontSize: 16,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}

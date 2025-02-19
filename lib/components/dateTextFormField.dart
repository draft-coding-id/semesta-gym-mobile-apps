import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;

  const DateTextFormField({
    super.key,
    required this.controller,
    required this.validator,
    required this.onSaved
    });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      onSaved: onSaved,
      keyboardType: TextInputType.none,
      readOnly: true,
      decoration: InputDecoration(
        fillColor: Color(0xfff9747FF),
        filled: true,
        hintText: "Masukkan Tanggal",
        hintStyle: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.transparent)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.transparent)),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.red),
        ),
        suffixIcon: Icon(Icons.calendar_today, color: Colors.white),
      ),
      style: TextStyle(
        color: Colors.white,
      ),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );

        if (pickedDate != null) {
          String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
          controller.text = formattedDate;
        }
      },
    );
  }
}

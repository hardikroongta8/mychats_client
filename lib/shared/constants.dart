import 'package:flutter/material.dart';

final textInputDecration = InputDecoration(
  hintText: '',
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(
      width: 0,
      color: Colors.transparent
    )
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(
      width: 1,
      color: Colors.blue
    )
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(
      width: 0,
      color: Colors.transparent
    )
  ),
  fillColor: Colors.white10,
  filled: true,
  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10)
);
import 'package:flutter/material.dart';

//const String uri = 'http://192.168.1.8:8080/';
const String uri = 'https://mychats-1.onrender.com/';

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
      color: Colors.red
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
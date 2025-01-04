import 'package:flutter/material.dart';

class RegisterFunctions {
  // Email validation function
  String? validateEmail(String? value) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (value == null || value.isEmpty) {
      return 'Se requiere correo electrónico';
    } else if (!emailRegex.hasMatch(value)) {
      return 'Introduce una dirección de correo electrónico válida';
    }
    return null;
  }

  // Password validation function
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Se requiere contraseña';
    } else if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    } else if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'La contraseña debe incluir al menos una letra mayúscula';
    } else if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'La contraseña debe incluir al menos una letra minúscula';
    } else if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'La contraseña debe incluir al menos un número';
    }
    return null;
  }
}

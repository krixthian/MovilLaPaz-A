class Validators {
  static final RegExp _numericRegex = RegExp(r'^[0-9]+$');

  static String? validateCI(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El CI es requerido';
    }
    if (!_numericRegex.hasMatch(value.trim())) {
      return 'El CI debe contener solo números';
    }
    if (value.trim().length != 7) {
      return 'El CI debe tener exactamente 7 dígitos';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    if (value.length < 4) {
      return 'La contraseña es muy corta';
    }
    return null;
  }

  static String? validateRequiredText(String? value, {int minLength = 1, int maxLength = 200}) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es requerido';
    }
    if (value.trim().length < minLength) {
      return 'Mínimo $minLength caracteres';
    }
    if (value.length > maxLength) {
      return 'Máximo $maxLength caracteres';
    }
    return null;
  }
}

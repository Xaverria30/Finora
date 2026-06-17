class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    if (!RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 8) {
      return 'Password minimal 8 karakter';
    }
    if (!RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)').hasMatch(value)) {
      return 'Password harus mengandung huruf besar, kecil, dan angka';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    if (value.length < 3) {
      return 'Nama minimal 3 karakter';
    }
    return null;
  }

  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Jumlah tidak boleh kosong';
    }
    if (double.tryParse(value) == null) {
      return 'Masukkan angka yang valid';
    }
    if (double.parse(value) <= 0) {
      return 'Jumlah harus lebih dari 0';
    }
    return null;
  }

  static String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Deskripsi tidak boleh kosong';
    }
    if (value.length < 3) {
      return 'Deskripsi minimal 3 karakter';
    }
    return null;
  }

  static String? validateCategoryName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama kategori tidak boleh kosong';
    }
    if (value.length < 2) {
      return 'Nama kategori minimal 2 karakter';
    }
    return null;
  }

  static String? validateGoalName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama tujuan tidak boleh kosong';
    }
    if (value.length < 3) {
      return 'Nama tujuan minimal 3 karakter';
    }
    return null;
  }

  static String? validateNotEmpty(String? value) {
    if (value == null || value.isEmpty) {
      return 'Field tidak boleh kosong';
    }
    return null;
  }
}

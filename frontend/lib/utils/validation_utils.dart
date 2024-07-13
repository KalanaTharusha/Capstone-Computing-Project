class ValidationUtils {
  // User Validations

  static String? validateCurtinID(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your Curtin ID.';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email address.';
    }

    if (!value.contains('@')) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  static String? validateFirstName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your first name.';
    }
    return null;
  }

  static String? validateLastName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your last name.';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password.';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long.';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter.';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter.';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number.';
    }
    if (!RegExp(r'[!@#\$&*~]').hasMatch(value)) {
      return 'Password must contain at least one special character.';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String? password) {
    print("$value $password");
    if (value == null || value.isEmpty) {
      return 'Please confirm your password.';
    }
    if (value != password) {
      return 'Passwords do not match.';
    }
    return null;
  }

  // Announcement Validations

  static String? validateAnnouncementTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the title.';
    }
    return null;
  }

  static String? validateAnnouncementBody(String? value) {
    if (value == null || value.isEmpty) {
      return 'Cannot publish an empty announcement.';
    }
    return null;
  }

  // Appointment Validations

  static String? validateAppointmentLecturer(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a lecturer from the list.';
    }
    return null;
  }

  static String? validateAppointmentReason(String? value) {
    if (value == null || value.isEmpty) {
      return 'Reason for the appointment is required.';
    }
    return null;
  }

  // Ticket Validations

  static String? validateTicketTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the title.';
    }
    return null;
  }

  static String? validateTicketBody(String? value) {
    if (value == null || value.isEmpty) {
      return 'Cannot submit an empty ticket.';
    }
    return null;
  }

  static String? validateEventName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Event name cannot be empty';
    }
    return null;
  }
}

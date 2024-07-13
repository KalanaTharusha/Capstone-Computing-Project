package com.example.student_support_system.model.user;

public enum UserAccountRole {

    LECTURER("LECTURER"),
    ACADEMIC_ADMINISTRATION("ACADEMIC_ADMINISTRATION"),
    INSTRUCTOR("INSTRUCTOR"),
    CHANNEL_MODERATOR("CHANNEL_MODERATOR"),
    STUDENT("STUDENT"),
    SYSTEM_ADMIN("SYSTEM_ADMIN");

    private String value;

    UserAccountRole(String value) {
        this.value = value;
    }

    public String getValue() {
        return value;
    }
}

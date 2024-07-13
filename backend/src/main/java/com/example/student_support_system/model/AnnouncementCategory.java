package com.example.student_support_system.model;

public enum AnnouncementCategory {
    IMPORTANT("IMPORTANT"),
    ACADEMIC("ACADEMIC"),
    SPORT("SPORT"),
    ALERT("ALERT");

    private String value;

    AnnouncementCategory(String value){this.value = value;}

    public String getValue() {
        return value;
    }

}

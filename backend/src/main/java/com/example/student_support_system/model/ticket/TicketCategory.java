package com.example.student_support_system.model.ticket;

public enum TicketCategory {

    Academic("Academic"),
    Payments("Payments"),
    Sports("Sports"),
    Accessibility("Accessibility");

    private String value;

    TicketCategory(String value) {
        this.value = value;
    }

    public String getValue() {
        return value;
    }
}

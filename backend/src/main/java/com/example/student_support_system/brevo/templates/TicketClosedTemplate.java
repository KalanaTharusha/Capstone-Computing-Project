package com.example.student_support_system.brevo.templates;

import com.example.student_support_system.brevo.BrevoTemplate;

import java.util.Map;

public class TicketClosedTemplate implements BrevoTemplate {

    private String ticketId;
    private String username;
    private String studentFirstName;
    private String studentLastName;
    private String studentEmail;
    private String description;

    public TicketClosedTemplate(String ticketId, String username, String studentFirstName,String studentLastName, String studentEmail, String description) {
        this.ticketId = ticketId;
        this.username = username;
        this.studentFirstName = studentFirstName;
        this.studentLastName = studentLastName;
        this.studentEmail = studentEmail;
        this.description = description;
    }

    @Override
    public int templateId() {
        return 14;
    }

    @Override
    public Map<String, ?> params() {
        return Map.of("ticketId", ticketId, "username", username, "studentName", studentFirstName+" "+studentLastName, "studentEmail", studentEmail, "description", description);
    }
}

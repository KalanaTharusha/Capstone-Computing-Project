package com.example.student_support_system.brevo.templates;

import com.example.student_support_system.brevo.BrevoTemplate;

import java.util.Map;

public class ForwardTicketTemplate implements BrevoTemplate{

    private String ticketId;
    private String forwardUsername;
    private String studentFirstName;
    private String studentLastName;
    private String studentEmail;
    private String description;

    public ForwardTicketTemplate(String ticketId, String forwardUsername, String studentFirstName, String studentLastName, String studentEmail, String description) {
        this.ticketId = ticketId;
        this.forwardUsername = forwardUsername;
        this.studentFirstName = studentFirstName;
        this.studentLastName = studentLastName;
        this.studentEmail = studentEmail;
        this.description = description;

    }


    @Override
    public int templateId() {
        return 12;
    }

    @Override
    public Map<String, ?> params() {
        return Map.of("ticketId", ticketId, "username", forwardUsername, "studentName", studentFirstName +" "+studentLastName, "studentEmail", studentEmail, "description", description);
    }
}

package com.example.student_support_system.brevo.templates;

import com.example.student_support_system.brevo.BrevoTemplate;

import java.util.Map;

public class ReplyTicketTemplate implements BrevoTemplate{

    private String ticketId;
    private String username;
    private String description;
    private String reply;

    public ReplyTicketTemplate(String ticketId, String username, String description, String reply) {
        this.ticketId = ticketId;
        this.username = username;
        this.description = description;
        this.reply = reply;
    }

    @Override
    public int templateId() {
        return 11;
    }

    @Override
    public Map<String, ?> params() {
        return Map.of("ticketId", ticketId, "username", username,"issue" ,description,"reply", reply);
    }
}


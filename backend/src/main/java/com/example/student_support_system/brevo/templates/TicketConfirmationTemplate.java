package com.example.student_support_system.brevo.templates;

import com.example.student_support_system.brevo.BrevoTemplate;
import java.util.Map;


public class TicketConfirmationTemplate implements BrevoTemplate {
    private String username;
    private String ticketId;

    public TicketConfirmationTemplate(String username, String ticketId) {
        this.username = username;
        this.ticketId = ticketId;

    }

    @Override
    public int templateId() {
        return 4;
    }

    @Override
    public Map<String, ?> params() {
        return Map.of("username", username, "ticketId", ticketId);
    }
}

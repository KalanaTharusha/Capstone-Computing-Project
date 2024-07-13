package com.example.student_support_system.brevo.templates;

import com.example.student_support_system.brevo.BrevoTemplate;

import java.util.Map;

public class OnboardingTemplate implements BrevoTemplate {

    private String username;
    public OnboardingTemplate(String username) {
        this.username = username;
    }

    @Override
    public int templateId() {
        return 1;
    }

    @Override
    public Map<String, ?> params() {
        return Map.of("username", username);
    }
}

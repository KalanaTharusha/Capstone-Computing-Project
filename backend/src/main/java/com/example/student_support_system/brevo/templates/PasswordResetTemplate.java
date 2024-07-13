package com.example.student_support_system.brevo.templates;

import com.example.student_support_system.brevo.BrevoTemplate;

import java.util.Map;

public class PasswordResetTemplate implements BrevoTemplate {

    private String OTP;

    public PasswordResetTemplate(String OTP){
        this.OTP = OTP;
    }
    @Override
    public int templateId() {
        return 3;
    }

    @Override
    public Map<String, ?> params() {
        return Map.of("otp", OTP);
    }
}

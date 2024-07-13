package com.example.student_support_system.brevo.templates;

import com.example.student_support_system.brevo.BrevoTemplate;

import java.util.Map;

public class AccountActivateTemplate implements BrevoTemplate {

    private String OTP;

    public AccountActivateTemplate(String OTP) {
        this.OTP = OTP;
    }
    @Override
    public int templateId() {
        return 2;
    }

    @Override
    public Map<String, ?> params() {
        return Map.of("otp", OTP);
    }
}

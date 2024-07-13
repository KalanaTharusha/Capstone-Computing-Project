package com.example.student_support_system.controller;


import com.example.student_support_system.brevo.templates.OnboardingTemplate;
import com.example.student_support_system.service.EmailNotificationService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/test")
public class TestController {

    private final EmailNotificationService emailNotificationService;
    public TestController(EmailNotificationService emailNotificationService) {
        this.emailNotificationService = emailNotificationService;
    }


    @GetMapping()
    public ResponseEntity<String> testEndpoint() {
        return ResponseEntity.ok("Hello World!");
    }

    @PostMapping("/email")
    public ResponseEntity testEmail() {
        emailNotificationService.sendEmailNotification(new OnboardingTemplate("John"), "kalanatharusha.devop@gmail.com");
        return ResponseEntity.ok("sent");
    }

}
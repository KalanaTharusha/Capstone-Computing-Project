package com.example.student_support_system.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.student_support_system.dto.fcm.CreateFcmDto;
import com.example.student_support_system.dto.fcm.UpdateFcmDto;
import com.example.student_support_system.model.Fcm;
import com.example.student_support_system.service.FcmService;
import com.example.student_support_system.util.ApiUtil;

import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;


@CrossOrigin(origins = "*", allowedHeaders = "*")
@RestController
@RequestMapping(value = "/api/fcm", produces = "application/json")
public class FcmController {
    private final FcmService fcmService;

    public FcmController(FcmService fcmService) {
        this.fcmService = fcmService;
    }

    @PostMapping("/register")
    public ResponseEntity registerFcmToken(@RequestBody @Validated CreateFcmDto createFcmDto) {
        try {
            if (fcmService.existsByFcmToken(createFcmDto.getFcmToken())) {
                return ResponseEntity
                        .badRequest()
                        .body("Device token already exists");
            }
            Fcm savedFcmToken = fcmService.createFcmToken(createFcmDto.getUserId(), createFcmDto.getFcmToken());
            return ResponseEntity
                    .ok()
                    .body(savedFcmToken);
        }
        catch (Exception exception) {
            return ResponseEntity
                    .internalServerError()
                    .body(exception.getMessage());
        }
    }

    @PatchMapping("/update")
    public ResponseEntity updateFcmToken(@RequestBody @Validated UpdateFcmDto updateFcmDto) {
        try {
            fcmService.updateFcmToken(updateFcmDto.getOldFcmToken(), updateFcmDto.getNewFcmToken());
            return ResponseEntity
                    .ok()
                    .body("Device token updated successfully");
        }
        catch (Exception exception) {
            return ResponseEntity
                    .internalServerError()
                    .body(exception.getMessage());
        }
    }
    
    
}

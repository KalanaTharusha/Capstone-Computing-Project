package com.example.student_support_system.dto.fcm;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class CreateFcmDto {
    private String userId;
    private String fcmToken;
}

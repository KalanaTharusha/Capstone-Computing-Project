package com.example.student_support_system.dto.fcm;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class UpdateFcmDto {

    private String oldFcmToken;
    private String newFcmToken;
    
}

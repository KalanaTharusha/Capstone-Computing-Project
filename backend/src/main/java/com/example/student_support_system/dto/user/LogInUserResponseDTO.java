package com.example.student_support_system.dto.user;


import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class LogInUserResponseDTO {

    private String userId;

    private String authToken;
}

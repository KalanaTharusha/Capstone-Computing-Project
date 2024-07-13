package com.example.student_support_system.dto.user;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class UserAccountResponseDTO {

    private String userId;

    private String emailAddress;

    private String firstName;

    private String lastName;

    private String role;

    private String imageId;
}

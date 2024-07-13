package com.example.student_support_system.dto.user;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
@JsonInclude(JsonInclude.Include.NON_NULL)
@Builder
public class ChangePasswordRequestDTO {
    @NotBlank(message = "User ID cannot be null")
    private String userId;

    @NotBlank(message = "Current password cannot be null")
    private String currPassword;

    @NotBlank(message = "New password cannot be null")
    private String newPassword;
}

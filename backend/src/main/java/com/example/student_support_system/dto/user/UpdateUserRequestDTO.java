package com.example.student_support_system.dto.user;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;
import jakarta.annotation.Nullable;
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
public class UpdateUserRequestDTO {
    @NotBlank(message = "User ID cannot be null")
    private String userId;

    @NotBlank(message = "Email address cannot be null")
    private String emailAddress;

    @NotBlank(message = "First name cannot be null")
    private String firstName;

    private String lastName;

    @NotBlank(message = "Role cannot be null")
    private String role;

    @Nullable
    private String imageId;
}

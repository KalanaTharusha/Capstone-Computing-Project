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
public class CreateUserRequestDTO {

    @NotBlank(message = "User ID cannot be null")
    private String userId;

    @NotBlank(message = "Email address cannot be null")
    private String emailAddress;

    @NotBlank(message = "Password cannot be null")
    private String password;

    private String phoneNumber;

    @NotBlank(message = "First name cannot be null")
    private String firstName;

    private String lastName;

    @NotBlank(message = "Role cannot be null")
    private String role;
}

package com.example.student_support_system.dto.message;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
@JsonInclude(JsonInclude.Include.NON_NULL)
public class EditMessageDTO {

    @NotNull(message = "Message id cannot be null")
    private Long messageId;

    @NotBlank(message = "Message text cannot be null")
    private String text;

    @NotBlank(message = "UserId cannot be null")
    private String userId;

    @NotBlank(message = "modifiedBy cannot be null")
    private String modifiedBy;

}

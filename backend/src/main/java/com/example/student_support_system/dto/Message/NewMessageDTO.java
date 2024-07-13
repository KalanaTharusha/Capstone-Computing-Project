package com.example.student_support_system.dto.message;

import java.time.LocalDateTime;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
@JsonInclude(JsonInclude.Include.NON_NULL)
public class NewMessageDTO {

    @NotBlank(message = "User id cannot be null")
    private String userId;

    @NotBlank(message = "Channel id cannot be null")
    private String channelId;

    private String data;

    private String type;

    private LocalDateTime dateTimeSent;

    private String attachmentId;

    private int attachmentSize;
}

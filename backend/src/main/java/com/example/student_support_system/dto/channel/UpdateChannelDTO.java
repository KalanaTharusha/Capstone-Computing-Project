package com.example.student_support_system.dto.channel;

import java.util.List;

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
public class UpdateChannelDTO {

    @NotBlank(message = "Channel id cannot be null")
    private String id;
    
    @NotBlank(message = "Channel name cannot be null")
    private String name;

    private String description;

    @NotBlank(message = "Category cannot be null")
    private String category;
    
    private List<String> admins;

    private List<String> members;
}

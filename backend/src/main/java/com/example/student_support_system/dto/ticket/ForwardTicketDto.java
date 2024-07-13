package com.example.student_support_system.dto.ticket;

import com.fasterxml.jackson.databind.JsonNode;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class ForwardTicketDto {

    private String forwardEmail;
    private String forwardUserFirstName;
    private String forwardUserLastName;
    private JsonNode forwardData;

}
package com.example.student_support_system.dto.ticket;

import com.example.student_support_system.model.ticket.TicketCategory;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class CreateTicketRequestDTO {

    private String title;

    private String description;

    private TicketCategory category;

    private String createdUserId;
}

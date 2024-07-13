package com.example.student_support_system.dto.common;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class pageResponseDTO {
    private int totalPages;
    private int pageNo;
    private int pageSize;
    private Object page;
}

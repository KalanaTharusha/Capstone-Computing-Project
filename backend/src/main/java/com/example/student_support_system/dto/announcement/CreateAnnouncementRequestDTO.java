package com.example.student_support_system.dto.announcement;

import com.example.student_support_system.model.AnnouncementCategory;
import com.fasterxml.jackson.databind.JsonNode;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class CreateAnnouncementRequestDTO {

    private String title;

    private JsonNode description;

    private AnnouncementCategory category;

    private String imageId;
}

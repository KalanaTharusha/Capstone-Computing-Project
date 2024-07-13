package com.example.student_support_system.model;

import com.example.student_support_system.model.user.UserAccount;
import com.example.student_support_system.util.CustomDateTimeDeserializer;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIncludeProperties;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.LocalDateTime;

@Table
@Entity
@Data
@AllArgsConstructor
@NoArgsConstructor
public class Announcement {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column
    private AnnouncementCategory category;

    @Column
    private String title;

    @Column(columnDefinition = "json")
    @JdbcTypeCode(SqlTypes.JSON)
    private JsonNode description;

    @Column
    private String imageId;

    @Column
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "dd-MM-yyyy HH:mm:ss")
    @JsonDeserialize(using = CustomDateTimeDeserializer.class)
    private LocalDateTime createDate;

    @ManyToOne
    @JoinColumn(name = "createBy", referencedColumnName = "id", nullable = false)
    @JsonIncludeProperties(value = {"firstName", "lastName"})
    private UserAccount createBy;

    @Column
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "dd-MM-yyyy HH:mm:ss")
    @JsonDeserialize(using = CustomDateTimeDeserializer.class)
    private LocalDateTime updateDate;

    @ManyToOne
    @JoinColumn(name = "updateBy", referencedColumnName = "id", nullable = false)
    @JsonIncludeProperties(value = {"firstName", "lastName"})
    private UserAccount updateBy;
}

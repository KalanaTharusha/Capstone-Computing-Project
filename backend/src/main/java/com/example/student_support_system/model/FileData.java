package com.example.student_support_system.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Table (name = "fileData")
@Entity
@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
public class FileData {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column
    private String fileId;

    @Column
    private String fileType;

    @Column (name = "filedata", length = 1000)
    private byte[] fileData;

}

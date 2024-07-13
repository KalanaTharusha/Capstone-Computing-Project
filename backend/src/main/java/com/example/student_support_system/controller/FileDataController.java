package com.example.student_support_system.controller;

import com.example.student_support_system.dto.filedata.FileUploadResponse;
import com.example.student_support_system.service.FileDataService;
import com.example.student_support_system.util.logging.AppLogger;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;

@RestController
@RequestMapping("/api/files")
public class FileDataController {

    private final FileDataService fileDataService;

    public FileDataController(FileDataService fileDataService) {
        this.fileDataService = fileDataService;
    }

    @PostMapping("/upload")
    public ResponseEntity<?> uploadFile(@RequestParam("file") MultipartFile file) {

        String fileId = (LocalDateTime.now() + "-" + file.getOriginalFilename()).replaceAll("\\s+","");
        fileDataService.uploadFile(file, fileId);

        FileUploadResponse fileUploadResponse = new FileUploadResponse(fileId, "File Uploaded Successfully");
        return ResponseEntity
                .ok()
                .body(fileUploadResponse);
    }

    @GetMapping("/download/{fileId}")
    public ResponseEntity<?> downloadFile(@PathVariable("fileId") String fileId) {

        byte[] file = fileDataService.downloadFile(fileId);

        AppLogger.info("Request received to download file with id: " + fileId + ". File exists? " + (file != null));

        String contentType = fileDataService.getContentType(fileId);

        return ResponseEntity
                .ok()
                .contentType(MediaType.valueOf(contentType))
                .body(file);
    }

    @DeleteMapping("/{fileId}")
    public ResponseEntity<?> deleteFile(@PathVariable("fileId") String fileId) {
        try {
            fileDataService.deleteFile(fileId);
            return new ResponseEntity("File deleted", HttpStatus.NO_CONTENT);

        } catch (Exception exception){
            return ResponseEntity
                    .internalServerError()
                    .body(exception.getMessage());
        }
    }

}

package com.example.student_support_system.service;

import com.example.student_support_system.exception.EntityNotFoundException;
import com.example.student_support_system.model.FileData;
import com.example.student_support_system.repository.FileDataRepository;
import com.example.student_support_system.util.FileUtil;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Optional;

@Service
public class FileDataService {
    private final FileDataRepository fileDataRepository;

    private final ResourceLoader resourceLoader;

    public FileDataService(
            FileDataRepository fileDataRepository,
            ResourceLoader resourceLoader
    ) {
        this.fileDataRepository = fileDataRepository;
        this.resourceLoader = resourceLoader;
    }

    public void uploadFile(MultipartFile file, String fileId) {
        try {
            fileDataRepository.save(
                    FileData.builder()
                            .fileId(fileId)
                            .fileType(file.getContentType())
                            .fileData(FileUtil.compressFile(file.getBytes()))
                            .build());
        } catch (IOException e) {
            throw new RuntimeException(e); // TODO: 12/16/2023 : implement proper exception handling
        }
    }

    public byte[] downloadFile(String fileId) {
        Optional<FileData> fileData = fileDataRepository.findByFileId(fileId);
        return FileUtil.decompressFile(unwrapFileData(fileData, fileId).getFileData());
    }

    public void deleteFile(String fileId) {
        Optional<FileData> fileData = fileDataRepository.findByFileId(fileId);
        fileDataRepository.deleteById(unwrapFileData(fileData, fileId).getId());
    }

    public String getContentType(String fileId) {
        Optional<FileData> fileData = fileDataRepository.findByFileId(fileId);
        return unwrapFileData(fileData, fileId).getFileType();
    }

    static FileData unwrapFileData(Optional<FileData> entity, String id) {
        if (entity.isPresent()) return entity.get();
        else throw new EntityNotFoundException(id, FileData.class);
    }

    public Resource loadResource(String resourceFilePath) {
        return resourceLoader.getResource("classpath:" + resourceFilePath);
    }
}

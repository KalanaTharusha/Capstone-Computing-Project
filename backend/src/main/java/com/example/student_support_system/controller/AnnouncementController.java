package com.example.student_support_system.controller;

import com.example.student_support_system.dto.announcement.CreateAnnouncementRequestDTO;
import com.example.student_support_system.model.Announcement;
import com.example.student_support_system.model.AnnouncementCategory;
import com.example.student_support_system.model.user.UserAccount;
import com.example.student_support_system.service.AnnouncementService;
import com.example.student_support_system.service.UserAccountService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;

@CrossOrigin("*")
@RestController
@RequestMapping("/api/announcements")
public class AnnouncementController {

    private final AnnouncementService announcementService;
    private final UserAccountService userAccountService;


    public AnnouncementController(AnnouncementService announcementService, UserAccountService userAccountService) {
        this.announcementService = announcementService;
        this.userAccountService = userAccountService;
    }

    @GetMapping
    public ResponseEntity getAllAnnouncements() throws Exception {
        return ResponseEntity
                .ok()
                .body(announcementService.getAllAnnouncements());
    }

    @GetMapping("/{id}")
    public ResponseEntity getAnnouncement(@PathVariable("id") Long id) {
        return ResponseEntity
                .ok()
                .body(announcementService.getAnnouncement(id));
    }

    @GetMapping("/pagination/{offset}/{pageSize}")
    public ResponseEntity getAnnouncementsWithPagination(@PathVariable int offset, @PathVariable int pageSize) {
        return ResponseEntity
                .ok()
                .body(announcementService.getAnnouncementsWithPagination(offset, pageSize));
    }

    @GetMapping("/date/{start}/{end}")
    public ResponseEntity getAnnouncementByDate(@PathVariable("start") LocalDateTime start, @PathVariable("end") LocalDateTime end) {
        return ResponseEntity
                .ok()
                .body(announcementService.getAllAnnouncementsByDate(start, end));
    }

    @GetMapping("/search/{term}")
    public ResponseEntity search(@PathVariable("term") String term) {
        return ResponseEntity
                .ok()
                .body(announcementService.search(term));
    }

    @PostMapping("/create")
    public ResponseEntity createAnnouncement(
            @RequestHeader String userId,
            @RequestBody CreateAnnouncementRequestDTO announcementRequestDTO) {

            UserAccount creator = userAccountService.getUserAccountByUserId(userId);

            LocalDateTime dateTime = LocalDateTime.now();

            Announcement announcement = new Announcement();
            announcement.setTitle(announcementRequestDTO.getTitle());
            announcement.setDescription(announcementRequestDTO.getDescription());
            announcement.setCategory(announcementRequestDTO.getCategory());
            announcement.setImageId(announcementRequestDTO.getImageId());
            announcement.setCreateDate(dateTime);
            announcement.setCreateBy(creator);
            announcement.setUpdateDate(dateTime);
            announcement.setUpdateBy(creator);

            Announcement createdAnnouncement = announcementService.createAnnouncement(announcement);
            return ResponseEntity
                    .ok()
                    .body(createdAnnouncement);
    }

    @PostMapping("/update/{id}")
    public ResponseEntity updateAnnouncement(
            @PathVariable String id,
            @RequestHeader String userId,
            @RequestBody CreateAnnouncementRequestDTO announcementRequestDTO) {

        try {
            UserAccount updateBy = userAccountService.getUserAccountByUserId(userId);

            Announcement announcement = new Announcement();
            announcement.setTitle(announcementRequestDTO.getTitle());
            announcement.setDescription(announcementRequestDTO.getDescription());
            announcement.setCategory(announcementRequestDTO.getCategory());
            announcement.setImageId(announcementRequestDTO.getImageId());

            Announcement updatedAnnouncement = announcementService.updateAnnouncement(Long.valueOf(id), updateBy, announcement);
            return ResponseEntity
                    .ok()
                    .body(updatedAnnouncement);
        }
        catch (Exception exception) {
            return ResponseEntity
                    .internalServerError()
                    .body(exception.getMessage());
        }

    }

    @DeleteMapping("/{id}")
    public ResponseEntity deleteAnnouncement(@PathVariable Long id){
        try {
            announcementService.deleteAnnouncement(id);
            return new ResponseEntity("Announcement deleted", HttpStatus.NO_CONTENT);
        }
        catch (Exception exception) {
            return ResponseEntity
                    .internalServerError()
                    .body(exception.getMessage());
        }
    }

    @GetMapping("/alerts")
    public ResponseEntity getAlerts(){
        return ResponseEntity
                .ok()
                .body(announcementService.getAlerts());
    }

    @GetMapping("/categories")
    public ResponseEntity getAllCategories(){

        AnnouncementCategory[] announcementCategories = AnnouncementCategory.class.getEnumConstants();

        return ResponseEntity
                .ok()
                .body(announcementCategories);
    }

}

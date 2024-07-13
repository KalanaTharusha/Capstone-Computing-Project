package com.example.student_support_system.controller;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.userdetails.User;

import com.example.student_support_system.dto.announcement.CreateAnnouncementRequestDTO;
import com.example.student_support_system.model.Announcement;
import com.example.student_support_system.model.AnnouncementCategory;
import com.example.student_support_system.model.user.UserAccount;
import com.example.student_support_system.service.AnnouncementService;
import com.example.student_support_system.service.UserAccountService;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.introspect.AnnotatedClass;

@ExtendWith(MockitoExtension.class)
public class AnnouncementControllerTest {
    @Mock
    private AnnouncementService announcementService;

    @Mock
    private UserAccountService userAccountService;

    @InjectMocks
    private AnnouncementController announcementController;

    @Test
    public void testGetAllAnnouncements(){


        try{
            Announcement announcementOne = new Announcement();
            announcementOne.setId(1L);

            Announcement announcementTwo = new Announcement();
            announcementTwo.setId(2L);

            List<Announcement> announcementList = new ArrayList<>();
            announcementList.add(announcementOne);
            announcementList.add(announcementTwo);

            Mockito.when(announcementService.getAllAnnouncements()).thenReturn(announcementList);

            ResponseEntity<List<Announcement>> responseEntity = announcementController.getAllAnnouncements();

            Assertions.assertNotNull(responseEntity.getBody());
            Assertions.assertEquals(HttpStatus.OK, responseEntity.getStatusCode());

            List<Announcement> returnedAnnouncements = responseEntity.getBody();
            assertNotNull(returnedAnnouncements, "Returned announcements should not be null");
            assertEquals(2, returnedAnnouncements.size());

            assertEquals(announcementOne.getId(), returnedAnnouncements.get(0).getId());
            
            assertEquals(announcementTwo.getId(), returnedAnnouncements.get(1).getId());
        } catch (Exception e){
            Assertions.fail("Failed test: getAllAnnouncements", e);
        }
    }

    @Test
    public void testGetAnnouncement() throws Exception{
            Announcement announcement = new Announcement();
            Mockito.when(announcementService.getAnnouncement(1l)).thenReturn(announcement);

            ResponseEntity responseEntity = ResponseEntity.ok(announcementController.getAnnouncement(1l));
            Assertions.assertEquals(HttpStatus.OK, responseEntity.getStatusCode());
            Assertions.assertNotNull(responseEntity.getBody());
    }



    @Test
    public void testCreateAnnouncement() throws Exception{
        UserAccount user = new UserAccount();
        user.setId(3L); 

        CreateAnnouncementRequestDTO announcementRequestDTO = new CreateAnnouncementRequestDTO();
        announcementRequestDTO.setCategory(AnnouncementCategory.ACADEMIC);
        announcementRequestDTO.setDescription(null);
        announcementRequestDTO.setImageId(null);
        announcementRequestDTO.setTitle("Title");

        Announcement announcement = new Announcement();
        announcement.setId(2L);
        announcement.setCreateBy(user);
        announcement.setCreateDate(LocalDateTime.now());

       Mockito.when(announcementService.createAnnouncement(Mockito.any())).thenReturn(announcement);

       ResponseEntity responseEntity = announcementController.createAnnouncement("3", announcementRequestDTO);

       Assertions.assertEquals(HttpStatus.OK, responseEntity.getStatusCode());
       Assertions.assertNotNull(responseEntity.getBody());
    }


    
    @Test
    public void testDeleteAnnouncement(){
        try{
            Mockito.doNothing().when(announcementService).deleteAnnouncement(1L);
            ResponseEntity responseEntity = announcementController.deleteAnnouncement(1l);

            Assertions.assertEquals(HttpStatus.NO_CONTENT, responseEntity.getStatusCode());
        } catch (Exception e){
            Assertions.fail("Failed test: deleteAnnouncement", e);
        }
    }
}


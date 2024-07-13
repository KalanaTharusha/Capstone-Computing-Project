package com.example.student_support_system.controller;

import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import com.example.student_support_system.dto.fcm.CreateFcmDto;
import com.example.student_support_system.dto.fcm.UpdateFcmDto;
import com.example.student_support_system.model.Fcm;
import com.example.student_support_system.service.FcmService;

@ExtendWith(MockitoExtension.class)
public class FcmControllerTest {

    @Mock
    private FcmService fcmService;

    @InjectMocks
    private FcmController fcmController;

    @Test
    void testRegisterFcmToken() {
        try {
            CreateFcmDto createFcmDto = new CreateFcmDto("0000", "ABC123");
            Fcm fcm = new Fcm();

            Mockito.when(fcmService.existsByFcmToken(createFcmDto.getFcmToken())).thenReturn(false);
            Mockito.when(fcmService.createFcmToken(createFcmDto.getUserId(), createFcmDto.getFcmToken()))
                    .thenReturn(fcm);

            ResponseEntity responseEntity = fcmController.registerFcmToken(createFcmDto);

            Assertions.assertEquals(HttpStatus.OK, responseEntity.getStatusCode());
            Assertions.assertNotNull(responseEntity.getBody());
        } catch (Exception exception) {
            Assertions.fail("registerFcmTokenTest failed", exception);
        }
    }

    @Test
    void testUpdateFcmToken() {
        try {
            UpdateFcmDto updateFcmDto = new UpdateFcmDto("ABC123", "XYZ456");

            Mockito.doNothing().when(fcmService).updateFcmToken(updateFcmDto.getOldFcmToken(),
                    updateFcmDto.getNewFcmToken());

            ResponseEntity responseEntity = fcmController.updateFcmToken(updateFcmDto);

            Assertions.assertEquals(HttpStatus.OK, responseEntity.getStatusCode());
            Assertions.assertEquals("Device token updated successfully", responseEntity.getBody());
        } catch (Exception exception) {
            Assertions.fail("registerFcmTokenTest failed", exception);
        }
    }

}

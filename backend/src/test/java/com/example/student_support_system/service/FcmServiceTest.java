package com.example.student_support_system.service;

import com.example.student_support_system.model.user.UserAccount;
import com.example.student_support_system.model.user.UserAccountRole;
import com.example.student_support_system.model.user.UserAccountStatus;
import com.example.student_support_system.repository.FcmRepository;
import com.example.student_support_system.repository.UserAccountRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import com.example.student_support_system.model.Fcm;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.*;

public class FcmServiceTest {

    @InjectMocks
    private FcmService fcmService;

    @Mock
    private FcmRepository fcmRepository;
    @Mock
    private UserAccountRepository userAccountRepository;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }


    @Test
    public void testCreateFcmToken() {
        String userId = "1010";
        String fcmToken = "ABC123";

        UserAccount userAccount = new UserAccount(
                10L,
                "1010",
                "First Name",
                "Last Name",
                "email",
                null, UserAccountRole.STUDENT,
                "password",
                UserAccountStatus.ACTIVATED);

        when(userAccountRepository.save(userAccount)).thenReturn(userAccount);
        when(userAccountRepository.findByUserId(userId)).thenReturn(Optional.of(userAccount));

        Fcm tempFcm = new Fcm();
        tempFcm.setFcmToken(fcmToken);
        tempFcm.setUserId(userAccount.getId());


        when(fcmRepository.save(tempFcm)).thenReturn(tempFcm);

        Fcm createdFcm = fcmService.createFcmToken(userId, fcmToken);

        assertEquals(tempFcm, createdFcm);
        verify(userAccountRepository, times(1)).findByUserId(userId);
        verify(fcmRepository, times(1)).save(any(Fcm.class));

    }

}

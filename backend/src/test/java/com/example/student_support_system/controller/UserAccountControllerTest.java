package com.example.student_support_system.controller;

import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;
import com.auth0.jwt.interfaces.DecodedJWT;
import com.example.student_support_system.brevo.templates.OnboardingTemplate;
import com.example.student_support_system.brevo.templates.PasswordResetTemplate;
import com.example.student_support_system.dto.user.*;
import com.example.student_support_system.model.user.UserAccount;
import com.example.student_support_system.model.user.UserAccountRole;
import com.example.student_support_system.model.user.UserAccountStatus;
import com.example.student_support_system.security.SecurityConstants;
import com.example.student_support_system.service.EmailNotificationService;
import com.example.student_support_system.service.OTPService;
import com.example.student_support_system.service.SecureTokenService;
import com.example.student_support_system.service.UserAccountService;
import com.example.student_support_system.util.ApiUtil;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.junit.jupiter.MockitoExtension;
import org.skyscreamer.jsonassert.JSONAssert;
import org.springframework.http.ResponseEntity;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ExtendWith(MockitoExtension.class)
public class UserAccountControllerTest {

    @Mock
    private OTPService otpService;

    @Mock
    private SecureTokenService secureTokenService;

    @Mock
    private UserAccountService userAccountService;

    @Mock
    private EmailNotificationService emailNotificationService;

    @InjectMocks
    private UserAccountController userAccountController;

    private final UserAccount testUserAccount;

    public UserAccountControllerTest() {
        testUserAccount = new UserAccount(
            1L,
            "1010",
            "First Name",
            "Last Name",
            "email",
            null,
            UserAccountRole.STUDENT,
            "password",
            UserAccountStatus.ACTIVATED
        );
    }

    @Test
    public void getAllUserAccountsTest() {
        try {
            Mockito.when(userAccountService.getAllUserAccounts())
                    .thenReturn(List.of(testUserAccount, testUserAccount));

            @SuppressWarnings("unchecked")
            ResponseEntity<List<UserAccount>> userAccounts = userAccountController.getAllUsers();

            List<UserAccount> actualUserAccounts = userAccounts.getBody();

            Assertions.assertEquals(200, userAccounts.getStatusCodeValue());
            Assertions.assertNotNull(actualUserAccounts);
            Assertions.assertEquals(2, actualUserAccounts.size());
            Assertions.assertEquals(testUserAccount, actualUserAccounts.get(0));
        } catch (Exception exception) {
            Assertions.fail("getAllUserAccountsTest failed", exception);
        }
    }

    @Test
    public void getAllStaffTest() {
        try {
            testUserAccount.setRole(UserAccountRole.INSTRUCTOR);
            Mockito.when(userAccountService.getAcademicStaff())
                    .thenReturn(List.of(testUserAccount, testUserAccount));

            @SuppressWarnings("unchecked")
            ResponseEntity<List<UserAccount>> staff = userAccountController.getAllStaff();

            List<UserAccount> actualStaff = staff.getBody();

            Assertions.assertEquals(200, staff.getStatusCodeValue());
            Assertions.assertNotNull(actualStaff);
            Assertions.assertEquals(2, actualStaff.size());
            Assertions.assertEquals(testUserAccount, actualStaff.get(0));

        } catch (Exception exception) {
            Assertions.fail("getAllStaffTest failed", exception);
        }
    }

    @Test
    public void createUserTest() {
        try {
            CreateUserRequestDTO createUserRequestDTO = CreateUserRequestDTO
                    .builder()
                    .userId("1010")
                    .emailAddress("email")
                    .firstName("First Name")
                    .lastName("Last Name")
                    .role("STUDENT")
                    .build();

            Mockito.when(userAccountService.createUserAccount(Mockito.any(UserAccount.class)))
                    .thenReturn(testUserAccount);

            Mockito.doNothing()
                    .when(emailNotificationService)
                    .sendEmailNotification(Mockito.any(OnboardingTemplate.class), Mockito.anyString());

            ResponseEntity<UserAccount> userAccount = userAccountController.createUser(createUserRequestDTO);

            ArgumentCaptor<UserAccount> userAccountArgumentCaptor = ArgumentCaptor.forClass(UserAccount.class);
            Mockito.verify(userAccountService, Mockito.times(1))
                    .createUserAccount(userAccountArgumentCaptor.capture());

            UserAccount userAccountArgumentCaptorValue = userAccountArgumentCaptor.getValue();
            Assertions.assertEquals(200, userAccount.getStatusCodeValue());
            Assertions.assertNotNull(userAccount.getBody());
            Assertions.assertEquals(testUserAccount, userAccount.getBody());
            Assertions.assertEquals(createUserRequestDTO.getUserId(), userAccountArgumentCaptorValue.getUserId());
            Assertions.assertEquals(createUserRequestDTO.getEmailAddress(), userAccountArgumentCaptorValue.getEmailAddress());
            Assertions.assertEquals(createUserRequestDTO.getFirstName(), userAccountArgumentCaptorValue.getFirstName());
            Assertions.assertEquals(createUserRequestDTO.getLastName(), userAccountArgumentCaptorValue.getLastName());
            Assertions.assertEquals(UserAccountRole.STUDENT, userAccountArgumentCaptorValue.getRole());
        } catch (Exception exception) {
            Assertions.fail("createUserTest failed", exception);
        }
    }

    @Test
    public void updateUserTest() {
        try {
            UpdateUserRequestDTO updateUserRequestDTO = UpdateUserRequestDTO
                    .builder()
                    .userId("1010")
                    .emailAddress("email")
                    .firstName("First Name")
                    .lastName("Last Name")
                    .role("STUDENT")
                    .build();

            Mockito.when(userAccountService.updateUserAccount(Mockito.anyString(), Mockito.eq(updateUserRequestDTO)))
                    .thenReturn(testUserAccount);

            ResponseEntity<UserAccount> userAccount = userAccountController.updateUser(updateUserRequestDTO, "1010");

            Assertions.assertEquals(200, userAccount.getStatusCodeValue());
            Assertions.assertNotNull(userAccount.getBody());
            Assertions.assertEquals(testUserAccount, userAccount.getBody());
        } catch (Exception exception) {
            Assertions.fail("updateUserTest failed", exception);
        }
    }

    @Test
    public void getUserByIdTest() {
        try {
            Mockito.when(userAccountService.getUserAccountByUserId(Mockito.anyString()))
                    .thenReturn(testUserAccount);

            ResponseEntity<UserAccountResponseDTO> userAccount = userAccountController.getUserById("1010");

            Assertions.assertEquals(200, userAccount.getStatusCodeValue());
            Assertions.assertNotNull(userAccount.getBody());
            Assertions.assertEquals(testUserAccount.getUserId(), userAccount.getBody().getUserId());
            Assertions.assertEquals(testUserAccount.getEmailAddress(), userAccount.getBody().getEmailAddress());
            Assertions.assertEquals(testUserAccount.getFirstName(), userAccount.getBody().getFirstName());
            Assertions.assertEquals(testUserAccount.getLastName(), userAccount.getBody().getLastName());
        } catch (Exception exception) {
            Assertions.fail("getUserByIdTest failed", exception);
        }
    }

    @Test
    public void deleteUserTest() {
        try {
            Mockito.when(userAccountService.getUserAccountByUserId("1010"))
                    .thenReturn(testUserAccount);

            Mockito.doNothing()
                    .when(userAccountService)
                    .deleteUserAccount(Mockito.anyLong());

            ResponseEntity<String> responseEntity = userAccountController.deleteUser("1010");

            Assertions.assertEquals(204, responseEntity.getStatusCodeValue());
            Assertions.assertEquals("User deleted", responseEntity.getBody());
        } catch (Exception exception) {
            Assertions.fail("deleteUserTest failed", exception);
        }
    }

    @Test
    public void activateUserTest() {
        try {
            ActivateUserAccountRequestDTO activateUserAccountRequestDTO = ActivateUserAccountRequestDTO
                    .builder()
                    .userId("1010")
                    .secureToken("1234")
                    .build();

            Mockito.doNothing()
                    .when(userAccountService)
                    .activateUserAccount(Mockito.anyString());

            DecodedJWT decodedJWT = Mockito.mock(DecodedJWT.class);
            Mockito.when(secureTokenService.verifyToken(Mockito.anyString()))
                    .thenReturn(decodedJWT);
            ResponseEntity<String> responseEntity = userAccountController.activateAccount(activateUserAccountRequestDTO);

            Assertions.assertEquals(200, responseEntity.getStatusCodeValue());
            Assertions.assertEquals("activated", responseEntity.getBody());
        } catch (Exception exception) {
            Assertions.fail("activateUserTest failed", exception);
        }
    }

    @Test
    public void changePasswordTest() {
        try {
            ChangePasswordRequestDTO changePasswordRequestDTO = ChangePasswordRequestDTO
                    .builder()
                    .userId("1010")
                    .currPassword("password")
                    .newPassword("newPassword")
                    .build();

            Mockito.when(userAccountService.changePassword(Mockito.eq("1010"), Mockito.eq("password"), Mockito.eq("newPassword")))
                    .thenReturn(testUserAccount);

            ResponseEntity<String> responseEntity = userAccountController.changePassword(changePasswordRequestDTO);

            Assertions.assertEquals(200, responseEntity.getStatusCodeValue());
            Assertions.assertEquals("Updated Successfully", responseEntity.getBody());
        } catch (Exception exception) {
            Assertions.fail("changePasswordTest failed", exception);
        }
    }

    @Test
    public void resetPasswordTest() {
        try {
            PasswordResetRequestDTO resetPasswordRequestDTO = PasswordResetRequestDTO
                    .builder()
                    .userId("1010")
                    .secureToken("1234")
                    .password("newPassword")
                    .build();

            DecodedJWT decodedJWT = Mockito.mock(DecodedJWT.class);
            Mockito.when(secureTokenService.verifyToken(Mockito.eq("1234")))
                    .thenReturn(decodedJWT);

            Mockito.when(userAccountService.resetPassword(Mockito.eq("1010"), Mockito.eq("newPassword")))
                    .thenReturn(testUserAccount);

            ResponseEntity<String> responseEntity = userAccountController.resetPassword(resetPasswordRequestDTO);

            Assertions.assertEquals(200, responseEntity.getStatusCodeValue());
            Assertions.assertEquals("password has been reset successfully", responseEntity.getBody());
        } catch (Exception exception) {
            Assertions.fail("resetPasswordTest failed", exception);
        }
    }

    @Test
    public void requestOTPTest() {
        try {
            Mockito.when(userAccountService.getUserAccountByUserId("1010"))
                    .thenReturn(testUserAccount);

            Mockito.when(otpService.generateOTP(Mockito.anyString()))
                    .thenReturn(1234);

            Mockito.doNothing()
                    .when(emailNotificationService)
                    .sendEmailNotification(Mockito.any(PasswordResetTemplate.class), Mockito.anyString());

            ResponseEntity<String> responseEntity = userAccountController.requestOTP("1010");


            Map<String, String> responseBody = new HashMap<>()
            {{
                put("accountStatus", UserAccountStatus.ACTIVATED.toString());
                put("email", testUserAccount.getEmailAddress());
            }};

            Assertions.assertEquals(200, responseEntity.getStatusCodeValue());
            JSONAssert.assertEquals(ApiUtil.toJson(responseBody), responseEntity.getBody(), false);

        } catch (Exception exception) {
            Assertions.fail("requestOTPTest failed", exception);
        }
    }

    @Test
    public void getStatsTest() {
        try {
            Map<String, String> stats = new HashMap<>() {{
                put("total", "1");
                put("students", "1");
                put("lecturers", "0");
                put("admins", "0");
                put("instructors", "0");
            }};

            Mockito.when(userAccountService.getStats())
                    .thenReturn(stats);

            ResponseEntity<Map<String, String>> responseEntity = userAccountController.getStats();

            Assertions.assertEquals(200, responseEntity.getStatusCodeValue());
            Assertions.assertEquals(stats, responseEntity.getBody());
        } catch (Exception exception) {
            Assertions.fail("getStatsTest failed", exception);
        }
    }

    @Test
    public void verifyOtpTest() {
        try {
            Mockito.when(otpService.getOtp(Mockito.eq("1010")))
                    .thenReturn(1234);

            Mockito.when(secureTokenService.generateToken(Mockito.eq("1010"), Mockito.anyLong()))
                    .thenReturn("testSecureToken");

            ResponseEntity responseEntity = userAccountController.verifyOTP("1010", "1234");

            Map<String, String> expectedResponseBody = new HashMap<>() {{
                put("secureToken", "testSecureToken");
            }};

            Assertions.assertEquals(200, responseEntity.getStatusCodeValue());
            JSONAssert.assertEquals(ApiUtil.toJson(expectedResponseBody), responseEntity.getBody().toString(), false);
        } catch (Exception exception) {
            Assertions.fail("verifyOtpTest failed", exception);
        }
    }

    @Test
    public void changeEmailTest_success() {
        try {
            Mockito.when(userAccountService.changeEmail(Mockito.eq("1010"), Mockito.eq("email")))
                    .thenReturn(testUserAccount);

            ResponseEntity<String> responseEntity = userAccountController.changeEmail("email", "1010");

            Assertions.assertEquals(200, responseEntity.getStatusCodeValue());
            Assertions.assertEquals("Updated Successfully", responseEntity.getBody());
        } catch (Exception exception) {
            Assertions.fail("changeEmail test failed", exception);
        }
    }

    @Test
    public void changeEmailTest_failure() {
        try {
            Mockito.when(userAccountService.changeEmail(Mockito.eq("1010"), Mockito.eq("email")))
                    .thenReturn(null);

            ResponseEntity<String> responseEntity = userAccountController.changeEmail("email", "1010");

            Assertions.assertEquals(401, responseEntity.getStatusCodeValue());
            Assertions.assertEquals("Invalid Password", responseEntity.getBody());
        } catch (Exception exception) {
            Assertions.fail("changeEmail test failed", exception);
        }
    }
}

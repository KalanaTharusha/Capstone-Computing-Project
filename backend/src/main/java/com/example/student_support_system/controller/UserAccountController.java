package com.example.student_support_system.controller;

import com.auth0.jwt.interfaces.DecodedJWT;
import com.example.student_support_system.brevo.templates.AccountActivateTemplate;
import com.example.student_support_system.brevo.templates.OnboardingTemplate;
import com.example.student_support_system.brevo.templates.PasswordResetTemplate;
import com.example.student_support_system.dto.user.*;
import com.example.student_support_system.model.user.UserAccount;
import com.example.student_support_system.service.EmailNotificationService;
import com.example.student_support_system.service.OTPService;
import com.example.student_support_system.service.SecureTokenService;
import com.example.student_support_system.service.UserAccountService;
import com.example.student_support_system.util.ApiUtil;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

@CrossOrigin("*")
@RestController
@RequestMapping(value = "/api/users", produces = "application/json")
public class UserAccountController {

    private final UserAccountService userAccountService;
    private final OTPService otpService;

    private final SecureTokenService secureTokenService;
    private final EmailNotificationService emailNotificationService;

    public UserAccountController(UserAccountService userAccountService, OTPService otpService,
            EmailNotificationService emailNotificationService, SecureTokenService secureTokenService) {
        this.userAccountService = userAccountService;
        this.otpService = otpService;
        this.emailNotificationService = emailNotificationService;
        this.secureTokenService = secureTokenService;
    }

    @GetMapping()
    public ResponseEntity getAllUsers() {
        try {
            return ResponseEntity
                    .ok()
                    .body(userAccountService.getAllUserAccounts());
        } catch (Exception exception) {
            return ResponseEntity
                    .internalServerError()
                    .body(exception.getMessage());
        }
    }

    @GetMapping(path = "/staff")
    public ResponseEntity getAllStaff() {
        try {
            return ResponseEntity
                    .ok()
                    .body(userAccountService.getAcademicStaff());
        } catch (Exception exception) {
            return ResponseEntity
                    .internalServerError()
                    .body(exception.getMessage());
        }
    }

    @PostMapping(path = "/register")
    public ResponseEntity createUser(
            @RequestBody @Validated CreateUserRequestDTO createUserRequestDto) {
        try {
            UserAccount user = ApiUtil.convert(createUserRequestDto, UserAccount.class);
            UserAccount createdUser = userAccountService.createUserAccount(user);

            emailNotificationService.sendEmailNotification(new OnboardingTemplate(createdUser.getFirstName()),
                    createdUser.getEmailAddress());

            return ResponseEntity
                    .ok()
                    .body(createdUser);
        } catch (Exception exception) {
            return ResponseEntity
                    .internalServerError()
                    .body(exception.getMessage());
        }
    }

    @PutMapping(path = "/update/{userId}")
    public ResponseEntity updateUser(
            @RequestBody @Validated UpdateUserRequestDTO updateUserRequestDTO, @PathVariable String userId) {
        try {

            UserAccount updatedUser = userAccountService.updateUserAccount(userId, updateUserRequestDTO);

            return ResponseEntity
                    .ok()
                    .body(updatedUser);
        } catch (Exception exception) {
            return ResponseEntity
                    .internalServerError()
                    .body(exception.getMessage());
        }
    }

    @GetMapping(path = "/{userId}")
    public ResponseEntity getUserById(@PathVariable String userId) {
        try {
            UserAccount user = userAccountService.getUserAccountByUserId(userId);
            UserAccountResponseDTO requestedUser = new UserAccountResponseDTO(
                    user.getUserId(),
                    user.getEmailAddress(),
                    user.getFirstName(),
                    user.getLastName(),
                    user.getRole().getValue(),
                    user.getImageId());

            return ResponseEntity
                    .ok()
                    .body(requestedUser);
        } catch (Exception exception) {
            return ResponseEntity
                    .internalServerError()
                    .body(exception.getMessage());
        }
    }

    @DeleteMapping("/{userId}")
    public ResponseEntity deleteUser(@PathVariable String userId) {
        try {

            UserAccount deletedUser = userAccountService.getUserAccountByUserId(userId);
            userAccountService.deleteUserAccount(deletedUser.getId());
            return new ResponseEntity("User deleted", HttpStatus.NO_CONTENT);

        } catch (Exception e) {
            return ResponseEntity
                    .internalServerError()
                    .body(e.getMessage());
        }
    }

    @PostMapping(path = "/activate")
    public ResponseEntity activateAccount(
            @RequestBody @Validated ActivateUserAccountRequestDTO activateUserAccountRequestDTO) {
        try {
            String userId = activateUserAccountRequestDTO.getUserId();
            String secureToken = activateUserAccountRequestDTO.getSecureToken();

            DecodedJWT decodedJWT = secureTokenService.verifyToken(secureToken);

            if (decodedJWT != null) {
                userAccountService.activateUserAccount(userId);
                return ResponseEntity.ok("activated");
            }
            return new ResponseEntity("Invalid OTP", HttpStatus.UNAUTHORIZED);

        } catch (Exception e) {
            return ResponseEntity
                    .internalServerError()
                    .body(e.getMessage());
        }
    }

    @GetMapping(path = "/otp/activate/{userId}")
    public ResponseEntity requestActivateAccountOTP(@PathVariable String userId) {
        try {
            UserAccount user = userAccountService.getUserAccountByUserId(userId);
            String email = user.getEmailAddress();
            String accountStatus = user.getUserAccountStatus().toString();

            int otp = otpService.generateOTP(userId);

            // TODO: 1/16/2024 :handle email send exceptions
            emailNotificationService.sendEmailNotification(new AccountActivateTemplate(String.valueOf(otp)), email);
            return ResponseEntity
                    .ok(String.format("{\"email\": \"%s\", \"accountStatus\": \"%s\"}", email, accountStatus));

        } catch (Exception e) {
            return ResponseEntity
                    .internalServerError()
                    .body(e.getLocalizedMessage());
        }
    }

    @PostMapping(path = "/password")
    public ResponseEntity changePassword(@RequestBody @Validated ChangePasswordRequestDTO changePasswordRequestDTO) {
        try {
            String userId = changePasswordRequestDTO.getUserId();
            String currPassword = changePasswordRequestDTO.getCurrPassword();
            String newPassword = changePasswordRequestDTO.getNewPassword();

            UserAccount user = userAccountService.changePassword(userId, currPassword, newPassword);

            if (user != null)
                return ResponseEntity.ok("Updated Successfully");

            return new ResponseEntity("Invalid Password", HttpStatus.UNAUTHORIZED);

        } catch (Exception e) {
            return ResponseEntity
                    .internalServerError()
                    .body(e.getMessage());
        }
    }

    @PostMapping(path = "/email/{email}")
    public ResponseEntity changeEmail(@PathVariable String email, @RequestHeader String userId) {
        try {
            UserAccount user = userAccountService.changeEmail(userId, email);

            if (user != null)
                return ResponseEntity.ok("Updated Successfully");

            return new ResponseEntity("Invalid Password", HttpStatus.UNAUTHORIZED);

        } catch (Exception e) {
            return ResponseEntity
                    .internalServerError()
                    .body(e.getMessage());
        }
    }

    @PostMapping(path = "/reset")
    public ResponseEntity resetPassword(@RequestBody @Validated PasswordResetRequestDTO passwordResetRequestDTO) {
        try {
            String userId = passwordResetRequestDTO.getUserId();
            String password = passwordResetRequestDTO.getPassword();
            String secureToken = passwordResetRequestDTO.getSecureToken();

            DecodedJWT decodedJWT = secureTokenService.verifyToken(secureToken);

            if (decodedJWT != null) {
                UserAccount user = userAccountService.resetPassword(userId, password);
                return ResponseEntity.ok("password has been reset successfully");
            }
            return new ResponseEntity("Invalid secure token", HttpStatus.UNAUTHORIZED);

        } catch (Exception e) {
            return ResponseEntity
                    .internalServerError()
                    .body(e.getMessage());
        }
    }

    @GetMapping(path = "/otp/password/{userId}")
    public ResponseEntity requestOTP(@PathVariable String userId) {
        try {
            UserAccount user = userAccountService.getUserAccountByUserId(userId);
            String email = user.getEmailAddress();
            String accountStatus = user.getUserAccountStatus().toString();

            int otp = otpService.generateOTP(userId);

            // TODO: 1/16/2024 :handle email send exceptions
            emailNotificationService.sendEmailNotification(new PasswordResetTemplate(String.valueOf(otp)), email);
            return ResponseEntity
                    .ok(String.format("{\"email\": \"%s\", \"accountStatus\": \"%s\"}", email, accountStatus));

        } catch (Exception e) {
            return ResponseEntity
                    .internalServerError()
                    .body(e.getLocalizedMessage());
        }
    }

    @GetMapping(path = "/otp/verify/{userId}/{otp}")
    public ResponseEntity verifyOTP(@PathVariable String userId, @PathVariable String otp) {
        try {

            if (otp.equals(String.valueOf(otpService.getOtp(userId)))) {
                String secureToken = secureTokenService.generateToken(userId, 7200000);
                return ResponseEntity.ok(String.format("{\"secureToken\": \"%s\"}", secureToken));
            }
            return new ResponseEntity("Invalid OTP", HttpStatus.UNAUTHORIZED);

        } catch (Exception e) {
            return ResponseEntity
                    .internalServerError()
                    .body(e.getMessage());
        }
    }

    @GetMapping(path = "/stats")
    public ResponseEntity getStats() {
        try {
            return ResponseEntity.ok(userAccountService.getStats());
        } catch (Exception e) {
            return ResponseEntity
                    .internalServerError()
                    .body(e.getMessage());
        }
    }

}

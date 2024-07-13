package com.example.student_support_system.service;

import com.example.student_support_system.dto.user.UpdateUserRequestDTO;
import com.example.student_support_system.model.user.UserAccount;
import com.example.student_support_system.model.user.UserAccountRole;
import com.example.student_support_system.model.user.UserAccountStatus;
import com.example.student_support_system.repository.UserAccountRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class UserAccountServiceTest {

    @InjectMocks
    private UserAccountService userAccountService;

    @Mock
    BCryptPasswordEncoder bCryptPasswordEncoder;

    @Mock
    private UserAccountRepository userAccountRepository;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    public void createUserAccountTest() {

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

        UserAccount createdUserAccount = userAccountService.createUserAccount(userAccount);

        assertEquals(userAccount, createdUserAccount);
        verify(bCryptPasswordEncoder, times(1)).encode("password");
        verify(userAccountRepository, times(1)).save(userAccount);

    }

    @Test
    public void getUserAccountByUserIdTest() {

        UserAccount userAccount = new UserAccount(
                10L,
                "1010",
                "First Name",
                "Last Name",
                "email",
                null, UserAccountRole.STUDENT,
                "password",
                UserAccountStatus.ACTIVATED);

        when(userAccountRepository.findByUserId(userAccount.getUserId())).thenReturn(Optional.of(userAccount));

        assertEquals(userAccount, userAccountService.getUserAccountByUserId(userAccount.getUserId()));
        verify(userAccountRepository, times(1)).findByUserId(userAccount.getUserId());

    }

    @Test
    public void getUserAccountsTest() {

        UserAccount userAccount = new UserAccount(
                10L,
                "1010",
                "First Name",
                "Last Name",
                "email",
                null, UserAccountRole.STUDENT,
                "password",
                UserAccountStatus.ACTIVATED);

        List<UserAccount> userAccounts = new ArrayList<>();
        userAccounts.add(userAccount);

        when(userAccountRepository.findAll()).thenReturn(userAccounts);

        assertEquals(userAccounts, userAccountService.getAllUserAccounts());
        verify(userAccountRepository, times(1)).findAll();

    }

    @Test
    public void updateUserAccountTest() {

        UserAccount userAccount = new UserAccount(
                10L,
                "1010",
                "First Name",
                "Last Name",
                "email",
                null, UserAccountRole.STUDENT,
                "password",
                UserAccountStatus.ACTIVATED);

        when(userAccountRepository.findByUserId(userAccount.getUserId())).thenReturn(Optional.of(userAccount));
        when(userAccountRepository.save(userAccount)).thenReturn(userAccount);

        assertEquals(userAccount,
                userAccountService.updateUserAccount(
                        userAccount.getUserId(),
                        new UpdateUserRequestDTO(
                                userAccount.getUserId(),
                                userAccount.getEmailAddress(),
                                "Updated First Name",
                                userAccount.getLastName(),
                                userAccount.getRole().toString(),
                                userAccount.getImageId()
                        )));

    }

    @Test
    public void deleteUserAccountTest() {

        UserAccount userAccount = new UserAccount(
                10L,
                "1010",
                "First Name",
                "Last Name",
                "email",
                null, UserAccountRole.STUDENT,
                "password",
                UserAccountStatus.ACTIVATED);

        doNothing().when(userAccountRepository).deleteById(userAccount.getId());

        userAccountService.deleteUserAccount(userAccount.getId());

        verify(userAccountRepository, times(1)).deleteById(userAccount.getId());

    }

}
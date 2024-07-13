package com.example.student_support_system.service;


import com.example.student_support_system.dto.user.UpdateUserRequestDTO;
import com.example.student_support_system.exception.EntityNotFoundException;
import com.example.student_support_system.model.user.UserAccountStatus;
import com.example.student_support_system.model.user.UserAccountRole;
import com.example.student_support_system.model.user.UserAccount;
import com.example.student_support_system.repository.UserAccountRepository;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class UserAccountService {


    private UserAccountRepository userAccountRepository;
    private BCryptPasswordEncoder bCryptPasswordEncoder;

    public UserAccountService(UserAccountRepository userAccountRepository, BCryptPasswordEncoder passwordEncoder) {
        this.userAccountRepository = userAccountRepository;
        this.bCryptPasswordEncoder = passwordEncoder;
    }


    public UserAccount createUserAccount(UserAccount user) { // TODO: 12/16/2023 : check if the is user already exists
        user.setPassword(bCryptPasswordEncoder.encode(user.getPassword()));
        return userAccountRepository.save(user);
    }

    public UserAccount getUserAccountByUserId(String userId) {
        Optional<UserAccount> user = userAccountRepository.findByUserId(userId);
        return unwrapUser(user, userId);
    }

    public List<UserAccount> getAcademicStaff() {
        List<UserAccountRole> roles = Arrays.asList(
                UserAccountRole.LECTURER,
                UserAccountRole.INSTRUCTOR,
                UserAccountRole.ACADEMIC_ADMINISTRATION);
        List<UserAccount> users = userAccountRepository.findByRoleIn(roles);
        return users;
    }

    public UserAccount updateUserAccount(String userId, UpdateUserRequestDTO updateUserRequestDTO) {
        Optional<UserAccount> user = userAccountRepository.findByUserId(userId);

        UserAccount updatedUser = unwrapUser(user, userId);
        updatedUser.setUserId(updateUserRequestDTO.getUserId());
        updatedUser.setFirstName(updateUserRequestDTO.getFirstName());
        updatedUser.setLastName(updateUserRequestDTO.getLastName());
        updatedUser.setEmailAddress(updateUserRequestDTO.getEmailAddress());
        updatedUser.setRole(UserAccountRole.valueOf(updateUserRequestDTO.getRole()));
        updatedUser.setImageId(updateUserRequestDTO.getImageId());

        System.out.println(updatedUser);

        return userAccountRepository.save(updatedUser);
    }

    public void deleteUserAccount(Long id) {
        userAccountRepository.deleteById(id);
    }

    public List<UserAccount> getAllUserAccounts() {
        return userAccountRepository.findAll();
    }

    public void activateUserAccount(String userId) {
        Optional<UserAccount> user = userAccountRepository.findByUserId(userId);
        UserAccount activateUser = unwrapUser(user, userId);
        activateUser.setUserAccountStatus(UserAccountStatus.ACTIVATED);
        userAccountRepository.save(activateUser);
    }

    public UserAccount changePassword(String userId, String currPassword, String newPassword) {
        Optional<UserAccount> user = userAccountRepository.findByUserId(userId);
        UserAccount updateUser = unwrapUser(user, userId);

        if (bCryptPasswordEncoder.matches(currPassword, updateUser.getPassword())) {
            updateUser.setPassword(bCryptPasswordEncoder.encode(newPassword));
            return userAccountRepository.save(updateUser);
        }
        else return null;
    }

    public UserAccount resetPassword(String userId, String password) {
        Optional<UserAccount> user = userAccountRepository.findByUserId(userId);
        UserAccount resetUser = unwrapUser(user, userId);
        resetUser.setPassword(bCryptPasswordEncoder.encode(password));
        return userAccountRepository.save(resetUser);
    }

    public UserAccount changeEmail(String userId, String email) {
        Optional<UserAccount> user = userAccountRepository.findByUserId(userId);
        UserAccount unwrappedUser = unwrapUser(user, userId);
        unwrappedUser.setEmailAddress(email);
        unwrappedUser.setUserAccountStatus(UserAccountStatus.PENDING);
        return userAccountRepository.save(unwrappedUser);
    }

    public Map<String, String> getStats() {
        Map<String, String> stats = new HashMap<>();

        long total = userAccountRepository.count();
        Long students = userAccountRepository.countByRole(UserAccountRole.STUDENT);
        Long lecturers = userAccountRepository.countByRole(UserAccountRole.LECTURER);
        Long admins = userAccountRepository.countByRole(UserAccountRole.SYSTEM_ADMIN);
        Long instructors = userAccountRepository.countByRole(UserAccountRole.INSTRUCTOR);

        stats.put("total", Long.toString(total));
        stats.put("students", students.toString());
        stats.put("lecturers", lecturers.toString());
        stats.put("admins", admins.toString());
        stats.put("instructors", instructors.toString());

        return stats;
    }

    static UserAccount unwrapUser(Optional<UserAccount> entity, String id) {
        if (entity.isPresent()) return entity.get();
        else throw new EntityNotFoundException(id, UserAccount.class);
    }

}

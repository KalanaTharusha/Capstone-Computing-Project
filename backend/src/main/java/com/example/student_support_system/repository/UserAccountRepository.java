package com.example.student_support_system.repository;

import com.example.student_support_system.model.user.UserAccountRole;
import com.example.student_support_system.model.user.UserAccount;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;


@Repository
public interface UserAccountRepository extends JpaRepository<UserAccount, Long> {

    Optional<UserAccount> findByUserId(String userId);
    Long countByRole(UserAccountRole role);
    List<UserAccount> findByRoleIn(List<UserAccountRole> roles);
}

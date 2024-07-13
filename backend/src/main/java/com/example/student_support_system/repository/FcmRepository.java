package com.example.student_support_system.repository;

import com.example.student_support_system.model.Fcm;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
public interface FcmRepository extends JpaRepository<Fcm, Long> {

    List<Fcm> findByUserId(Long userId);

    @Query("SELECT d.fcmToken FROM Fcm d WHERE d.userId = :userId")
    List<String> findFcmTokenByUserId(Long userId);

    Fcm findByFcmToken(String fcmToken);

    @Modifying
    @Transactional
    @Query("UPDATE Fcm d SET d.fcmToken = :newFcmToken WHERE d.fcmToken = :oldFcmToken")
    void updateFcmTokenByFcmToken(String oldFcmToken, String newFcmToken);

    @Modifying
    @Transactional
    @Query("UPDATE Fcm d SET d.userId = :userId WHERE d.fcmToken = :fcmToken")
    void updateUserIdByFcmToken(Long userId, String fcmToken);

    Boolean existsByFcmToken(String fcmToken);
}

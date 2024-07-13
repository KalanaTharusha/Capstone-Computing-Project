package com.example.student_support_system.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.CrossOrigin;

import com.example.student_support_system.exception.EntityNotFoundException;
import com.example.student_support_system.model.Fcm;
import com.example.student_support_system.model.user.UserAccount;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import com.example.student_support_system.repository.FcmRepository;
import com.example.student_support_system.repository.UserAccountRepository;
import com.google.cloud.storage.Acl.User;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.Notification;

@CrossOrigin(origins = "*")
@Service
public class FcmService {

    @Autowired
    private FirebaseMessaging firebaseMessaging;
    private FcmRepository fcmRepository;
    private UserAccountRepository userAccountRepository;

    public FcmService(FcmRepository fcmRepository, UserAccountRepository userAccountRepository) {
        this.fcmRepository = fcmRepository;
        this.userAccountRepository = userAccountRepository;
    }

    public Fcm createFcmToken(String userId, String fcmToken) {

        Fcm fcmEntry = fcmRepository.findByFcmToken(fcmToken);
        Optional<UserAccount> optionalUser = userAccountRepository.findByUserId(userId);
        UserAccount user = unwrapUser(optionalUser, userId);

        if (fcmEntry != null) {
            if (fcmEntry.getUserId() == user.getId()) {
                return fcmEntry;
            } else {
                fcmRepository.updateUserIdByFcmToken(user.getId(), fcmToken);
                return fcmEntry;
            }
        } else {
            Fcm newFcm = new Fcm();
            newFcm.setFcmToken(fcmToken);
            newFcm.setUserId(user.getId());

            return fcmRepository.save(newFcm);
        }

    }

    public void updateFcmToken(String oldFcmToken, String newFcmToken) {
        if (fcmRepository.existsByFcmToken(oldFcmToken)) {
            fcmRepository.updateFcmTokenByFcmToken(oldFcmToken, newFcmToken);
        }
    }

    public void sendNotificationToUser(Long userId, String title, String body) {

        List<String> fcmTokens = new ArrayList<>();
        List<String> tokens = fcmRepository.findFcmTokenByUserId(userId);
        fcmTokens.addAll(tokens);

        if (fcmTokens.isEmpty()) {
            return;
        }

        com.google.firebase.messaging.MulticastMessage multiMessage = com.google.firebase.messaging.MulticastMessage
                .builder()
                .setNotification(Notification.builder()
                        .setTitle(title)
                        .setBody(body)
                        .build())
                .addAllTokens(fcmTokens)
                .build();

        try {
            firebaseMessaging.sendMulticast(multiMessage);
        } catch (FirebaseMessagingException e) {
            e.printStackTrace();
        }

    }

    public void sendNotificationToAll(String title, String body) {
        List<String> fcmTokens = new ArrayList<>();
        List<Fcm> fcmList = fcmRepository.findAll();
        for (Fcm fcm : fcmList) {
            fcmTokens.add(fcm.getFcmToken());
        }

        if (fcmTokens.isEmpty()) {
            return;
        }

        com.google.firebase.messaging.MulticastMessage multiMessage = com.google.firebase.messaging.MulticastMessage
                .builder()
                .setNotification(Notification.builder()
                        .setTitle(title)
                        .setBody(body)
                        .build())
                .addAllTokens(fcmTokens)
                .build();

        try {
            firebaseMessaging.sendMulticast(multiMessage);
        } catch (FirebaseMessagingException e) {
            e.printStackTrace();
        }
    }

    public List<Fcm> getDeviceTokensByUserId(Long userId) {
        return fcmRepository.findByUserId(userId);
    }

    public Boolean existsByFcmToken(String fcmToken) {
        return fcmRepository.existsByFcmToken(fcmToken);
    }

    static UserAccount unwrapUser(Optional<UserAccount> entity, String id) {
        if (entity.isPresent())
            return entity.get();
        else
            throw new EntityNotFoundException(id, UserAccount.class);
    }
}

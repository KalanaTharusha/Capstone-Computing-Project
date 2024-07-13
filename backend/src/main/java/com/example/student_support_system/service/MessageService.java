package com.example.student_support_system.service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.student_support_system.dto.message.DeleteMessageDTO;
import com.example.student_support_system.dto.message.EditMessageDTO;
import com.example.student_support_system.dto.message.NewMessageDTO;
import com.example.student_support_system.exception.EntityNotFoundException;
import com.example.student_support_system.exception.UnauthorizedException;
import com.example.student_support_system.model.Channel;
import com.example.student_support_system.model.Message;
import com.example.student_support_system.model.user.UserAccount;
import com.example.student_support_system.repository.ChannelRepository;
import com.example.student_support_system.repository.FcmRepository;
import com.example.student_support_system.repository.MessageRepository;
import com.example.student_support_system.repository.UserAccountRepository;
import com.example.student_support_system.util.logging.AppLogger;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.Notification;

@Service
public class MessageService {

    @Autowired
    private FirebaseMessaging firebaseMessaging;

    private MessageRepository messageRepository;
    private ChannelRepository channelRepository;
    private UserAccountRepository userAccountRepository;
    private FcmRepository fcmRepository;
    private FileDataService fileService;

    public MessageService(MessageRepository messageRepository, ChannelRepository channelRepository,
            UserAccountRepository userAccountRepository, FcmRepository fcmRepository) {
        this.messageRepository = messageRepository;
        this.channelRepository = channelRepository;
        this.userAccountRepository = userAccountRepository;
        this.fcmRepository = fcmRepository;
        this.fileService = fileService;
    }

    public List<Message> getMessagesByChannel(Long channelId) {
        Optional<Channel> optionalChannel = channelRepository.findById(channelId);
        unwrapChannel(optionalChannel, channelId);

        return messageRepository.findByChannelId(channelId);
    }

    public Message createMessage(NewMessageDTO newMessageDTO) {

        Optional<Channel> optionalChannel = channelRepository.findById(Long.parseLong(newMessageDTO.getChannelId()));
        Channel channel = unwrapChannel(optionalChannel, Long.parseLong(newMessageDTO.getChannelId()));

        Optional<UserAccount> optionalUser = userAccountRepository.findByUserId(newMessageDTO.getUserId());
        UserAccount user = unwrapUser(optionalUser, newMessageDTO.getUserId());

        if (!channel.getMembers().contains(user)) {
            UnauthorizedException error = new UnauthorizedException(
                    user.getUserId() + " is not a member of " + channel.getName());
            AppLogger.error("User is not subscribed to channel", error); // replace with custom // exception
        }

        List<String> fcmTokens = new ArrayList<>();

        for (UserAccount member : channel.getMembers()) {
            if (member.getUserId() != user.getUserId().toString()) {
                List<String> tokens = fcmRepository.findFcmTokenByUserId(member.getId());
                fcmTokens.addAll(tokens);
            }
        }

        Message message = new Message();
        message.setChannel(channel);
        message.setUser(user);
        message.setData(newMessageDTO.getData());
        message.setType(newMessageDTO.getType());
        message.setDateTimeSent(newMessageDTO.getDateTimeSent());
        message.setAttachmentId(newMessageDTO.getAttachmentId());
        message.setAttachmentSize(newMessageDTO.getAttachmentSize());

        Message savedMsg = messageRepository.save(message);

        if (!fcmTokens.isEmpty()) {

            com.google.firebase.messaging.MulticastMessage multiMessage = com.google.firebase.messaging.MulticastMessage
                    .builder()
                    .setNotification(Notification.builder()
                            .setTitle(channel.getName())
                            .setBody(newMessageDTO.getData())
                            .build())
                    .putData("category", "CHAT")
                    .putData("type", "NEW")
                    .putData("clickAction", "CHAT")
                    .putData("id", savedMsg.getId().toString())
                    .putData("channelId", newMessageDTO.getChannelId())
                    .putData("userId", newMessageDTO.getUserId())
                    .putData("firstName", user.getFirstName())
                    .putData("msgType", newMessageDTO.getType())
                    .putData("data", newMessageDTO.getData())
                    .putData("dateTimeSent", newMessageDTO.getDateTimeSent().toString())
                    .putData("modifiedBy", newMessageDTO.getUserId())
                    .putData("attachmentId", newMessageDTO.getAttachmentId())
                    .putData("attachmentSize", String.valueOf(newMessageDTO.getAttachmentSize()))
                    .addAllTokens(fcmTokens)
                    .build();

            try {
                firebaseMessaging.sendMulticast(multiMessage);
            } catch (FirebaseMessagingException e) {
                AppLogger.error("FCM error during create message", e);
            }
        }

        channel.setLastMessageId(savedMsg.getId());
        channelRepository.save(channel);

        return savedMsg;
    }

    public Message editMessage(EditMessageDTO editMessageDTO) {
        Optional<Message> optionalMessage = messageRepository.findById(editMessageDTO.getMessageId());
        Message message = unwrapMessage(optionalMessage, editMessageDTO.getMessageId().toString());

        if (message.getUser().getUserId().equals(editMessageDTO.getUserId())) {

            message.setData(editMessageDTO.getText());

            messageRepository.save(message);

            Channel channel = message.getChannel();
            UserAccount user = message.getUser();

            List<String> fcmTokens = new ArrayList<>();

            for (UserAccount member : channel.getMembers()) {
                if (member.getUserId() != editMessageDTO.getModifiedBy()) {
                    List<String> tokens = fcmRepository.findFcmTokenByUserId(member.getId());
                    fcmTokens.addAll(tokens);
                }
            }

            if (!fcmTokens.isEmpty()) {
                com.google.firebase.messaging.MulticastMessage multiMessage = com.google.firebase.messaging.MulticastMessage
                        .builder()
                        .putData("category", "CHAT")
                        .putData("type", "EDIT")
                        .putData("id", message.getId().toString())
                        .putData("channelId", channel.getId().toString())
                        .putData("userId", user.getUserId())
                        .putData("firstName", user.getFirstName())
                        .putData("msgType", message.getType())
                        .putData("data", message.getData())
                        .putData("dateTimeSent", message.getDateTimeSent().toString())
                        .putData("modifiedBy", editMessageDTO.getModifiedBy().toString())
                        .putData("attachmentId", message.getAttachmentId())
                        .putData("attachmentSize", String.valueOf(message.getAttachmentSize()))
                        .addAllTokens(fcmTokens)
                        .build();

                try {
                    firebaseMessaging.sendMulticast(multiMessage);
                } catch (FirebaseMessagingException e) {
                    AppLogger.error("FCM error during edit message", e);
                }
            }

        } else {
            UnauthorizedException unauthorizedException = new UnauthorizedException(
                    editMessageDTO.getUserId() + " is not the owner of the message " + message.getId());
            AppLogger.error("User is not the owner of the message", unauthorizedException);
            throw unauthorizedException;
        }
        return message;
    }

    public Message deleteMessage(DeleteMessageDTO deleteMessageDTO) {
        Optional<Message> optionalMessage = messageRepository.findById(deleteMessageDTO.getMessageId());
        Message message = unwrapMessage(optionalMessage, deleteMessageDTO.getMessageId().toString());

        Channel channelOfMessage = message.getChannel();

        List<String> fcmTokens = new ArrayList<>();

        for (UserAccount member : channelOfMessage.getMembers()) {

            if (member.getUserId().equals(deleteMessageDTO.getModifiedBy())) {
                List<String> tokens = fcmRepository.findFcmTokenByUserId(member.getId());
                fcmTokens.addAll(tokens);
            }
        }

        if (!fcmTokens.isEmpty()) {
            com.google.firebase.messaging.MulticastMessage multiMessage = com.google.firebase.messaging.MulticastMessage
                    .builder()
                    .putData("channelId", message.getChannel().getId().toString())
                    .putData("userId", message.getUser().getUserId())
                    .putData("id", message.getId().toString())
                    .putData("category", "CHAT")
                    .putData("type", "DELETE")
                    .putData("modifiedBy", deleteMessageDTO.getModifiedBy())
                    .addAllTokens(fcmTokens)
                    .build();

            try {
                firebaseMessaging.sendMulticast(multiMessage);
            } catch (FirebaseMessagingException e) {
                AppLogger.error("FCM error during delete message", e);
            }
        }

        if (message.getAttachmentId() != null && !message.getAttachmentId().isBlank()) {
            fileService.deleteFile(message.getAttachmentId());
        }

        messageRepository.delete(message);

        List<Message> messages = getMessagesByChannel(channelOfMessage.getId());

        if (messages.isEmpty()) {
            channelOfMessage.setLastMessageId(null);
            channelRepository.save(channelOfMessage);
        } else {
            channelOfMessage.setLastMessageId(messages.get(messages.size() - 1).getId());
            channelRepository.save(channelOfMessage);
        }

        return message;
    }

    static Message unwrapMessage(Optional<Message> entity, String id) {
        if (entity.isPresent())
            return entity.get();
        else
            throw new EntityNotFoundException(id, Message.class);
    }

    static UserAccount unwrapUser(Optional<UserAccount> entity, String id) {
        if (entity.isPresent())
            return entity.get();
        else
            throw new EntityNotFoundException(id, UserAccount.class);
    }

    static Channel unwrapChannel(Optional<Channel> entity, Long id) {
        if (entity.isPresent())
            return entity.get();
        else
            throw new EntityNotFoundException(id.toString(), Channel.class);
    }
}

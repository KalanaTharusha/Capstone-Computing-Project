package com.example.student_support_system.controller;

import java.util.Collections;

import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import com.example.student_support_system.dto.message.DeleteMessageDTO;
import com.example.student_support_system.dto.message.EditMessageDTO;
import com.example.student_support_system.dto.message.NewMessageDTO;
import com.example.student_support_system.model.Message;
import com.example.student_support_system.service.MessageService;
import com.google.api.services.storage.Storage.BucketAccessControls.Delete;

@ExtendWith(MockitoExtension.class)
public class MessagesControllerTest {

    @Mock
    private MessageService messageService;

    @InjectMocks
    private MessageController messageController;

    @Test
    void testGetMessagesByChannel() {
        try {
            Message message = new Message();
            Mockito.when(messageService.getMessagesByChannel(1L)).thenReturn(Collections.singletonList(message));

            ResponseEntity response = messageController.getMessagesByChannel(1L);

            Mockito.verify(messageService, Mockito.times(1)).getMessagesByChannel(1L);
            Assertions.assertEquals(HttpStatus.OK, response.getStatusCode());
            Assertions.assertEquals(Collections.singletonList(message), response.getBody());
        } catch (Exception e) {
            Assertions.fail("getMessagesByChannelTest failed", e);
        }

    };

    @Test
    void testCreateMessage() {
        try {
            Message message = new Message();
            NewMessageDTO newMessageDTO = new NewMessageDTO();
            Mockito.when(messageService.createMessage(newMessageDTO)).thenReturn(message);

            ResponseEntity response = messageController.createMessage(newMessageDTO);

            Mockito.verify(messageService, Mockito.times(1)).createMessage(newMessageDTO);
            Assertions.assertEquals(HttpStatus.OK, response.getStatusCode());
            Assertions.assertEquals(message, response.getBody());
        } catch (Exception e) {
            Assertions.fail("createMessageTest failed", e);
        }
    };

    @Test
    void testDeleteMessage() {
        try {
            Message message = new Message();
            DeleteMessageDTO deleteMessageDTO = new DeleteMessageDTO();

            Mockito.when(messageService.deleteMessage(deleteMessageDTO)).thenReturn(message);

            ResponseEntity response = messageController.deleteMessage(deleteMessageDTO);

            Mockito.verify(messageService, Mockito.times(1)).deleteMessage(deleteMessageDTO);
            Assertions.assertEquals(HttpStatus.OK, response.getStatusCode());
            Assertions.assertEquals(message, response.getBody());
        } catch (Exception e) {
            Assertions.fail("deleteMessageTest failed", e);
        }
    };

    @Test
    void testEditMessage() {
        try {
            Message message = new Message();
            EditMessageDTO editMessageDTO = new EditMessageDTO();

            Mockito.when(messageService.editMessage(editMessageDTO)).thenReturn(message);

            ResponseEntity response = messageController.editMessage(editMessageDTO);

            Mockito.verify(messageService, Mockito.times(1)).editMessage(editMessageDTO);
            Assertions.assertEquals(HttpStatus.OK, response.getStatusCode());
            Assertions.assertEquals(message, response.getBody());
        } catch (Exception e) {
            Assertions.fail("editMessageTest failed", e);
        }
    };

}

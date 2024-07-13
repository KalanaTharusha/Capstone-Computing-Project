package com.example.student_support_system.controller;

import com.example.student_support_system.dto.chatbot.ChatBotReplyDTO;
import com.example.student_support_system.dto.chatbot.ChatBotRequestDTO;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

@ExtendWith(MockitoExtension.class)
public class ChatbotControllerTest{

    @InjectMocks
    private ChatBotController chatBotController;
    @Test
    void testCreateChatMessageFound() throws Exception{
        try {
            ChatBotRequestDTO requestDTO = new ChatBotRequestDTO();
            ChatBotReplyDTO replyDTO = new ChatBotReplyDTO();
            requestDTO.setQuestion("What are the locations of the lecture halls?");

            ResponseEntity response = chatBotController.chat(requestDTO);

            replyDTO.setReply(response.getBody().toString());
            String reply = replyDTO.getReply();

            Assertions.assertEquals(HttpStatus.OK, response.getStatusCode());
            Assertions.assertTrue(reply.contains("LT105"));

        }
        catch (Exception e) {
            Assertions.fail("createChatMessageTest failed", e);
        }
    }

    @Test
    void testCreateChatMessageNotFound() throws Exception{
        try {
            ChatBotRequestDTO requestDTO = new ChatBotRequestDTO();
            ChatBotReplyDTO replyDTO = new ChatBotReplyDTO();
            requestDTO.setQuestion("What is the weather today?");

            ResponseEntity response = chatBotController.chat(requestDTO);

            replyDTO.setReply(response.getBody().toString());
            String reply = replyDTO.getReply();

            Assertions.assertEquals(HttpStatus.OK, response.getStatusCode());
            Assertions.assertEquals(reply,response.getBody().toString());

        }
        catch (Exception e) {
            Assertions.fail("createChatMessageTest failed", e);
        }
    }


}

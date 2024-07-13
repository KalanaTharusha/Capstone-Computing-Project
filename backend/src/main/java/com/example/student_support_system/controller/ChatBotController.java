package com.example.student_support_system.controller;

import com.example.student_support_system.dto.chatbot.ChatBotReplyDTO;
import com.example.student_support_system.dto.chatbot.ChatBotRequestDTO;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

@CrossOrigin("*")
@RestController
@RequestMapping(path = "/api/chatbot", produces = MediaType.APPLICATION_JSON_VALUE)
public class ChatBotController {
    final String BASE_URL = "https://api.chatpdf.com/v1/chats/message";
    final String API_KEY = "sec_AqoWqc77f20f5P6WSA9iJFj2CyGcWGpJ";
    final String SOURCE_ID = "cha_zCatKl2Ys3fcNqFmkdg52";
    final String ROLE = "user";

    @PostMapping(path = "/chat")
    public ResponseEntity chat(@RequestBody ChatBotRequestDTO chatBotRequestDTO) {

        String jsonInputString = String.format("""
                 {
                     "sourceId" : "%s",
                     "messages" : [
                         {
                             "role" : "%s",
                             "content" : "%s"
                         }
                     ]
                 }
                """, SOURCE_ID, ROLE, chatBotRequestDTO);

        try {
            var client = HttpClient.newHttpClient();
            var request = HttpRequest.newBuilder(
                    URI.create(BASE_URL))
                    .header("Content-Type", "application/json")
                    .header("x-api-key", API_KEY)
                    .POST(HttpRequest.BodyPublishers.ofString(jsonInputString))
                    .build();

            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

            ObjectMapper objectMapper = new ObjectMapper();
            JsonNode jsonNode = objectMapper.readTree(response.body());

            ChatBotReplyDTO chatBotReplyDTO = new ChatBotReplyDTO();
            chatBotReplyDTO.setReply(jsonNode.get("content").asText());

            return ResponseEntity.ok(chatBotReplyDTO);

        } catch (IOException e) {
            throw new RuntimeException(e);
        } catch (InterruptedException e) {
            throw new RuntimeException(e);
        }
    }
}

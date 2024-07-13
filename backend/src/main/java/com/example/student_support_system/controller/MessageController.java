package com.example.student_support_system.controller;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.student_support_system.dto.message.NewMessageDTO;
import com.example.student_support_system.dto.message.DeleteMessageDTO;
import com.example.student_support_system.dto.message.EditMessageDTO;
import com.example.student_support_system.service.MessageService;

import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

@CrossOrigin(origins = "*", allowedHeaders = "*")
@RestController
@RequestMapping(value = "/api/messages", produces = "application/json")
public class MessageController {

    private final MessageService messageService;

    public MessageController(MessageService messageService) {
        this.messageService = messageService;
    }

    @GetMapping("/{channelId}")
    public ResponseEntity getMessagesByChannel(@PathVariable Long channelId) {
        try {
            return ResponseEntity
                    .ok()
                    .body(messageService.getMessagesByChannel(channelId));
        } catch (Exception exception) {
            return ResponseEntity
                    .internalServerError()
                    .body(exception.getMessage());
        }
    }

    @PostMapping("/new")
    public ResponseEntity createMessage(@RequestBody @Validated NewMessageDTO newMessageDTO) {
        try {
            return ResponseEntity
                    .ok()
                    .body(messageService.createMessage(newMessageDTO));
        } catch (Exception exception) {
            return ResponseEntity
                    .internalServerError()
                    .body(exception.getMessage());
        }
    }

    @DeleteMapping("/delete")
    public ResponseEntity deleteMessage(@RequestBody @Validated DeleteMessageDTO deleteMessageDTO) {
        try {
            return ResponseEntity
                    .ok()
                    .body(messageService.deleteMessage(deleteMessageDTO));
        } catch (Exception exception) {
            return ResponseEntity
                    .internalServerError()
                    .body(exception.getMessage());
        }
    }

    @PostMapping("/edit")
    public ResponseEntity editMessage(@RequestBody @Validated EditMessageDTO editMessageDTO) {
        try {
            return ResponseEntity
                    .ok()
                    .body(messageService.editMessage(editMessageDTO));
        } catch (Exception exception) {
            return ResponseEntity
                    .internalServerError()
                    .body(exception.getMessage());
        }
    }
}

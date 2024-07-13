package com.example.student_support_system.service;

import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;
import com.auth0.jwt.interfaces.DecodedJWT;
import com.example.student_support_system.security.SecurityConstants;
import org.springframework.stereotype.Service;

import java.util.Date;

@Service
public class SecureTokenService {

    public String generateToken(String userId, long expirationMillis) {
        Date now = new Date();
        Date expirationDate = new Date(now.getTime() + expirationMillis);

        String secureToken = JWT.create()
                .withSubject(userId)
                .withExpiresAt(new Date(System.currentTimeMillis() + expirationMillis))
                .sign(Algorithm.HMAC512(SecurityConstants.SECURE_TOKEN_SECRET_KEY));

        return secureToken;
    }

    public DecodedJWT verifyToken(String token) {
        try {
            DecodedJWT decodedJWT = JWT.require(Algorithm.HMAC512(SecurityConstants.SECURE_TOKEN_SECRET_KEY))
                    .build()
                    .verify(token);

            return decodedJWT;
        } catch (Exception e) {
            System.out.println(e.getMessage());
            return null;
        }
    }

}

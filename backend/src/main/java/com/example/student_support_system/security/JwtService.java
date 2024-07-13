package com.example.student_support_system.security;


import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;
import com.example.student_support_system.model.user.UserAccountRole;
import org.springframework.stereotype.Service;

@Service
public class JwtService {

    public String getUserIdFromJwt(String jwtToken) {
        String userId = JWT.require(Algorithm.HMAC512(SecurityConstants.SECRET_KEY))
                .build()
                .verify(jwtToken)
                .getSubject();

        return userId;
    }

    public UserAccountRole getUserRoleFromJWt(String jwtToken) {
        String role = JWT.require(Algorithm.HMAC512(SecurityConstants.SECRET_KEY))
                .build()
                .verify(jwtToken)
                .getClaim("role")
                .asString();

        return UserAccountRole.valueOf(role);
    }
}

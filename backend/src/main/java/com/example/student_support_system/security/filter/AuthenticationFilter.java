package com.example.student_support_system.security.filter;

import com.example.student_support_system.dto.user.LogInUserResponseDTO;
import com.example.student_support_system.model.user.UserAccount;
import com.example.student_support_system.security.SecurityConstants;
import com.example.student_support_system.security.manager.CustomAuthenticationManager;
import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;
import com.example.student_support_system.service.UserAccountService;
import com.example.student_support_system.util.logging.AppLogger;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.AllArgsConstructor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

import java.io.IOException;
import java.util.Date;


@AllArgsConstructor
public class AuthenticationFilter extends UsernamePasswordAuthenticationFilter {

    private CustomAuthenticationManager authenticationManager;
    private UserAccountService userAccountServiceImpl;

    @Override
    public Authentication attemptAuthentication(HttpServletRequest request, HttpServletResponse response) throws AuthenticationException {
        //            SparkleUser user = new ObjectMapper().readValue(request.getInputStream(), SparkleUser.class);
        String userId = request.getHeader("userId");
        String password = request.getHeader("password");
        Authentication authentication = new UsernamePasswordAuthenticationToken(userId, password);
        return authenticationManager.authenticate(authentication);
    }

    @Override
    protected void successfulAuthentication(HttpServletRequest request, HttpServletResponse response, FilterChain chain, Authentication authResult) throws IOException, ServletException {
        UserAccount user = userAccountServiceImpl.getUserAccountByUserId(authResult.getName());
        String token = JWT.create()
                .withSubject(user.getUserId())
                .withClaim("role", user.getRole().getValue())
                .withExpiresAt(new Date(System.currentTimeMillis() + SecurityConstants.TOKEN_EXPIRATION))
                .sign(Algorithm.HMAC512(SecurityConstants.SECRET_KEY));
        response.addHeader(SecurityConstants.AUTHORIZATION, SecurityConstants.BEARER + token);

        LogInUserResponseDTO responseDto = new LogInUserResponseDTO(user.getUserId(), token);
        ObjectMapper mapper = new ObjectMapper();
        String body = mapper.writeValueAsString(responseDto);

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(body);
        response.getWriter().flush();

        AppLogger.info("Successfully authenticated user with id: " + user.getUserId() + " and issued token: " + token);
    }

    @Override
    protected void unsuccessfulAuthentication(HttpServletRequest request, HttpServletResponse response, AuthenticationException failed) throws IOException, ServletException {

        String userId = request.getHeader("userId");

        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(failed.getMessage());
        response.getWriter().flush();

        AppLogger.warn("Failed to authenticate user: " + failed.getMessage() + " for userId: " + userId);
    }
}

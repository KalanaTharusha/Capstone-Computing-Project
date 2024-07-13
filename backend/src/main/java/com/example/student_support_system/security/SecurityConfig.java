package com.example.student_support_system.security;

import com.example.student_support_system.model.user.UserAccountRole;
import com.example.student_support_system.security.filter.AuthenticationFilter;
import com.example.student_support_system.security.filter.ExceptionHandlerFilter;
import com.example.student_support_system.security.filter.JWTAuthorizationFilter;
import com.example.student_support_system.security.manager.CustomAuthenticationManager;
import com.example.student_support_system.service.UserAccountService;

import lombok.AllArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.web.cors.CorsConfiguration;

import java.util.List;

@Configuration
@AllArgsConstructor
public class SecurityConfig {
    CustomAuthenticationManager authenticationManager;
    UserAccountService userAccountService;

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {

        AuthenticationFilter authenticationFilter = new AuthenticationFilter(authenticationManager, userAccountService);
        authenticationFilter.setFilterProcessesUrl(SecurityConstants.AUTHENTICATE_PATH);

        http
                .cors(httpSecurityCorsConfigurer -> httpSecurityCorsConfigurer.configurationSource(
                        request -> {
                            var cors = new CorsConfiguration();
                            cors.setAllowedOrigins(List.of("*"));
                            cors.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"));
                            cors.setAllowedHeaders(List.of("*"));
                            cors.setExposedHeaders(List.of("*"));
                            return cors;
                        }
                ))
                .headers(headers -> headers.frameOptions(frameOptions -> frameOptions.disable()))
                .csrf(httpSecurityCsrfConfigurer -> httpSecurityCsrfConfigurer.disable())
                .authorizeHttpRequests(authorize -> authorize
                        .requestMatchers(HttpMethod.GET, SecurityConstants.SWAGGER_UI_PATH).permitAll()
                        .requestMatchers(HttpMethod.GET, SecurityConstants.SWAGGER_API_DOC_PATH).permitAll()
                        .requestMatchers(HttpMethod.POST, SecurityConstants.SIGNUP_PATH).permitAll()
                        .requestMatchers(HttpMethod.POST, SecurityConstants.ACTIVATE_PATH).permitAll()
                        .requestMatchers(HttpMethod.POST, SecurityConstants.PASSWORD_RESET_PATH).permitAll()
                        .requestMatchers(HttpMethod.GET, SecurityConstants.OTP_PATH).permitAll()
                        .requestMatchers(HttpMethod.DELETE, SecurityConstants.COMMUNICATION_CHANNEL_PATH)
                            .hasAnyAuthority(UserAccountRole.SYSTEM_ADMIN.getValue(), UserAccountRole.ACADEMIC_ADMINISTRATION.getValue())
                        .requestMatchers(HttpMethod.PUT, SecurityConstants.COMMUNICATION_CHANNEL_PATH)
                            .hasAnyAuthority(UserAccountRole.SYSTEM_ADMIN.getValue(), UserAccountRole.ACADEMIC_ADMINISTRATION.getValue())
                        .requestMatchers("/api/test/**").permitAll()
                        .requestMatchers("/api/files/**").permitAll()
                        .requestMatchers("/api/announcements/**").permitAll()
                        .requestMatchers("/api/events/**").permitAll()
                        .anyRequest().authenticated()
                )
                .addFilterBefore(new ExceptionHandlerFilter(), AuthenticationFilter.class)
                .addFilter(authenticationFilter)
                .addFilterAfter(new JWTAuthorizationFilter(userAccountService), AuthenticationFilter.class)
                .sessionManagement(sessionManagement -> sessionManagement.sessionCreationPolicy(SessionCreationPolicy.STATELESS));

        return http.build();
    }


}

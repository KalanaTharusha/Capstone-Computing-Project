package com.example.student_support_system.security.manager;

import com.example.student_support_system.model.user.UserAccountStatus;
import com.example.student_support_system.model.user.UserAccount;
import com.example.student_support_system.service.UserAccountService;
import com.example.student_support_system.util.logging.AppLogger;
import jakarta.persistence.EntityNotFoundException;
import lombok.AllArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;

@Component
@AllArgsConstructor
public class CustomAuthenticationManager implements AuthenticationManager {

    private UserAccountService userAccountServiceImpl;
    private BCryptPasswordEncoder bCryptPasswordEncoder;
    @Override
    public Authentication authenticate(Authentication authentication) throws AuthenticationException {
        AppLogger.info("Authenticating user with id: " + authentication.getName());
        UserAccount user = userAccountServiceImpl.getUserAccountByUserId(authentication.getName());
        if (user == null) throw new EntityNotFoundException();
        if (!bCryptPasswordEncoder.matches(authentication.getCredentials().toString(), user.getPassword())) {
            throw new BadCredentialsException("Invalid Credentials");
        }
        if (user.getUserAccountStatus() != UserAccountStatus.ACTIVATED) {
            throw new BadCredentialsException("Account is not activated");
        }

        return new UsernamePasswordAuthenticationToken(authentication.getName(), user.getPassword(), getAuthority(user.getRole().getValue()));
    }

    private List<SimpleGrantedAuthority> getAuthority(String authority) {
        List<SimpleGrantedAuthority> authorities = new ArrayList<>();
        authorities.add(new SimpleGrantedAuthority(authority));
        return authorities;
    }
}

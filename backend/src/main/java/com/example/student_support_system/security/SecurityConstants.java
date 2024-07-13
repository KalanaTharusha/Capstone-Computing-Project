package com.example.student_support_system.security;

public class SecurityConstants {
    public static final String SECRET_KEY = "A%D*G-KaPdSgVkYp3s6v9y$B&E(H+MbQeThWmZq4t7w!z%C*F-J@NcRfUjXn2r5u";
    public static final String SECURE_TOKEN_SECRET_KEY = "e2cb94936772ad10da990cdc712c1aef6f07f9943d3d34964a61ad84c367bbf3";

    public static final int TOKEN_EXPIRATION = 7200000;

    public static final String BEARER = "Bearer ";

    public static final String AUTHORIZATION = "Authorization";

    public static final String AUTHENTICATE_PATH = "/authenticate";

    public static final String SIGNUP_PATH = "/api/users/register";

    public static final String SWAGGER_UI_PATH = "swagger-ui/**";

    public static final String SWAGGER_API_DOC_PATH = "/api-docs/**";

    public static final String ADMIN_REGISTER_PATH = "/api/users/admin"; // TODO: 12/8/2023 : Needs to implement

    public static final String ACTIVATE_PATH = "/api/users/activate";

    public static final String PASSWORD_RESET_PATH = "/api/users/reset";

    public static final String OTP_PATH = "/api/users/otp/**";

    public static final String COMMUNICATION_CHANNEL_PATH = "/api/channels/**";
}

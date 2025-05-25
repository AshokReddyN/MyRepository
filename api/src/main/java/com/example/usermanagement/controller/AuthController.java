package com.example.usermanagement.controller;

import com.example.usermanagement.dto.LoginResponseDto;
import com.example.usermanagement.dto.OtpRequestDto;
import com.example.usermanagement.dto.OtpVerificationRequestDto;
import com.example.usermanagement.dto.UserDto;
import com.example.usermanagement.service.OtpService;
import com.example.usermanagement.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.validation.Valid;

@RestController
@RequestMapping("/api/auth")
@Tag(name = "Authentication", description = "APIs for user registration and login")
public class AuthController {

    private static final Logger logger = LoggerFactory.getLogger(AuthController.class);

    private final OtpService otpService;
    private final UserService userService;

    public AuthController(OtpService otpService, UserService userService) {
        this.otpService = otpService;
        this.userService = userService;
    }

    @PostMapping("/register/send-otp")
    @Operation(summary = "Send OTP for registration",
               responses = {
                   @ApiResponse(responseCode = "200", description = "OTP sent successfully"),
                   @ApiResponse(responseCode = "400", description = "Invalid mobile number or rate limit exceeded")
               })
    public ResponseEntity<String> sendRegistrationOtp(@Valid @RequestBody OtpRequestDto otpRequestDto) {
        logger.info("Received request to send registration OTP for mobile: {}", otpRequestDto.getMobileNumber());
        String response = otpService.generateAndSendOtp(otpRequestDto.getMobileNumber());
        return ResponseEntity.ok(response);
    }

    @PostMapping("/register/verify-otp")
    @Operation(summary = "Verify OTP and register user",
               responses = {
                   @ApiResponse(responseCode = "201", description = "User registered successfully",
                                content = @Content(schema = @Schema(implementation = UserDto.class))),
                   @ApiResponse(responseCode = "400", description = "Invalid OTP or mobile number"),
                   @ApiResponse(responseCode = "409", description = "User already exists")
               })
    public ResponseEntity<UserDto> verifyRegistrationOtpAndRegister(@Valid @RequestBody OtpVerificationRequestDto verificationRequest) {
        logger.info("Received request to verify registration OTP for mobile: {}", verificationRequest.getMobileNumber());
        UserDto registeredUser = userService.registerUser(verificationRequest.getMobileNumber(), verificationRequest.getOtp());
        return ResponseEntity.status(HttpStatus.CREATED).body(registeredUser);
    }

    @PostMapping("/login/send-otp")
    @Operation(summary = "Send OTP for login",
               responses = {
                   @ApiResponse(responseCode = "200", description = "OTP sent successfully"),
                   @ApiResponse(responseCode = "400", description = "Invalid mobile number or rate limit exceeded")
               })
    public ResponseEntity<String> sendLoginOtp(@Valid @RequestBody OtpRequestDto otpRequestDto) {
        logger.info("Received request to send login OTP for mobile: {}", otpRequestDto.getMobileNumber());
        // Logic is similar to registration OTP send for now.
        // Could be different if login OTPs have different rate limits or checks.
        String response = otpService.generateAndSendOtp(otpRequestDto.getMobileNumber());
        return ResponseEntity.ok(response);
    }

    @PostMapping("/login/verify-otp")
    @Operation(summary = "Verify OTP and login user",
               responses = {
                   @ApiResponse(responseCode = "200", description = "Login successful, JWT token returned",
                                content = @Content(schema = @Schema(implementation = LoginResponseDto.class))),
                   @ApiResponse(responseCode = "400", description = "Invalid OTP or mobile number"),
                   @ApiResponse(responseCode = "401", description = "Authentication failed")
               })
    public ResponseEntity<LoginResponseDto> verifyLoginOtpAndLogin(@Valid @RequestBody OtpVerificationRequestDto verificationRequest) {
        logger.info("Received request to verify login OTP for mobile: {}", verificationRequest.getMobileNumber());
        LoginResponseDto loginResponse = userService.loginUser(verificationRequest.getMobileNumber(), verificationRequest.getOtp());
        return ResponseEntity.ok(loginResponse);
    }

    @PostMapping("/resend-otp")
    @Operation(summary = "Resend OTP",
               responses = {
                   @ApiResponse(responseCode = "200", description = "OTP resent successfully"),
                   @ApiResponse(responseCode = "400", description = "Invalid mobile number or rate limit exceeded")
               })
    public ResponseEntity<String> resendOtp(@Valid @RequestBody OtpRequestDto otpRequestDto) {
        logger.info("Received request to resend OTP for mobile: {}", otpRequestDto.getMobileNumber());
        String response = otpService.resendOtp(otpRequestDto.getMobileNumber());
        return ResponseEntity.ok(response);
    }
}

package com.example.usermanagement.service;

import com.example.usermanagement.dto.LoginResponseDto;
import com.example.usermanagement.dto.UserDto;
import com.example.usermanagement.exception.UserAlreadyExistsException;
import com.example.usermanagement.exception.UserNotFoundException;
import com.example.usermanagement.model.User;
import com.example.usermanagement.repository.UserRepository;
import com.example.usermanagement.security.JwtUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Collections; // For default roles

@Service
public class UserService {

    private static final Logger logger = LoggerFactory.getLogger(UserService.class);

    private final UserRepository userRepository;
    private final OtpService otpService;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    public UserService(UserRepository userRepository,
                       OtpService otpService,
                       PasswordEncoder passwordEncoder,
                       JwtUtil jwtUtil) {
        this.userRepository = userRepository;
        this.otpService = otpService;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtil = jwtUtil;
    }

    public UserDto registerUser(String mobileNumber, String otp) {
        if (userRepository.existsByMobileNumber(mobileNumber)) {
            logger.warn("User registration failed: Mobile number {} already exists", mobileNumber);
            throw new UserAlreadyExistsException("User already registered with mobile number: " + mobileNumber);
        }

        // Verify OTP
        boolean isOtpValid = otpService.verifyOtp(mobileNumber, otp);
        if (!isOtpValid) {
            // OtpService throws specific exceptions, so this might not be strictly needed here
            // but as a safeguard or for different error handling:
            logger.warn("User registration failed: Invalid OTP for mobile number {}", mobileNumber);
            // OtpInvalidException or OtpExpiredException would have been thrown by otpService.verifyOtp
            // If we reach here, it means verifyOtp returned false without an exception, which is not its current design.
            // However, to be defensive:
            throw new com.example.usermanagement.exception.OtpInvalidException("OTP verification failed for registration.");
        }

        // Create new user
        // For OTP-based systems, the "password" field might not be a traditional password.
        // Here, we're storing the hashed OTP as the initial "password".
        // This could be cleared or handled differently post-registration if needed.
        // A more robust approach for a system that might later support passwords would be
        // to leave the password field null/empty or generate a random secure password
        // if the user is only supposed to log in via OTP.
        String encodedPassword = passwordEncoder.encode(otp); // Or consider a different strategy

        User newUser = new User(mobileNumber, encodedPassword, Collections.singletonList("ROLE_USER"));
        User savedUser = userRepository.save(newUser);

        logger.info("User registered successfully: {}", savedUser.getMobileNumber());
        return convertToDto(savedUser);
    }

    public LoginResponseDto loginUser(String mobileNumber, String otp) {
        // Verify OTP
        boolean isOtpValid = otpService.verifyOtp(mobileNumber, otp); // This will throw if OTP is invalid/expired

        // If OTP is valid, the user is considered "authenticated" for this session.
        // Now, find the user to generate a token.
        User user = userRepository.findByMobileNumber(mobileNumber)
                .orElseThrow(() -> {
                    logger.warn("Login failed: User not found with mobile number {} after OTP verification", mobileNumber);
                    // This case should ideally not happen if registration is mandatory before login.
                    // If it can happen (e.g. OTP sent to non-registered user for login),
                    // then registration flow should be triggered or a specific error.
                    return new UserNotFoundException("User not found with mobile number: " + mobileNumber + ". Please register first.");
                });

        // Generate JWT token
        String token = jwtUtil.generateToken(user.getMobileNumber(), user.getRoles());
        logger.info("User logged in successfully: {}. Token generated.", user.getMobileNumber());
        return new LoginResponseDto(token, "Login successful");
    }

    public UserDto findUserByMobileNumber(String mobileNumber) {
        User user = userRepository.findByMobileNumber(mobileNumber)
                .orElseThrow(() -> new UserNotFoundException("User not found with mobile number: " + mobileNumber));
        return convertToDto(user);
    }


    private UserDto convertToDto(User user) {
        return new UserDto(user.getId(), user.getMobileNumber(), user.getRoles(), user.getCreatedAt());
    }
}

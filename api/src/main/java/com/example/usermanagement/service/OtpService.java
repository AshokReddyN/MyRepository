package com.example.usermanagement.service;

import com.example.usermanagement.exception.OtpExpiredException;
import com.example.usermanagement.exception.OtpInvalidException;
import com.example.usermanagement.exception.RateLimitException;
import com.example.usermanagement.model.Otp;
import com.example.usermanagement.repository.OtpRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.Optional;

@Service
public class OtpService {

    private static final Logger logger = LoggerFactory.getLogger(OtpService.class);

    private final OtpRepository otpRepository;
    private final PasswordEncoder passwordEncoder;

    @Value("${fast2sms.api.key}")
    private String fast2SmsApiKey;

    @Value("${fast2sms.api.url}")
    private String fast2SmsApiUrl;

    private static final int OTP_LENGTH = 6;
    private static final int OTP_EXPIRATION_MINUTES = 5;
    private static final int MAX_RESEND_ATTEMPTS = 3;
    private static final int RESEND_RATE_LIMIT_MINUTES = 10;
    private static final int MAX_OTP_REQUESTS_HOURLY = 10; // Max 10 OTP requests per hour per number

    public OtpService(OtpRepository otpRepository, PasswordEncoder passwordEncoder) {
        this.otpRepository = otpRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public String generateAndSendOtp(String mobileNumber) {
        // Check rate limit for generating OTP
        long otpRequestsInLastHour = otpRepository.countByMobileNumberAndCreatedAtAfter(
                mobileNumber, LocalDateTime.now().minusHours(1));
        if (otpRequestsInLastHour >= MAX_OTP_REQUESTS_HOURLY) {
            logger.warn("Rate limit exceeded for OTP generation for mobile: {}", mobileNumber);
            throw new RateLimitException("Too many OTP requests. Please try again later.");
        }

        // Invalidate any existing OTP for this number
        otpRepository.deleteByMobileNumber(mobileNumber);

        String otpCode = generateRandomOtp();
        String hashedOtp = passwordEncoder.encode(otpCode);
        LocalDateTime expiresAt = LocalDateTime.now().plusMinutes(OTP_EXPIRATION_MINUTES);

        Otp otpDocument = new Otp(mobileNumber, hashedOtp, expiresAt);
        otpRepository.save(otpDocument);

        // Simulate sending OTP via Fast2SMS
        sendOtpViaSms(mobileNumber, otpCode);

        logger.info("Generated and sent OTP for mobile number: {}. OTP: {} (Hashed: {})", mobileNumber, otpCode, hashedOtp);
        return "OTP sent successfully to " + mobileNumber;
    }

    public boolean verifyOtp(String mobileNumber, String otp) {
        Optional<Otp> otpOptional = otpRepository.findByMobileNumber(mobileNumber);

        if (otpOptional.isEmpty()) {
            logger.warn("No OTP found for mobile number: {}", mobileNumber);
            throw new OtpInvalidException("OTP not found or already used. Please request a new OTP.");
        }

        Otp otpDocument = otpOptional.get();

        if (otpDocument.isExpired()) {
            otpRepository.delete(otpDocument); // Clean up expired OTP
            logger.warn("OTP expired for mobile number: {}", mobileNumber);
            throw new OtpExpiredException("OTP has expired. Please request a new OTP.");
        }

        if (passwordEncoder.matches(otp, otpDocument.getOtpCode())) {
            otpRepository.delete(otpDocument); // Delete OTP after successful verification
            logger.info("OTP verified successfully for mobile number: {}", mobileNumber);
            return true;
        } else {
            // Handle failed attempts if needed (e.g., lock account after too many failures)
            logger.warn("Invalid OTP for mobile number: {}", mobileNumber);
            throw new OtpInvalidException("Invalid OTP. Please try again.");
        }
    }

    public String resendOtp(String mobileNumber) {
        Optional<Otp> existingOtpOptional = otpRepository.findByMobileNumber(mobileNumber);

        if (existingOtpOptional.isEmpty()) {
            logger.info("No previous OTP found for {}. Generating a new one.", mobileNumber);
            return generateAndSendOtp(mobileNumber);
        }

        Otp existingOtp = existingOtpOptional.get();

        // Check if resend is allowed (within rate limit and max attempts)
        if (existingOtp.getResendCount() >= MAX_RESEND_ATTEMPTS) {
            logger.warn("Max resend attempts reached for mobile: {}", mobileNumber);
            throw new RateLimitException("Maximum OTP resend attempts reached. Please try again later.");
        }

        if (existingOtp.getLastResendTime() != null &&
            LocalDateTime.now().isBefore(existingOtp.getLastResendTime().plusMinutes(RESEND_RATE_LIMIT_MINUTES)) &&
            existingOtp.getResendCount() > 0) { // Allow first resend immediately if needed
            logger.warn("Resend OTP rate limit for mobile: {}. Last resend: {}, Count: {}",
                         mobileNumber, existingOtp.getLastResendTime(), existingOtp.getResendCount());
            long minutesToWait = RESEND_RATE_LIMIT_MINUTES - java.time.Duration.between(existingOtp.getLastResendTime(), LocalDateTime.now()).toMinutes();
            throw new RateLimitException("Please wait " + minutesToWait + " minutes before resending OTP.");
        }
        
        // Invalidate the current OTP before generating a new one
        otpRepository.delete(existingOtp);

        // Generate and send a new OTP
        String newOtpCode = generateRandomOtp();
        String hashedNewOtp = passwordEncoder.encode(newOtpCode);
        LocalDateTime newExpiresAt = LocalDateTime.now().plusMinutes(OTP_EXPIRATION_MINUTES);

        Otp newOtpDocument = new Otp(mobileNumber, hashedNewOtp, newExpiresAt);
        newOtpDocument.setResendCount(existingOtp.getResendCount() + 1); // Increment resend count
        otpRepository.save(newOtpDocument);

        sendOtpViaSms(mobileNumber, newOtpCode);
        logger.info("Resent OTP for mobile number: {}. OTP: {} (Hashed: {}). Resend count: {}",
                mobileNumber, newOtpCode, hashedNewOtp, newOtpDocument.getResendCount());
        return "OTP resent successfully to " + mobileNumber;
    }


    private String generateRandomOtp() {
        SecureRandom random = new SecureRandom();
        StringBuilder otp = new StringBuilder(OTP_LENGTH);
        for (int i = 0; i < OTP_LENGTH; i++) {
            otp.append(random.nextInt(10));
        }
        return otp.toString();
    }

    private void sendOtpViaSms(String mobileNumber, String otpCode) {
        // TODO: Implement actual Fast2SMS API call here
        // Example:
        // RestTemplate restTemplate = new RestTemplate();
        // HttpHeaders headers = new HttpHeaders();
        // headers.set("authorization", fast2SmsApiKey);
        // headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);
        //
        // MultiValueMap<String, String> map = new LinkedMultiValueMap<>();
        // map.add("variables_values", otpCode);
        // map.add("route", "otp");
        // map.add("numbers", mobileNumber);
        //
        // HttpEntity<MultiValueMap<String, String>> request = new HttpEntity<>(map, headers);
        //
        // try {
        //     ResponseEntity<String> response = restTemplate.postForEntity(fast2SmsApiUrl, request, String.class);
        //     logger.info("Fast2SMS response: {}", response.getBody());
        //     if (response.getStatusCode() == HttpStatus.OK) {
        //         // Handle success
        //     } else {
        //         // Handle error
        //         logger.error("Error sending OTP via Fast2SMS. Status: {}, Response: {}", response.getStatusCode(), response.getBody());
        //     }
        // } catch (RestClientException e) {
        //     logger.error("Error calling Fast2SMS API", e);
        // }
        logger.info("SIMULATING SMS: Sending OTP {} to mobile number {} via Fast2SMS (API Key: {}, URL: {})",
                otpCode, mobileNumber, fast2SmsApiKey, fast2SmsApiUrl);
    }
}

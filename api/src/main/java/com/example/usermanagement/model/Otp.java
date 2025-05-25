package com.example.usermanagement.model;

import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@Document(collection = "otps")
public class Otp {

    @Id
    private String id;

    @Indexed
    private String mobileNumber;

    private String otpCode; // Hashed OTP

    private LocalDateTime expiresAt;

    @CreatedDate
    private LocalDateTime createdAt;

    private int resendCount = 0;
    private LocalDateTime lastResendTime;


    public Otp(String mobileNumber, String otpCode, LocalDateTime expiresAt) {
        this.mobileNumber = mobileNumber;
        this.otpCode = otpCode;
        this.expiresAt = expiresAt;
        this.createdAt = LocalDateTime.now();
        this.lastResendTime = LocalDateTime.now();
    }

    public boolean isExpired() {
        return LocalDateTime.now().isAfter(expiresAt);
    }

    public void incrementResendCount() {
        this.resendCount++;
        this.lastResendTime = LocalDateTime.now();
    }
}

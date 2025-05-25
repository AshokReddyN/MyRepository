package com.example.usermanagement.repository;

import com.example.usermanagement.model.Otp;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.Optional;

@Repository
public interface OtpRepository extends MongoRepository<Otp, String> {
    Optional<Otp> findByMobileNumberAndOtpCode(String mobileNumber, String otpCode);
    Optional<Otp> findByMobileNumber(String mobileNumber);
    void deleteByMobileNumber(String mobileNumber);
    long countByMobileNumberAndCreatedAtAfter(String mobileNumber, LocalDateTime timestamp);
}

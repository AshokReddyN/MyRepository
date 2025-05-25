package com.example.usermanagement.model;

import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;
import java.util.List;

@Data
@NoArgsConstructor
@Document(collection = "users")
public class User {

    @Id
    private String id;

    @Indexed(unique = true)
    private String mobileNumber;

    private String password; // Will store hashed OTP during registration, can be cleared/updated later

    private List<String> roles;

    @CreatedDate
    private LocalDateTime createdAt;

    public User(String mobileNumber, String password, List<String> roles) {
        this.mobileNumber = mobileNumber;
        this.password = password;
        this.roles = roles;
        this.createdAt = LocalDateTime.now();
    }
}

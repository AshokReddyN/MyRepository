package com.example.usermanagement.security;

import com.example.usermanagement.model.User;
import com.example.usermanagement.repository.UserRepository;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class UserDetailsServiceImpl implements UserDetailsService {

    private final UserRepository userRepository;

    public UserDetailsServiceImpl(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Override
    public UserDetails loadUserByUsername(String mobileNumber) throws UsernameNotFoundException {
        User user = userRepository.findByMobileNumber(mobileNumber)
                .orElseThrow(() -> new UsernameNotFoundException("User not found with mobile number: " + mobileNumber));

        List<GrantedAuthority> authorities = user.getRoles()
                .stream()
                .map(SimpleGrantedAuthority::new)
                .collect(Collectors.toList());

        // Spring Security's User expects a username, password, and authorities.
        // For OTP-based auth, the password stored in User entity might be the hashed OTP or null.
        // If using JWT, the password check is bypassed after initial OTP verification.
        // Here, we pass user.getPassword(), but it might not be used for direct password comparison
        // if JWT is the primary auth mechanism post-login.
        return new org.springframework.security.core.userdetails.User(
                user.getMobileNumber(),
                user.getPassword(), // This might be null or a placeholder if not using traditional passwords
                authorities
        );
    }
}

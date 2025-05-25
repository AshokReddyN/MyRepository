package com.example.usermanagement.controller;

import com.example.usermanagement.dto.UserDto;
import com.example.usermanagement.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/users")
@Tag(name = "User", description = "APIs for user specific operations (requires authentication)")
@SecurityRequirement(name = "bearerAuth") // Indicates that endpoints here require Bearer token
public class UserController {

    private static final Logger logger = LoggerFactory.getLogger(UserController.class);

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/me")
    @PreAuthorize("hasRole('ROLE_USER') or hasRole('ROLE_ADMIN')") // Example authorization
    @Operation(summary = "Get current user details",
               description = "Fetches details of the currently authenticated user.",
               responses = {
                   @ApiResponse(responseCode = "200", description = "Successfully retrieved user details"),
                   @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token is missing or invalid"),
                   @ApiResponse(responseCode = "404", description = "User not found")
               })
    public ResponseEntity<UserDto> getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String mobileNumber = authentication.getName(); // This is the mobile number from UserDetails

        logger.info("Fetching details for current user: {}", mobileNumber);
        UserDto userDto = userService.findUserByMobileNumber(mobileNumber);
        return ResponseEntity.ok(userDto);
    }
}

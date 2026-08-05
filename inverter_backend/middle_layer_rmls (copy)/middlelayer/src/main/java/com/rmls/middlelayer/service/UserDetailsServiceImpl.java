package com.rmls.middlelayer.service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.rmls.middlelayer.configuration.JwtUtils;
import com.rmls.middlelayer.model.ERole;
import com.rmls.middlelayer.model.JwtResponse;
import com.rmls.middlelayer.model.Role;
import com.rmls.middlelayer.model.User;
import com.rmls.middlelayer.model.UserProfileEditModel;
import com.rmls.middlelayer.repository.RoleRepository;
import com.rmls.middlelayer.repository.UserRepository;

@Service
public class UserDetailsServiceImpl implements UserDetailsService {

  private static final Logger logger = LoggerFactory.getLogger(UserDetailsServiceImpl.class);

  private final PasswordEncoder passwordEncoder;

  @Autowired
  UserRepository userRepository;

  @Autowired
  RoleRepository roleRepository;

  @Autowired
  JwtUtils jwtUtils;

  // ------------------------------------
  // For Validating The User Exists
  public Boolean userDetailValidate(String email) {

    Optional<User> user = null;

    if (email != null) {
      user = userRepository.findByEmail(email);

      if (user.isPresent() && email != null) {

        return true; // For Valid User

      } else {
        return false; // For Not Valid User
      }
    } else {
      return false;
    }
  }

  // ---------------------------------------------------------
  // ----------------- LOGIN FOR USER

  public JwtResponse operatorDetailsValidate(String email, String password) {

    // JwtResponse jwtResponse =
    User userRecord = new User();
    Optional<User> user = null;
    String authToken = null;

    if (email != null) {
      user = userRepository.findByEmail(email);
    } else {
      userRecord.setId(-1L); // No User Found
    }

    if (user.isPresent()) {

      userRecord = user.get();

      List<ERole> roleNames = userRecord.getRoles().stream()
          .map(Role::getName)
          .collect(Collectors.toList());

      Boolean passwordMatch = false;

      if (userRecord.getPassword() != null) {
        passwordMatch = isTruePassword(userRecord.getId(), password);

        if (passwordMatch) {

          authToken = jwtUtils.generateJwtToken(userRecord.getEmail());

          return new JwtResponse(authToken, userRecord.getId(), userRecord.getUsername(), userRecord.getEmail(),
              roleNames);

        } else {
          // Bad Credientail
          return new JwtResponse(authToken, -2L, userRecord.getUsername(), userRecord.getEmail(), null);
        }
      }
    }

    return new JwtResponse(authToken, -1L, userRecord.getUsername(), userRecord.getEmail(), null);

  }

  // ---------------------------------
  // -- Validate OTP
  public Boolean validate_user_otp(User user, String emailOtp) {

    if (user.getEmail() != null && user.getEmailOtp().equals(emailOtp)) {
      return true;
    } else {
      return false;
    }
  }

  @Autowired
  public UserDetailsServiceImpl(PasswordEncoder passwordEncoder) {
    this.passwordEncoder = passwordEncoder;
  }

  @Override
  @Transactional
  public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {

    logger.info("UserDetailsServiceImpl-loadUserByUsername-Called");
    User user = userRepository.findByUsername(username)
        .orElseThrow(() -> new UsernameNotFoundException("User Not Found with username: " + username));

    return UserDetailsImpl.build(user);
  }

  public LocalDateTime getDeletedAt(String email) {
    return userRepository.findByEmail(email)
        .map(User::getDeletedAt)
        .orElse(null);
  }

  public User markUserAsDeleted(Integer userId, Boolean activeUser) {

    LocalDateTime dateTimeNow = LocalDateTime.now();
    Optional<User> userOptional = userRepository.findById((long) userId);

    User userRecord = new User();

    if (userOptional.isPresent()) {

      userRecord = userOptional.get();
      if (activeUser) {
        userRecord.setDeletedAt(null);
      } else {
        userRecord.setDeletedAt(dateTimeNow);
      }
    }
    return userRepository.save(userRecord);
  }

  public boolean isTruePassword(Long userId, String userPassword) {

    Optional<User> user = userRepository.findById(userId);
    User userModel = new User();

    if (user.isPresent()) {
      userModel = user.get();
      boolean check = passwordEncoder.matches(userPassword, userModel.getPassword());
      return check;
    } else {
      return false;
    }

  }

  // ----------------------------------------
  // If ForgotPassword is True than it will not check for old password
  public int changeUserPassword(User user, String newPassword, Boolean forgotPassword) {

    Long userId = user.getId();
    String userPassword = user.getPassword();
    boolean checkPassword = false;

    if (!forgotPassword) {
      checkPassword = isTruePassword(userId, userPassword);
    } else {
      userRepository.changeUserPassword(passwordEncoder.encode(newPassword), user.getId());
      return 1;
    }

    if (checkPassword) {
      userRepository.changeUserPassword(passwordEncoder.encode(newPassword), user.getId());
      return 1;
    } else {
      return 0;
    }
  }

  // Edit User Profile
  public User editUserProfile(UserProfileEditModel editUserDetails) {

    Optional<User> userRecord = userRepository.findById(editUserDetails.getId());
    User userModel = new User();
    LocalDateTime dateTimeNow = LocalDateTime.now();

    if (userRecord.isPresent()) {
      userModel = userRecord.get();

      if (editUserDetails.getUsername() != null && editUserDetails.getUsername() != "") {
        userModel.setUsername(editUserDetails.getUsername());
      }
      if (editUserDetails.getLastName() != null && editUserDetails.getLastName() != "") {
        userModel.setLastName(editUserDetails.getLastName());
      }
      if (editUserDetails.getAddress() != null && editUserDetails.getAddress() != "") {
        userModel.setAddress(editUserDetails.getAddress());
      }
      if (editUserDetails.getCity() != null && editUserDetails.getCity() != "") {
        userModel.setCity(editUserDetails.getCity());
      }
      if (editUserDetails.getCountry() != null && editUserDetails.getCountry() != "") {
        userModel.setCountry(editUserDetails.getCountry());
      }
      if (editUserDetails.getPostalCode() != null && editUserDetails.getPostalCode() != "") {
        userModel.setPostalCode(editUserDetails.getPostalCode());
      }
      if (editUserDetails.getEmail() != null && editUserDetails.getEmail() != "") {
        userModel.setEmail(editUserDetails.getEmail());
      }
      if (editUserDetails.getPassword() != null && editUserDetails.getPassword() != "") {
        userModel.setPassword(passwordEncoder.encode(editUserDetails.getPassword()));
      }
      if (editUserDetails.getPhone() != null && editUserDetails.getPhone() != "") {
        userModel.setPhone(Long.valueOf(editUserDetails.getPhone()));
      }

      userModel.setUpdatedAt(dateTimeNow);
      userModel = userRepository.save(userModel);

      return userModel;

    } else {
      return new User();
    }

  }

  // ----------------------------------------
  // If ForgotPassword On Login Screen
  public int forgotUserPassword(User user, String newPassword) {

    try {
      userRepository.changeUserPassword(passwordEncoder.encode(newPassword), user.getId());
      return 1;
    } catch (Exception e) {
      e.printStackTrace();
      return 0;
    }
  }

}
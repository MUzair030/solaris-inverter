package com.rmls.middlelayer.controller;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.concurrent.CompletableFuture;
import java.util.stream.Collectors;

import jakarta.validation.Valid;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

import com.rmls.middlelayer.configuration.JwtUtils;
import com.rmls.middlelayer.model.ERole;
import com.rmls.middlelayer.model.EmailDetails;
import com.rmls.middlelayer.model.ForgotPassword;
import com.rmls.middlelayer.model.JwtResponse;
import com.rmls.middlelayer.model.LoginRequest;
import com.rmls.middlelayer.model.MessageResponse;
import com.rmls.middlelayer.model.RequestChangePassword;
import com.rmls.middlelayer.model.Role;
import com.rmls.middlelayer.model.SignupRequest;
import com.rmls.middlelayer.model.TempUser_Model;
import com.rmls.middlelayer.model.User;
import com.rmls.middlelayer.model.UserProfileEditModel;
import com.rmls.middlelayer.model.User_Devices_Model;
import com.rmls.middlelayer.repository.RoleRepository;
import com.rmls.middlelayer.repository.TempUser_Repository;
import com.rmls.middlelayer.repository.UserRepository;
import com.rmls.middlelayer.repository.User_Devices_Repository;
import com.rmls.middlelayer.service.Email_ServiceImpl;
import com.rmls.middlelayer.service.TempUser_Service_Scheduler;
import com.rmls.middlelayer.service.UserDetailsServiceImpl;
import com.rmls.middlelayer.service.User_Device_Service;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/auth")
public class AuthController {

  private static final Logger logger = LoggerFactory.getLogger(AuthController.class);

  @Autowired
  AuthenticationManager authenticationManager;

  @Autowired
  UserRepository userRepository;

  @Autowired
  RoleRepository roleRepository;

  @Autowired
  PasswordEncoder encoder;

  @Autowired
  UserDetailsServiceImpl userDetailsServiceImpl;

  @Autowired
  JwtUtils jwtUtils;

  @Autowired
  User_Device_Service user_devices_service;

  @Autowired
  User_Devices_Repository user_Devices_Repository;

  @Autowired
  RestTemplate restTemplate;

  @Value("${base.url.email}")
  String urlEmailService;

  @Value("${base.url.verification.email}")
  String urlVerificationOTP;

  @Autowired
  Email_ServiceImpl email_ServiceImpl;

  @Autowired
  TempUser_Service_Scheduler tempUser_Service_Scheduler;

  @Autowired
  TempUser_Repository tempUser_Repository;

  // -------------------------------------------------
  // -- This API will Send OTP for Verification to the User
  // and will store that OTP in temperory table
  // -------------------------------
  @GetMapping(path = "/send-email-otp", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<?> sendEmailOtp(@RequestParam(required = true, defaultValue = "") String email) {
    logger.info("AuthController - Sending EmailOTP Controller");
    try {

      if (email != null) {
        String otp = email_ServiceImpl.generateOTP();
        EmailDetails emailDetails = new EmailDetails();

        emailDetails.setSubject("3POL Email Verification OTP CODE");
        emailDetails.setMsgBody("Your Email Verification OTP is " + otp);
        emailDetails.setRecipient(email);

        // -------------------------------------
        // ---- Save that OTP Against Temperory User
        Boolean status = tempUser_Service_Scheduler.saveTempUserOtp(email, otp);

        if (status) {
          logger.info("OTP Saved for Verification {}", email);
        } else {
          return new ResponseEntity<>("Something went wrong!", HttpStatus.OK);
        }

        // Sending email asynchronously
        CompletableFuture<ResponseEntity<String>> emailFuture = CompletableFuture.supplyAsync(() -> {
          try {
            ResponseEntity<String> response = restTemplate.postForEntity(urlVerificationOTP, emailDetails,
                String.class);
            logger.info("Email Send To " + emailDetails.getRecipient() + "\n" + response.getBody());
            return response;
          } catch (Exception e) {
            e.printStackTrace();
            return new ResponseEntity<>("Failed to send email", HttpStatus.INTERNAL_SERVER_ERROR);
          }
        });

        ResponseEntity<String> emailResponse = emailFuture.get();

        return new ResponseEntity<>(
            "Email Send To For Verification " + emailDetails.getRecipient() + " " + emailResponse.getBody(),
            HttpStatus.OK);

      } else {
        return new ResponseEntity<>("Something went wrong!", HttpStatus.OK);
      }

    } catch (Exception e) {
      logger.error("Exception in AuthController - Send Email Verification OTP Exception", e);
      e.printStackTrace(); // Log the exception for debugging purposes
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  // ---------------------------------------------------
  // -- This API will validate the OTP which is stores in
  // temporary table
  // ----------------------------------------------------
  @GetMapping(path = "/validate-email-otp", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<?> validateEmailVerificationOtp(
      @RequestParam(required = true, defaultValue = "") String emailOtp,
      @RequestParam(required = true, defaultValue = "") String email) {
    logger.info("AuthController - ValidateEmailVerificationOtp");
    try {
      Boolean validate_otp = false;

      if (emailOtp.isEmpty()) {
        return new ResponseEntity<>("Please Enter Valid OTP", HttpStatus.OK);
      }

      Optional<TempUser_Model> user = tempUser_Service_Scheduler.findByEmailAddress(email);

      if (user.isPresent()) {
        validate_otp = tempUser_Service_Scheduler.validate_user_otp(user.get(), emailOtp);

        TempUser_Model temp = user.get();
        temp.setVerified_otp(validate_otp);
        tempUser_Repository.save(temp);

      } else {
        return new ResponseEntity<>("Please Try Again!", HttpStatus.OK);
      }

      return new ResponseEntity<>(validate_otp, HttpStatus.OK);
    } catch (Exception e) {
      logger.error("Exception in AuthController - Validate Email OTP Verification Exception", e);
      e.printStackTrace(); // Log the exception for debugging purposes
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  // -----------------------------------------------------
  // -- This is working for Forgot Password to send OTP
  // -----------------------------------------------------
  @GetMapping(path = "/send-otp", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<?> sendOtp(@RequestParam(required = true, defaultValue = "") String email) {
    logger.info("AuthController - Sending OTP Controller");
    try {

      if (email != null) {
        String otp = email_ServiceImpl.generateOTP();
        EmailDetails emailDetails = new EmailDetails();

        emailDetails.setSubject("3POL OTP CODE");
        emailDetails.setMsgBody("Your Forgot Password OTP is " + otp);
        emailDetails.setRecipient(email);

        // -------------------------------------
        // ---- Save that OTP Against User
        Optional<User> user = userRepository.findByEmail(email);

        if (user.isPresent()) {
          User userBean = new User();
          userBean = user.get();
          userBean.setEmailOtp(otp);
          userRepository.save(userBean);
        } else {
          return new ResponseEntity<>("User Not Found!", HttpStatus.OK);
        }

        // Sending email asynchronously
        CompletableFuture<ResponseEntity<String>> emailFuture = CompletableFuture.supplyAsync(() -> {
          try {
            ResponseEntity<String> response = restTemplate.postForEntity(urlEmailService, emailDetails, String.class);
            logger.info("Email Send To " + emailDetails.getRecipient() + "\n" + response.getBody());
            return response;
          } catch (Exception e) {
            e.printStackTrace();
            return new ResponseEntity<>("Failed to send email", HttpStatus.INTERNAL_SERVER_ERROR);
          }
        });

        ResponseEntity<String> emailResponse = emailFuture.get();

        return new ResponseEntity<>("Email Send To " + emailDetails.getRecipient() + " " + emailResponse.getBody(),
            HttpStatus.OK);

      } else {
        return new ResponseEntity<>("User Not Found!", HttpStatus.OK);
      }

    } catch (Exception e) {
      logger.error("Exception in AuthController - Send OTP Exception", e);
      e.printStackTrace(); // Log the exception for debugging purposes
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  @GetMapping(path = "/validate-otp", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<?> checkOtp(@RequestParam(required = true, defaultValue = "") String emailOtp,
      @RequestParam(required = true, defaultValue = "") String email) {
    logger.info("AuthController - Validate OTP");
    try {
      Boolean validate_otp = false;

      if (emailOtp.isEmpty()) {
        return new ResponseEntity<>("Please Enter Valid OTP", HttpStatus.OK);
      }

      Optional<User> user = userRepository.findByEmail(email);
      if (user.isPresent()) {
        User userBean = new User();
        userBean = user.get();
        validate_otp = userDetailsServiceImpl.validate_user_otp(userBean, emailOtp);
      } else {
        return new ResponseEntity<>("User Not Found!", HttpStatus.OK);
      }

      return new ResponseEntity<>(validate_otp, HttpStatus.OK);
    } catch (Exception e) {
      logger.error("Exception in AuthController - Validate OTP Exception", e);
      e.printStackTrace(); // Log the exception for debugging purposes
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  @PostMapping("/signin")
  public ResponseEntity<?> authenticateUser(@Valid @RequestBody LoginRequest loginRequest) {
    logger.info("AuthController_signin_Called");

    try {

      // Check
      LocalDateTime deletedAtValue = userDetailsServiceImpl.getDeletedAt(loginRequest.getEmail());
      if (deletedAtValue != null) {
        return new ResponseEntity<>("User account is deleted or deactivated.", HttpStatus.UNAUTHORIZED);
      }

      JwtResponse jwtResponse = userDetailsServiceImpl.operatorDetailsValidate(loginRequest.getEmail(),
          loginRequest.getPassword());

      if (jwtResponse.getToken() != null && jwtResponse.getId() > 0) {
        return new ResponseEntity<>(jwtResponse, HttpStatus.OK);
      } else if (jwtResponse.getId() == -1) {
        return new ResponseEntity<>("User Not Found! Please Register", HttpStatus.OK);
      } else if (jwtResponse.getId() == -2) {
        return new ResponseEntity<>("Incorrect Password", HttpStatus.OK);
      }
      return new ResponseEntity<>("Something went wrong! Try Again", HttpStatus.OK);

    } catch (Exception e) {
      logger.error("Exception in AuthController_signin", e);
      logger.error(e.getMessage());
      if (e.getMessage().equalsIgnoreCase("Bad credentials")) {
        return new ResponseEntity<>("Bad credentials", HttpStatus.UNAUTHORIZED);
      } else {
        return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      }
    }
  }

  @PostMapping("/signup")
  public ResponseEntity<?> registerUser(@Valid @RequestBody SignupRequest signUpRequest) {
    logger.info("AuthController_signup_Called");

    try {
      LocalDateTime localDateTime = LocalDateTime.now();

      // if (userRepository.existsByUsername(signUpRequest.getUsername())) {
      // return ResponseEntity
      // .badRequest()
      // .body(new MessageResponse("Error: Username is already taken!"));
      // }

      if (userRepository.existsByEmail(signUpRequest.getEmail())) {
        return ResponseEntity
            .badRequest()
            .body(new MessageResponse("Error: Email is already in use!"));
      }

      // Create new user's account
      User user = new User(signUpRequest.getUsername(),
          signUpRequest.getEmail(),
          encoder.encode(signUpRequest.getPassword()),
          signUpRequest.getLastName(),
          signUpRequest.getAddress(),
          signUpRequest.getPostalCode(),
          signUpRequest.getCity(),
          signUpRequest.getCountry(),
          signUpRequest.getPhone());

      user.setCreatedAt(localDateTime);

      Set<Role> roles = new HashSet<>();

      Role userRole = roleRepository.findByName(ERole.ROLE_USER)
          .orElseThrow(() -> new RuntimeException("Error: Role is not found."));

      roles.add(userRole);

      user.setRoles(roles);

      userRepository.save(user);

      return ResponseEntity.ok(new MessageResponse("User registered successfully!"));

    } catch (Exception e) {
      logger.error("Exception in AuthController_signup", e);
      e.printStackTrace();
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  @GetMapping(path = "/getAllUser", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<User>> getAllUsers(@RequestHeader("Authorization") String authorizationHeader) {
    logger.info("AuthController_getAllUser_Called");

    try {
      List<User> ls = new ArrayList<>();
      List<User> filteredList = new ArrayList<>();

      User userDetails = jwtUtils.getUserDetailsFromJwtToken(authorizationHeader);

      List<ERole> roleNames = userDetails.getRoles().stream()
          .map(Role::getName)
          .collect(Collectors.toList());

      if (userDetails.getId() != null && roleNames.size() > 0
          && roleNames.get(0).name().equalsIgnoreCase(ERole.ROLE_ADMIN.name())) {
        ls = userRepository.findAllByOrderByIdDesc();

        filteredList = ls.stream()
            .filter(inverter -> inverter.getDeletedAt() == null)
            .collect(Collectors.toList());

        return new ResponseEntity<>(filteredList, HttpStatus.OK);
      } else {
        return new ResponseEntity<>(filteredList, HttpStatus.OK);
      }

    } catch (Exception e) {
      logger.error("Exception in AuthController_getAllUser", e);
      e.printStackTrace();
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  @PutMapping(path = "/macaddress", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<?> addMacAddress(@RequestParam(required = true) String macAddress,
      @RequestParam(required = true, defaultValue = "") String inverter_name,
      @RequestParam(required = true, defaultValue = "0") Integer inverter_power,
      @RequestHeader("Authorization") String authorizationHeader) {

    logger.info("Add Mac-Address-Auth-Controller");

    try {
      Optional<User> user;

      User userDetails = jwtUtils.getUserDetailsFromJwtToken(authorizationHeader);

      user = userRepository.findById(userDetails.getId());
      if (user.isPresent()) {

        // User userModel = new User();
        // userModel = user.get();
        // userModel.setMac_address(macAddress);
        // userRepository.save(userModel);

        User_Devices_Model user_Devices_Model = new User_Devices_Model();
        user_Devices_Model.setMac_address(macAddress);

        if (inverter_name.isEmpty()) {
          user_Devices_Model.setInverter_name(null);
        } else {
          user_Devices_Model.setInverter_name(inverter_name);
        }

        user_Devices_Model.setInverter_power(inverter_power);
        user_Devices_Model.setUser(user.get());

        if ((macAddress != null && macAddress != "") && !user_devices_service.findByMacAddress(macAddress)) {
          Boolean deviceAdded = user_devices_service.saveMacAddress(user_Devices_Model);

          if (deviceAdded) {
            return ResponseEntity.ok(new MessageResponse("User Device Added!"));
          } else {
            return ResponseEntity.ok(new MessageResponse("User Device Not Added! Something went Wrong!"));
          }

        } else {
          Optional<User_Devices_Model> user_Devices_Model2 = user_devices_service.findByMacParing(macAddress);
          if (user_Devices_Model2.isPresent()) {
            return ResponseEntity
                .ok(new MessageResponse("User Device Not Unique! Or Missing SSID!", user_Devices_Model2.get().getId()));
          } else {
            return ResponseEntity.ok(new MessageResponse("User Device Not Unique! Or Missing SSID!", 0));
          }

          // return ResponseEntity.ok(new MessageResponse("Mac Not Unique!"));

        }
      } else {
        return ResponseEntity.ok(new MessageResponse("User Not Found! Token Expired!"));
      }

    } catch (Exception e) {
      e.printStackTrace();
      return ResponseEntity.ok(new MessageResponse("Internal Error!"));
    }
  }

  @PutMapping(path = "/deleteUser", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<?> deleteUser(@RequestHeader("Authorization") String authorizationHeader,
      @RequestParam Integer userId,
      @RequestParam(required = false, defaultValue = "false") Boolean activeUser) {
    logger.info("AuthController_deleteUser_Called");

    try {

      User userDetails = jwtUtils.getUserDetailsFromJwtToken(authorizationHeader);

      List<ERole> roleNames = userDetails.getRoles().stream()
          .map(Role::getName)
          .collect(Collectors.toList());

      if (userDetails.getId() != null && roleNames.size() > 0
          && !roleNames.get(0).name().equalsIgnoreCase(ERole.ROLE_ADMIN.name())) {
        return new ResponseEntity<>("Not authorized", HttpStatus.FORBIDDEN);
      }

      if (userDetails.getId() != null && activeUser) {
        User updatedUser = userDetailsServiceImpl.markUserAsDeleted(userId, activeUser);
        if (updatedUser.getDeletedAt() == null) {
          return new ResponseEntity<>("User activated", HttpStatus.OK);
        }
      }

      if (userId != 1) {
        LocalDateTime deletedAtValue = userDetailsServiceImpl.getDeletedAt(userDetails.getEmail());
        if (deletedAtValue != null) {
          return new ResponseEntity<>("User already marked as deleted", HttpStatus.OK);
        }

        User updatedUser = userDetailsServiceImpl.markUserAsDeleted(userId, activeUser);
        if (updatedUser != null && updatedUser.getDeletedAt() != null) {
          return new ResponseEntity<>("User deleted", HttpStatus.OK);
        } else {
          return new ResponseEntity<>("User not found", HttpStatus.NOT_FOUND);
        }
      }

      return new ResponseEntity<>("Admin cannot be deleted", HttpStatus.OK);

    } catch (Exception e) {
      logger.error("Exception in AuthController_deleteUser", e);
      return new ResponseEntity<>("Internal server error", HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  @PutMapping(path = "/changepassword", consumes = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<String> changePassword(@RequestBody RequestChangePassword requestChangePassword,
      @RequestHeader("Authorization") String authorizationHeader) {

    logger.info("Change-Password-Auth-Controller");

    int check = 0;

    if (!requestChangePassword.getNewPassword().equals(requestChangePassword.getConfirmPassword())) {
      return new ResponseEntity<>("New & Confirm Password didn't match", HttpStatus.OK);
    }

    try {
      User user = new User();

      User userDetails = jwtUtils.getUserDetailsFromJwtToken(authorizationHeader);

      if (userDetails.getId() != null) {
        user.setId(userDetails.getId());
        user.setPassword(requestChangePassword.getOldPassword());
      }

      check = userDetailsServiceImpl.changeUserPassword(user, requestChangePassword.getNewPassword(),
          requestChangePassword.getForgetPassword());

    } catch (Exception e) {
      logger.error("Error While Changing Password", e);
    }

    if (check == 1) {
      return new ResponseEntity<>("Password Changed Successfully", HttpStatus.OK);
    } else {
      return new ResponseEntity<>("Incorrect Password", HttpStatus.OK);
    }

  }

  @PutMapping(path = "/forgotpassword", consumes = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<String> forgotPasswordOnLoginPage(@RequestBody ForgotPassword forgotPassword) {

    logger.info("ForgotPasswordOnLoginPage-Auth-Controller");

    int check = 0;

    if (!forgotPassword.getNewPassword().equals(forgotPassword.getConfirmPassword())) {
      return new ResponseEntity<>("New & Confirm Password didn't match", HttpStatus.OK);
    }

    try {
      Optional<User> user = userRepository.findByEmail(forgotPassword.getEmail());

      if (user.isPresent()) {
        check = userDetailsServiceImpl.forgotUserPassword(user.get(), forgotPassword.getNewPassword());
      } else {
        return new ResponseEntity<>("User Not Found!", HttpStatus.OK);
      }

    } catch (Exception e) {
      logger.error("Error While Changing Password", e);
    }

    if (check == 1) {
      return new ResponseEntity<>("Password Changed Successfully", HttpStatus.OK);
    } else {
      return new ResponseEntity<>("Something went wrong", HttpStatus.OK);
    }
  }

  @PutMapping(path = "/edituser", consumes = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<String> editUserProfile(@RequestBody UserProfileEditModel editUserDetails,
      @RequestHeader("Authorization") String authorizationHeader) {

    logger.info("Edit-User-Details-Auth-Controller");

    User userModel = new User();

    Boolean validate = jwtUtils.validateJwtToken(authorizationHeader);

    if (!validate) {
      return new ResponseEntity<>("Token Expired", HttpStatus.OK);
    }

    try {
      userModel = userDetailsServiceImpl.editUserProfile(editUserDetails);
    } catch (Exception e) {
      logger.error("Error While Updating User Profile", e);
    }

    if (userModel.getId() != null) {
      return new ResponseEntity<>("Profile Changed", HttpStatus.OK);
    } else {
      return new ResponseEntity<>("Profile Not Found!", HttpStatus.OK);
    }

  }

  @GetMapping(path = "/user-details", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<?> produceUserDetails(@RequestHeader("Authorization") String authorizationHeader) {

    logger.info("Produce User-Details-Auth-Controller");

    try {
      User userDetails;
      Long userId = 0L;
      Optional<User> user;

      Boolean validate = jwtUtils.validateJwtToken(authorizationHeader);

      if (!validate) {

        return new ResponseEntity<>("Token Expired", HttpStatus.OK);

      } else {
        userDetails = jwtUtils.getUserDetailsFromJwtToken(authorizationHeader);
        userId = userDetails.getId();
      }

      user = userRepository.findById(userId);
      if (user.isPresent()) {
        return new ResponseEntity<>(user, HttpStatus.OK);
      }

      return new ResponseEntity<>(user, HttpStatus.OK);

    } catch (Exception e) {
      e.printStackTrace();
      return ResponseEntity.ok(new MessageResponse("User-Details-Internal Error!"));
    }

  }

}

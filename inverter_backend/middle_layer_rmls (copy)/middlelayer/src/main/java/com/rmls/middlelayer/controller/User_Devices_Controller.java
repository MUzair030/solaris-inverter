package com.rmls.middlelayer.controller;

import java.io.IOException;
import java.util.List;
import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.rmls.middlelayer.configuration.JwtUtils;
import com.rmls.middlelayer.model.MessageResponse;
import com.rmls.middlelayer.model.User;
import com.rmls.middlelayer.model.User_Devices_Model;
import com.rmls.middlelayer.repository.UserRepository;
import com.rmls.middlelayer.service.PairingDeviceService;
import com.rmls.middlelayer.service.User_Device_Service;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/user")
public class User_Devices_Controller {

    private static final Logger logger = LoggerFactory.getLogger(User_Devices_Controller.class);

    @Autowired
    User_Device_Service user_devices_service;

    @Autowired
    JwtUtils jwtUtils;

    @Autowired
    UserRepository userRepository;

    @Autowired
    PairingDeviceService pairingDeviceService;

    @PostMapping(path = "/pairing", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<?> addMacAddress(@RequestParam(required = true) String macAddress,
            @RequestHeader("Authorization") String authorizationHeader) {

        logger.info("Add Pairing Mac-Address-UserDeviceController");

        try {
            Optional<User> user;

            User userDetails = jwtUtils.getUserDetailsFromJwtToken(authorizationHeader);

            user = userRepository.findById(userDetails.getId());
            if (user.isPresent()) {

                if ((macAddress != null && macAddress != "")) {
                    User_Devices_Model user_Devices_Model = new User_Devices_Model();
                    Optional<User_Devices_Model> deviceModel = user_devices_service.findByMacParing(macAddress);
                    if (deviceModel.isPresent()) {
                        user_Devices_Model = deviceModel.get();
                        Boolean devicePaired = pairingDeviceService.savePairedDevice(user_Devices_Model, user.get(),
                                macAddress);
                        if (devicePaired) {
                            return ResponseEntity.ok(new MessageResponse("Device Paired!"));
                        } else {
                            return ResponseEntity.ok(new MessageResponse("Device Not Paired!"));
                        }
                    } else {
                        return ResponseEntity.ok(new MessageResponse("Device Not Present!"));
                    }
                } else {
                    return ResponseEntity.ok(new MessageResponse("Mac Is Empty!"));
                }
            } else {
                return ResponseEntity.ok(new MessageResponse("User Not Found! Token Expired!"));
            }

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.ok(new MessageResponse("Internal Error!"));
        }
    }

    @GetMapping(path = "/devices", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<List<User_Devices_Model>> getAllUserDevices(
            @RequestHeader("Authorization") String authorizationHeader) {

        logger.info("User_Devices_getAllUserDevices");

        try {

            Long userId = 0L;
            User userDetails = jwtUtils.getUserDetailsFromJwtToken(authorizationHeader);

            if (userDetails != null) {
                userId = userDetails.getId();
            }

            List<User_Devices_Model> userDevices = user_devices_service.findAgainstUser(userId);
            return new ResponseEntity<>(userDevices, HttpStatus.OK);

        } catch (Exception e) {
            logger.error("Exception in User_Devices_Controller-getAllUserDevices", e);
            e.printStackTrace();
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @DeleteMapping(path = "/delete-device", consumes = MediaType.ALL_VALUE)
    public ResponseEntity<String> deleteDeviceData(@RequestParam Integer deviceId,
            @RequestHeader("Authorization") String authorizationHeader)
            throws IOException {

        logger.info("User_Device_Controller-delete-registered-device-data-Called");

        try {
            Boolean deviceData = null;
            Boolean validate = jwtUtils.validateJwtToken(authorizationHeader);

            if (!validate) {
                return new ResponseEntity<>("Token Expired", HttpStatus.OK);
            }

            deviceData = user_devices_service.deleteDevice(deviceId);

            if (deviceData) {
                return new ResponseEntity<>("Device Deleted", HttpStatus.OK);
            } else {
                return new ResponseEntity<>("Device Not Deleted", HttpStatus.OK);
            }

        } catch (Exception e) {
            logger.error("Exception in User_Device_Controller-delete-registered-device-data", e);
            e.printStackTrace();
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }

        // return new ResponseEntity<>("Device Already Deleted", HttpStatus.OK);

    }

}

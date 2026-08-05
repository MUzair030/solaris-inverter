package com.rmls.middlelayer.controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

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
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.rmls.middlelayer.configuration.JwtUtils;
import com.rmls.middlelayer.model.ERole;
import com.rmls.middlelayer.model.Inverter_Table_Model;
import com.rmls.middlelayer.model.InverterStatsBucketDTO;
import com.rmls.middlelayer.model.Role;
import com.rmls.middlelayer.model.User;
import com.rmls.middlelayer.service.Inverter_Service;
import com.rmls.middlelayer.service.WebSocketHandlerService;

@RestController
@CrossOrigin(origins = "*")
@RequestMapping("/api/inverter")
public class Inverter_Controller {

    private static final Logger logger = LoggerFactory.getLogger(Inverter_Controller.class);

    @Autowired
    Inverter_Service inverter_Service;

    @Autowired
    WebSocketHandlerService webSocketHandlerService;

    @Autowired
    JwtUtils jwtUtils;

    @PostMapping(path = "/save", consumes = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<?> saveInverterData(@RequestBody String rawBody,
            @RequestHeader("Authorization") String authorizationHeader) {

        logger.info("Inverter_Controller-save-inverter-data-Called");

        try {
            Boolean saveData;
            User user = new User();

            // Parsed manually (instead of Spring's automatic @RequestBody binding) so
            // the exact, unmodified JSON the caller sent can also be persisted verbatim
            // in raw_payload, alongside the normal parsed/typed fields.
            Inverter_Table_Model inverter_Table_Model = new ObjectMapper().readValue(rawBody,
                    Inverter_Table_Model.class);
            inverter_Table_Model.setRaw_payload(rawBody);

            User userDetails = jwtUtils.getUserDetailsFromJwtToken(authorizationHeader);

            if (userDetails.getId() != null) {
                user.setId(userDetails.getId());
                user.setUsername(userDetails.getUsername());
                user.setEmail(userDetails.getEmail());

                inverter_Table_Model.setUser(user);
            }

            saveData = inverter_Service.saveInverterData(inverter_Table_Model);

            return new ResponseEntity<>(saveData, HttpStatus.CREATED);

        } catch (Exception e) {
            logger.error("Exception in Inverter_Controller-save-inverter-data", e);
            e.printStackTrace(); // Log the exception for debugging purposes
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping(path = "/getAllInverterData", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<?> getInverterDataOnMac(
            @RequestParam(required = false, defaultValue = "") String macAddress,
            @RequestParam(required = false, defaultValue = "false") Boolean perday,
            @RequestParam(required = false, defaultValue = "false") Boolean perweek,
            @RequestParam(required = false, defaultValue = "false") Boolean permonth,
            @RequestParam(required = false, defaultValue = "false") Boolean peryear,
            @RequestHeader("Authorization") String authorizationHeader) {

        logger.info("Inverter_Controller-getInverterDataOn-MAC-Called");

        try {
            List<Inverter_Table_Model> ls = new ArrayList<>();

            Boolean validate = jwtUtils.validateJwtToken(authorizationHeader);

            if (!validate) {

                return new ResponseEntity<>("Token Expired", HttpStatus.OK);

            } else {

                if (macAddress != "" && macAddress != null) {
                    ls = inverter_Service.findByMACAddress(macAddress, perday, perweek, permonth, peryear);
                }
            }

            return new ResponseEntity<>(ls, HttpStatus.OK);

        } catch (Exception e) {
            logger.error("Exception in Inverter_Controller-getInverterDataOn-MAC", e);
            e.printStackTrace(); // Log the exception for debugging purposes
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @DeleteMapping(path = "/delete-inverter-data", consumes = MediaType.ALL_VALUE)
    public ResponseEntity<String> deleteInverterData(@RequestParam Integer inverterId,
            @RequestHeader("Authorization") String authorizationHeader)
            throws IOException {

        logger.info("Inverter_Controller-delete-inverter-data-Called");

        try {
            Boolean inverterData = null;

            User userDetails = jwtUtils.getUserDetailsFromJwtToken(authorizationHeader);

            List<ERole> roleNames = userDetails.getRoles().stream()
                    .map(Role::getName)
                    .collect(Collectors.toList());

            if (userDetails.getId() != null && roleNames.size() > 0
                    && !roleNames.get(0).name().equalsIgnoreCase(ERole.ROLE_ADMIN.name())) {
                return new ResponseEntity<>("Not authorized", HttpStatus.FORBIDDEN);
            } else {

                inverterData = inverter_Service.deleteInverterDataByAdmin(inverterId);

                if (inverterData) {
                    return new ResponseEntity<>("Record Deleted", HttpStatus.OK);
                } else {
                    return new ResponseEntity<>("Record Not Deleted", HttpStatus.OK);
                }
            }

        } catch (Exception e) {
            logger.error("Exception in Inverter_Controller-delete-inverter-data", e);
            e.printStackTrace();
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    // ------------------------------------------------------------------
    // Additions below this line. Nothing above this line was modified.
    // ------------------------------------------------------------------

    @GetMapping(path = "/stats", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<?> getInverterStats(
            @RequestParam(required = true) String macAddress,
            @RequestParam(required = true) String groupBy,
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate,
            @RequestHeader("Authorization") String authorizationHeader) {

        logger.info("Inverter_Controller-getInverterStats-Called");

        try {
            Boolean validate = jwtUtils.validateJwtToken(authorizationHeader);

            if (!validate) {

                return new ResponseEntity<>("Token Expired", HttpStatus.OK);

            }

            List<InverterStatsBucketDTO> stats = inverter_Service.getStats(macAddress, groupBy, startDate, endDate);

            return new ResponseEntity<>(stats, HttpStatus.OK);

        } catch (IllegalArgumentException e) {
            logger.error("Invalid input in Inverter_Controller-getInverterStats", e);
            return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
        } catch (Exception e) {
            logger.error("Exception in Inverter_Controller-getInverterStats", e);
            e.printStackTrace(); // Log the exception for debugging purposes
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping(path = "/latest", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<?> getLatestInverterData(
            @RequestParam(required = true) String macAddress,
            @RequestHeader("Authorization") String authorizationHeader) {

        logger.info("Inverter_Controller-getLatestInverterData-Called");

        try {
            Boolean validate = jwtUtils.validateJwtToken(authorizationHeader);

            if (!validate) {

                return new ResponseEntity<>("Token Expired", HttpStatus.OK);

            }

            Inverter_Table_Model latest = inverter_Service.findLatestByMacAddress(macAddress);

            return new ResponseEntity<>(latest, HttpStatus.OK);

        } catch (Exception e) {
            logger.error("Exception in Inverter_Controller-getLatestInverterData", e);
            e.printStackTrace(); // Log the exception for debugging purposes
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

}

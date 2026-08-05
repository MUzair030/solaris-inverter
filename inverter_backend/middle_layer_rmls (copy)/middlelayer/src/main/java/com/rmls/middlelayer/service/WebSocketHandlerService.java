package com.rmls.middlelayer.service;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.rmls.middlelayer.model.Inverter_Table_Model;
import com.rmls.middlelayer.model.User_Devices_Model;
import com.rmls.middlelayer.repository.UserRepository;
import com.rmls.middlelayer.repository.User_Devices_Repository;

@Service
public class WebSocketHandlerService extends TextWebSocketHandler {

    private static final Logger logger = LoggerFactory.getLogger(WebSocketHandlerService.class);

    private static List<WebSocketSession> activeSessions = new ArrayList<>();

    @Autowired
    Inverter_Service inverter_Service;

    @Autowired
    UserRepository userRepository;

    @Autowired
    User_Devices_Repository user_Devices_Repository;

    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {

        logger.info("WebSocketHandlerService-afterConnectionEstablished-Called");
        // Connection established, you can send messages to this session
        activeSessions.add(session);
        session.sendMessage(new TextMessage("Welcome to the WebSocket server!"));
    }

    @Override
    public void handleMessage(WebSocketSession session, WebSocketMessage<?> message) throws Exception {

        logger.info("WebSocketHandlerService-handleMessage-Called");

        // if (receivedMessage.startsWith("\"") && receivedMessage.endsWith("\"")) {
        // receivedMessage = receivedMessage.substring(1, receivedMessage.length() - 1);
        // }
        Boolean dataSaved = false;
        String receivedMessage = (String) message.getPayload();
        logger.info("Received message from Inverter : " + receivedMessage);

        try {
            ObjectMapper objectMapper = new ObjectMapper();

            // Convert string to JSON
            JsonNode jsonNode = objectMapper.readTree(receivedMessage);

            // Variable Defined
            Double energy_consumed = null;
            Double gen_power = null;
            Double pv_voltage = null;
            Double output_voltage = null;
            Double output_current = null;
            Integer error_bit = null;
            String device_name = null;
            String mac = null;
            String version = null;

            // Extract fields from the JSON
            if (jsonNode.has("energy")) {
                energy_consumed = jsonNode.get("energy").asDouble();
            }
            if (jsonNode.has("gen_power")) {
                gen_power = jsonNode.get("gen_power").asDouble();
            }
            if (jsonNode.has("pv_vol")) {
                pv_voltage = jsonNode.get("pv_vol").asDouble();
            }
            if (jsonNode.has("op_vol")) {
                output_voltage = jsonNode.get("op_vol").asDouble();
            }
            if (jsonNode.has("op_cur")) {
                output_current = jsonNode.get("op_cur").asDouble();
            }
            if (jsonNode.has("err")) {
                error_bit = jsonNode.get("err").asInt();
            }
            if (jsonNode.has("device_name")) {
                device_name = jsonNode.get("device_name").asText();
            }
            if (jsonNode.has("mac")) {
                mac = jsonNode.get("mac").asText();
            }
            if (jsonNode.has("ver")) {
                version = jsonNode.get("ver").asText();
            }

            Inverter_Table_Model inverterModel = new Inverter_Table_Model();

            inverterModel.setEnergy_consumed(energy_consumed);
            inverterModel.setGen_power(gen_power);
            inverterModel.setPv_voltage(pv_voltage);
            inverterModel.setOutput_voltage(output_voltage);
            inverterModel.setOutput_current(output_current);
            inverterModel.setMac_address(mac);
            inverterModel.setError(error_bit);
            inverterModel.setDevice_name(device_name);

            if (version == null) {
                inverterModel.setVersion("VER_3");
            } else {
                inverterModel.setVersion(version);
            }

            try {
                Optional<User_Devices_Model> userAgainstMacAddress = user_Devices_Repository.findAgainstMACAddress(mac);
                if (userAgainstMacAddress.isPresent()) {
                    inverterModel.setUser(userAgainstMacAddress.get().getUser());
                } else {
                    logger.error("No User Found!");
                }
            } catch (Exception e) {
                logger.error("Error! No User Found!");
            }

            // Optional<User> userFromDB = userRepository.findByMacAddress(mac);
            // if(userFromDB.isPresent()){
            // inverterModel.setUser(userFromDB.get());
            // }

            if (mac != null && mac != "") {
                dataSaved = inverter_Service.saveInverterData(inverterModel);
                if (dataSaved) {
                    logger.info("Data Saved Successfully!");
                } else {
                    logger.error("Error! Data Not Saved!");
                }
            } else {
                logger.error("Error! No Mac Address Found!");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void sendMessageToAll(String message) throws IOException {

        logger.info("WebSocketHandlerService-sendMessageToAll-Called");
        List<WebSocketSession> sessionsToRemove = new ArrayList<>();

        for (WebSocketSession session : activeSessions) {
            try {
                if (session.isOpen()) {
                    session.sendMessage(new TextMessage(message));
                } else {
                    // The session is closed, mark it for removal
                    sessionsToRemove.add(session);
                }
            } catch (IOException e) {
                // Handle any exceptions that may occur during message sending
            }
        }

        // Remove closed sessions from the activeSessions list
        activeSessions.removeAll(sessionsToRemove);
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {

        logger.info("WebSocketHandlerService-afterConnectionClosed-Called");
        super.afterConnectionClosed(session, status);
    }

    public void closeWebSocketConnection(WebSocketSession session, CloseStatus closeStatus) {

        logger.info("WebSocketHandlerService-closeWebSocketConnection-Called");
        try {
            if (session != null && session.isOpen()) {
                session.close(closeStatus);
            }
        } catch (Exception e) {
            // Handle the exception appropriately
        }
    }
}
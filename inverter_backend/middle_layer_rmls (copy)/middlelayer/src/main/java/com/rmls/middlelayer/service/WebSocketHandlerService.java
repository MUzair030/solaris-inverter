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

            Inverter_Table_Model inverterModel = new Inverter_Table_Model();
            String mac = null;

            // Newer firmware sends "solar_power" (PV-only power, distinct from total output
            // power); older firmware never sends this key. Use its presence to detect format.
            boolean isNewFormat = jsonNode.has("solar_power");

            if (isNewFormat) {

                // New hardware format - see class-level firmware notes. err/device_name/ver are
                // simply absent from this format, so those columns (and version's old-format-only
                // "VER_3" fallback below) are intentionally left null - never fabricated.
                Double solarVoltage = null;
                Double solarPower = null;
                Double solarUnits = null;
                Double outputVoltage = null;
                Double outputCurrent = null;
                Double outputPower = null;
                Double energyConsumed = null;
                Double gridVoltage = null;
                Double gridPower = null;
                Double gridUnits = null;
                Integer deviceType = null;

                if (jsonNode.has("solar_voltage")) {
                    solarVoltage = jsonNode.get("solar_voltage").asDouble();
                }
                if (jsonNode.has("solar_power")) {
                    solarPower = jsonNode.get("solar_power").asDouble();
                }
                if (jsonNode.has("solar_units")) {
                    solarUnits = jsonNode.get("solar_units").asDouble();
                }
                if (jsonNode.has("output_voltage")) {
                    outputVoltage = jsonNode.get("output_voltage").asDouble();
                }
                if (jsonNode.has("output_current")) {
                    outputCurrent = jsonNode.get("output_current").asDouble();
                }
                if (jsonNode.has("output_power")) {
                    outputPower = jsonNode.get("output_power").asDouble();
                }
                if (jsonNode.has("energy_consumed")) {
                    energyConsumed = jsonNode.get("energy_consumed").asDouble();
                }
                if (jsonNode.has("grid_voltage")) {
                    gridVoltage = jsonNode.get("grid_voltage").asDouble();
                }
                if (jsonNode.has("grid_power")) {
                    // Assumption (NOT yet confirmed by the hardware team - only sane reading of
                    // the sample payload's numbers): positive = importing from grid, negative =
                    // exporting to grid.
                    gridPower = jsonNode.get("grid_power").asDouble();
                }
                if (jsonNode.has("grid_units")) {
                    gridUnits = jsonNode.get("grid_units").asDouble();
                }
                if (jsonNode.has("device_type")) {
                    deviceType = jsonNode.get("device_type").asInt();
                }
                if (jsonNode.has("mac")) {
                    mac = jsonNode.get("mac").asText();
                }

                // Direct 1:1 mappings into the SAME existing columns the old format used, so
                // every existing feature that already reads these columns (stats bucketing,
                // live dashboard, etc.) keeps working unchanged.
                inverterModel.setPv_voltage(solarVoltage);
                inverterModel.setOutput_voltage(outputVoltage);
                inverterModel.setOutput_current(outputCurrent);
                inverterModel.setEnergy_consumed(energyConsumed);
                inverterModel.setMac_address(mac);
                // Historical analysis confirmed old gen_power always actually represented total
                // output power, not solar-only power, so output_power is the historically-correct
                // backward-compatible value for it.
                inverterModel.setGen_power(outputPower);

                // New columns.
                inverterModel.setSolar_power(solarPower);
                inverterModel.setSolar_units(solarUnits);
                inverterModel.setOutput_power(outputPower);
                inverterModel.setGrid_voltage(gridVoltage);
                inverterModel.setGrid_power(gridPower);
                inverterModel.setGrid_units(gridUnits);
                inverterModel.setDevice_type(deviceType);

                // Not present in the new format - leave genuinely null, no defaults fabricated.
                inverterModel.setError(null);
                inverterModel.setDevice_name(null);
                inverterModel.setVersion(null);

            } else {

                // Old hardware format (unchanged behavior).
                Double energy_consumed = null;
                Double gen_power = null;
                Double pv_voltage = null;
                Double output_voltage = null;
                Double output_current = null;
                Integer error_bit = null;
                String device_name = null;
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
            }

            inverterModel.setRaw_payload(receivedMessage);

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
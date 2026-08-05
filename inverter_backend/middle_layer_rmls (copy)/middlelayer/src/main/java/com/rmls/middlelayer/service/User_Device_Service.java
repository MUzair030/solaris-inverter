package com.rmls.middlelayer.service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.rmls.middlelayer.model.Inverter_Table_Model;
import com.rmls.middlelayer.model.PairingDeviceModel;
import com.rmls.middlelayer.model.User;
import com.rmls.middlelayer.model.User_Devices_Model;
import com.rmls.middlelayer.repository.Inverter_Repository;
import com.rmls.middlelayer.repository.PairingRepository;
import com.rmls.middlelayer.repository.User_Devices_Repository;

@Service
public class User_Device_Service {

    private static final Logger logger = LoggerFactory.getLogger(User_Device_Service.class);

    @Autowired
    User_Devices_Repository user_Devices_Repository;

    @Autowired
    PairingRepository pairingRepository;

    @Autowired
    Inverter_Repository inverter_Repository;

    public Boolean saveMacAddress(User_Devices_Model user_Devices_Model) {

        try {
            user_Devices_Repository.save(user_Devices_Model);
            return true;
        } catch (Exception e) {
            logger.error("Error while saving the inverter device!");
            return false;
        }
    }

    public Boolean findByMacAddress(String macAddress) {

        Optional<User_Devices_Model> userDevices = user_Devices_Repository.findAgainstMACAddress(macAddress);
        if (userDevices.isPresent()) {
            return true;
        } else {
            return false;
        }
    }

    public List<User_Devices_Model> findAgainstUser(Long userId) {

        List<User_Devices_Model> filteredList = new ArrayList<>();

        for (User_Devices_Model list : user_Devices_Repository.findAgainstUserID(userId)) {

            User_Devices_Model user_Devices_Model = new User_Devices_Model();
            User u = new User();

            u.setId(list.getUser().getId());
            u.setUsername(list.getUser().getUsername());
            u.setLastName(list.getUser().getLastName());
            u.setEmail(list.getUser().getEmail());
            u.setAddress(list.getUser().getAddress());
            u.setPhone(list.getUser().getPhone());

            u.setRoles(null);

            user_Devices_Model.setId(list.getId());
            user_Devices_Model.setMac_address(list.getMac_address());
            user_Devices_Model.setInverter_name(list.getInverter_name());
            user_Devices_Model.setInverter_power(list.getInverter_power());
            user_Devices_Model.setUser(u);

            filteredList.add(user_Devices_Model);

        }

        // ------------------------------------
        // ----- Paired Devices
        for (PairingDeviceModel list : pairingRepository.findAgainstUserID(userId)) {

            User_Devices_Model user_Devices_Model = new User_Devices_Model();
            User u = new User();

            u.setId(list.getUser().getId());
            u.setUsername(list.getUser().getUsername());
            u.setLastName(list.getUser().getLastName());
            u.setEmail(list.getUser().getEmail());
            u.setAddress(list.getUser().getAddress());
            u.setPhone(list.getUser().getPhone());

            u.setRoles(null);

            user_Devices_Model.setId(list.getUser_Devices_Model().getId());
            user_Devices_Model.setMac_address(list.getUser_Devices_Model().getMac_address());
            user_Devices_Model.setInverter_name(list.getUser_Devices_Model().getInverter_name());
            user_Devices_Model.setInverter_power(list.getUser_Devices_Model().getInverter_power());
            user_Devices_Model.setUser(u);

            filteredList.add(user_Devices_Model);

        }

        return filteredList;
    }

    // Delete Registered Device
    public Boolean deleteDevice(Integer deviceId) {

        logger.info("User_Device_Service-deleteDevice-Called");

        User_Devices_Model user_Devices_Model = new User_Devices_Model();
        Optional<User_Devices_Model> user_device = user_Devices_Repository.findByDeviceId(deviceId);
        if (user_device.isPresent()) {

            List<PairingDeviceModel> listPaired = pairingRepository.findByDeviceID(user_device.get().getMac_address());
            pairingRepository.deleteAll(listPaired);

            List<Inverter_Table_Model> inverter = inverter_Repository
                    .findByMacAddress(user_device.get().getMac_address());
            inverter_Repository.deleteAll(inverter);

            user_Devices_Model = user_device.get();
            try {
                user_Devices_Repository.delete(user_Devices_Model);
                return true;
            } catch (Exception e) {
                logger.info("Device Data Not Deleted" + deviceId);
                return false;
            }
        } else {
            return false;
        }
    }

    // ----------------------------------
    // This Method is created for finding against MacAddress
    // Using For Pairing Device
    public Optional<User_Devices_Model> findByMacParing(String macAddress) {
        return user_Devices_Repository.findAgainstMACAddress(macAddress);
    }

    // public User_Devices_Model findByDeviceBySSIDAddress(String ssid) {

    //     Optional<User_Devices_Model> userDevices = user_Devices_Repository.findAgainstMACAddress(ssid);
    //     if (userDevices.isPresent()) {
    //         return userDevices.get();
    //     } else {
    //         return new User_Devices_Model();
    //     }
    // }
}

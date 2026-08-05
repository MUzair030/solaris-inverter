package com.rmls.middlelayer.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.rmls.middlelayer.model.PairingDeviceModel;
import com.rmls.middlelayer.model.User;
import com.rmls.middlelayer.model.User_Devices_Model;
import com.rmls.middlelayer.repository.PairingRepository;

@Service
public class PairingDeviceService {
    
    @Autowired
    PairingRepository pairingRepository;

    public List<PairingDeviceModel> findByUserId(Long userId){
        return pairingRepository.findAgainstUserID(userId);
    }

    public Boolean savePairedDevice(User_Devices_Model user_Devices_Model, User user, String macAddress){
        PairingDeviceModel pairingDeviceModel = new PairingDeviceModel();
        
        pairingDeviceModel.setUser_Devices_Model(user_Devices_Model);
        pairingDeviceModel.setUser(user);
        pairingDeviceModel.setMac_address(macAddress);

        pairingDeviceModel = pairingRepository.save(pairingDeviceModel);

        if(pairingDeviceModel.getId() > 0){
            return true;
        } else {
            return false;
        }
    }

}

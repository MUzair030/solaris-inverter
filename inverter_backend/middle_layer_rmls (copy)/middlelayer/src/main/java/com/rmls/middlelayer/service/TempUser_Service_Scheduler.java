package com.rmls.middlelayer.service;

import java.time.LocalDateTime;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import com.rmls.middlelayer.model.TempUser_Model;
import com.rmls.middlelayer.repository.TempUser_Repository;


@Service
public class TempUser_Service_Scheduler {

    @Autowired
    private TempUser_Repository tempUser_Repository;

    @Scheduled(fixedRate = 60000)
    public void deleteExpiredOtps() {
        LocalDateTime fifteenMinutesAgo = LocalDateTime.now().minusMinutes(15);
        tempUser_Repository.deleteOtpsOlderThan(fifteenMinutesAgo);
    }

    public Boolean saveTempUserOtp(String email, String otp) {
        try {
            TempUser_Model tempUser_Model = new TempUser_Model();
            tempUser_Model.setEmail(email);
            tempUser_Model.setEmailOtp(otp);
            tempUser_Model.setCreatedAt(LocalDateTime.now());
            tempUser_Repository.save(tempUser_Model);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }

    }

    public Optional<TempUser_Model> findByEmailAddress(String email) {
        return tempUser_Repository.findByEmailTempUser(email);
    }

    // -- Validate OTP For Verification
    public Boolean validate_user_otp(TempUser_Model user, String emailOtp) {

        if (user.getEmail() != null && user.getEmailOtp().equals(emailOtp)) {
            return true;
        } else {
            return false;
        }
    }

}

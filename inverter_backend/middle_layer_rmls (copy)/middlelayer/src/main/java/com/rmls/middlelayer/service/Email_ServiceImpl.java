package com.rmls.middlelayer.service;

import java.util.Random;

import org.springframework.stereotype.Service;

@Service
public class Email_ServiceImpl {
    
    public String generateOTP() {

        String alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        Random random = new Random();

        // Generate three random alphabets
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < 3; i++) {
            char randomChar = alphabet.charAt(random.nextInt(alphabet.length()));
            sb.append(randomChar);
        }

        // Generate four random digits
        int randomNumber = random.nextInt(10000);
        String formattedNumber = String.format("%04d", randomNumber);

        String otp = sb.toString() + "-" + formattedNumber;

        return otp;
    }
}

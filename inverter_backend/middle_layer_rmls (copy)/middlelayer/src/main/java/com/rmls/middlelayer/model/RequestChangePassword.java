package com.rmls.middlelayer.model;

import org.springframework.stereotype.Component;

@Component
public class RequestChangePassword {

    private String oldPassword;
    private String newPassword;
    private String confirmPassword;
    private Boolean forgetPassword;

    public String getOldPassword() {
        return oldPassword;
    }

    public void setOldPassword(String oldPassword) {
        this.oldPassword = oldPassword;
    }

    public String getNewPassword() {
        return newPassword;
    }

    public void setNewPassword(String newPassword) {
        this.newPassword = newPassword;
    }

    public String getConfirmPassword() {
        return confirmPassword;
    }

    public void setConfirmPassword(String confirmPassword) {
        this.confirmPassword = confirmPassword;
    }

    public Boolean getForgetPassword() {
        return forgetPassword;
    }

    public void setForgetPassword(Boolean forgetPassword) {
        this.forgetPassword = forgetPassword;
    }

}

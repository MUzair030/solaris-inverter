package com.rmls.middlelayer.model;

import com.fasterxml.jackson.annotation.JsonInclude;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "user_devices_table")
@JsonInclude(JsonInclude.Include.NON_NULL)
public class User_Devices_Model {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "mac_address")
    private String mac_address;

    @Column(name = "inverter_name")
    private String inverter_name;

    @Column(name = "inverter_power")
    private Integer inverter_power;

    @ManyToOne(fetch = FetchType.EAGER, optional = false)
    @JoinColumn(name = "user_id", nullable = true)
    private User user;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getMac_address() {
        return mac_address;
    }

    public void setMac_address(String mac_address) {
        this.mac_address = mac_address;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public String getInverter_name() {
        return inverter_name;
    }

    public void setInverter_name(String inverter_name) {
        this.inverter_name = inverter_name;
    }

    public Integer getInverter_power() {
        return inverter_power;
    }

    public void setInverter_power(Integer inverter_power) {
        this.inverter_power = inverter_power;
    }

    

}

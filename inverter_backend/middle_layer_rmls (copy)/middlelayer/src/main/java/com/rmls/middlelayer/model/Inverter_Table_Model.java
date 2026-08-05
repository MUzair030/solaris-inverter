package com.rmls.middlelayer.model;

import java.time.LocalDateTime;

import com.fasterxml.jackson.annotation.JsonIgnore;
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
@Table(name = "inverter_table")
@JsonInclude(JsonInclude.Include.NON_NULL)
public class Inverter_Table_Model {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "energy_consumed")
    private Double energy_consumed;

    @Column(name = "gen_power")
    private Double gen_power;

    @Column(name = "pv_voltage")
    private Double pv_voltage;

    @Column(name = "output_voltage")
    private Double output_voltage;

    @Column(name = "output_current")
    private Double output_current;

    @Column(name = "mac_address")
    private String mac_address;

    @Column(name = "error")
    private Integer error;

    @Column(name = "device_name")
    private String device_name;

    @Column(name = "version")
    private String version;

    // Full, unmodified JSON payload exactly as received from the hardware
    // device (over the websocket ingestion path) or the /save REST caller,
    // stored verbatim so nothing the device sends is ever lost even if a
    // future firmware adds fields this backend doesn't parse yet. Not part
    // of any existing API response (JsonIgnore) - it's a backend-only audit
    // trail, not user-facing telemetry.
    @JsonIgnore
    @Column(name = "raw_payload", columnDefinition = "TEXT")
    private String raw_payload;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "deleted_at")
    private LocalDateTime deletedAt;

    @JsonIgnore
    @ManyToOne(fetch = FetchType.EAGER, optional = false)
    @JoinColumn(name = "user_id", nullable = true)
    private User user;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Double getEnergy_consumed() {
        return energy_consumed;
    }

    public void setEnergy_consumed(Double energy_consumed) {
        this.energy_consumed = energy_consumed;
    }

    public Double getGen_power() {
        return gen_power;
    }

    public void setGen_power(Double gen_power) {
        this.gen_power = gen_power;
    }

    public Double getPv_voltage() {
        return pv_voltage;
    }

    public void setPv_voltage(Double pv_voltage) {
        this.pv_voltage = pv_voltage;
    }

    public Double getOutput_voltage() {
        return output_voltage;
    }

    public void setOutput_voltage(Double output_voltage) {
        this.output_voltage = output_voltage;
    }

    public Double getOutput_current() {
        return output_current;
    }

    public void setOutput_current(Double output_current) {
        this.output_current = output_current;
    }

    public String getMac_address() {
        return mac_address;
    }

    public void setMac_address(String mac_address) {
        this.mac_address = mac_address;
    }

    public Integer getError() {
        return error;
    }

    public void setError(Integer error) {
        this.error = error;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getDeletedAt() {
        return deletedAt;
    }

    public void setDeletedAt(LocalDateTime deletedAt) {
        this.deletedAt = deletedAt;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public String getDevice_name() {
        return device_name;
    }

    public void setDevice_name(String device_name) {
        this.device_name = device_name;
    }

    public String getVersion() {
        return version;
    }

    public void setVersion(String version) {
        this.version = version;
    }

    public String getRaw_payload() {
        return raw_payload;
    }

    public void setRaw_payload(String raw_payload) {
        this.raw_payload = raw_payload;
    }

}
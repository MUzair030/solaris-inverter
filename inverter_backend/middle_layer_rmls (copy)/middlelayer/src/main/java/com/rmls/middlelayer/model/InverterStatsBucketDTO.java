package com.rmls.middlelayer.model;

/**
 * Plain response DTO for the /api/inverter/stats endpoint.
 *
 * Every numeric value on this DTO is derived from real inverter_table rows
 * (energy_consumed / gen_power / pv_voltage / output_voltage / output_current),
 * with the single exception of zero-valued, explicitly-flagged "padded" placeholder
 * buckets that the service synthesizes purely as a calendar placeholder so a
 * requested time series stays continuous (see Inverter_Service#getStats).
 */
public class InverterStatsBucketDTO {

    // Display label for the bucket, e.g. "2026-08-05", "2026-08-05 09:00", "2026-08", "2026"
    private String bucket;

    // ISO-8601 local-date-time string usable as an unambiguous chronological sort key
    private String bucketStart;

    // Number of raw inverter_table rows that fell into this bucket (0 for padded buckets)
    private int count;

    // max(energy_consumed) - min(energy_consumed) within the bucket, floored at 0; 0.0 if count == 0
    private double energyDeltaKwh;

    private double avgGenPowerKw;

    private double avgPvVoltage;

    private double avgOutputVoltage;

    private double avgOutputCurrent;

    // true when this bucket had zero real rows and was synthesized as a zero-valued placeholder
    private boolean padded;

    public InverterStatsBucketDTO() {
    }

    public InverterStatsBucketDTO(String bucket, String bucketStart, int count, double energyDeltaKwh,
            double avgGenPowerKw, double avgPvVoltage, double avgOutputVoltage, double avgOutputCurrent,
            boolean padded) {
        this.bucket = bucket;
        this.bucketStart = bucketStart;
        this.count = count;
        this.energyDeltaKwh = energyDeltaKwh;
        this.avgGenPowerKw = avgGenPowerKw;
        this.avgPvVoltage = avgPvVoltage;
        this.avgOutputVoltage = avgOutputVoltage;
        this.avgOutputCurrent = avgOutputCurrent;
        this.padded = padded;
    }

    public String getBucket() {
        return bucket;
    }

    public void setBucket(String bucket) {
        this.bucket = bucket;
    }

    public String getBucketStart() {
        return bucketStart;
    }

    public void setBucketStart(String bucketStart) {
        this.bucketStart = bucketStart;
    }

    public int getCount() {
        return count;
    }

    public void setCount(int count) {
        this.count = count;
    }

    public double getEnergyDeltaKwh() {
        return energyDeltaKwh;
    }

    public void setEnergyDeltaKwh(double energyDeltaKwh) {
        this.energyDeltaKwh = energyDeltaKwh;
    }

    public double getAvgGenPowerKw() {
        return avgGenPowerKw;
    }

    public void setAvgGenPowerKw(double avgGenPowerKw) {
        this.avgGenPowerKw = avgGenPowerKw;
    }

    public double getAvgPvVoltage() {
        return avgPvVoltage;
    }

    public void setAvgPvVoltage(double avgPvVoltage) {
        this.avgPvVoltage = avgPvVoltage;
    }

    public double getAvgOutputVoltage() {
        return avgOutputVoltage;
    }

    public void setAvgOutputVoltage(double avgOutputVoltage) {
        this.avgOutputVoltage = avgOutputVoltage;
    }

    public double getAvgOutputCurrent() {
        return avgOutputCurrent;
    }

    public void setAvgOutputCurrent(double avgOutputCurrent) {
        this.avgOutputCurrent = avgOutputCurrent;
    }

    public boolean isPadded() {
        return padded;
    }

    public void setPadded(boolean padded) {
        this.padded = padded;
    }

}

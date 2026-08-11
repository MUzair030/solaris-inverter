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

    // ------------------------------------------------------------------
    // Additions below this line support the newer hardware firmware's
    // solar/grid telemetry (see Inverter_Table_Model and
    // WebSocketHandlerService for the dual-format parsing that populates the
    // underlying columns). These default to 0.0 for buckets containing only
    // old-format rows (or no rows at all), same as the existing avg* fields.
    // ------------------------------------------------------------------

    // max(solar_units) - min(solar_units) within the bucket, floored at 0; 0.0 if no non-null
    // solar_units samples fell in this bucket (e.g. old-format-only rows, or a padded bucket).
    private double solarEnergyDeltaKwh;

    // Same pattern as solarEnergyDeltaKwh, using grid_units (cumulative grid import energy).
    private double gridEnergyDeltaKwh;

    private double avgSolarPowerKw;

    private double avgOutputPowerKw;

    private double avgGridPowerKw;

    private double avgGridVoltage;

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

    // Overload additionally carrying the new solar/grid telemetry fields. Used wherever the
    // bucketing query rows have been extended with the new aggregate columns (see
    // Inverter_Service#getTimeSeriesStats); other call sites (padded placeholders,
    // getYearStats/getTotalStats) keep using the 9-arg constructor above, which leaves these
    // new fields at their default 0.0.
    public InverterStatsBucketDTO(String bucket, String bucketStart, int count, double energyDeltaKwh,
            double avgGenPowerKw, double avgPvVoltage, double avgOutputVoltage, double avgOutputCurrent,
            boolean padded, double solarEnergyDeltaKwh, double gridEnergyDeltaKwh, double avgSolarPowerKw,
            double avgOutputPowerKw, double avgGridPowerKw, double avgGridVoltage) {
        this(bucket, bucketStart, count, energyDeltaKwh, avgGenPowerKw, avgPvVoltage, avgOutputVoltage,
                avgOutputCurrent, padded);
        this.solarEnergyDeltaKwh = solarEnergyDeltaKwh;
        this.gridEnergyDeltaKwh = gridEnergyDeltaKwh;
        this.avgSolarPowerKw = avgSolarPowerKw;
        this.avgOutputPowerKw = avgOutputPowerKw;
        this.avgGridPowerKw = avgGridPowerKw;
        this.avgGridVoltage = avgGridVoltage;
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

    public double getSolarEnergyDeltaKwh() {
        return solarEnergyDeltaKwh;
    }

    public void setSolarEnergyDeltaKwh(double solarEnergyDeltaKwh) {
        this.solarEnergyDeltaKwh = solarEnergyDeltaKwh;
    }

    public double getGridEnergyDeltaKwh() {
        return gridEnergyDeltaKwh;
    }

    public void setGridEnergyDeltaKwh(double gridEnergyDeltaKwh) {
        this.gridEnergyDeltaKwh = gridEnergyDeltaKwh;
    }

    public double getAvgSolarPowerKw() {
        return avgSolarPowerKw;
    }

    public void setAvgSolarPowerKw(double avgSolarPowerKw) {
        this.avgSolarPowerKw = avgSolarPowerKw;
    }

    public double getAvgOutputPowerKw() {
        return avgOutputPowerKw;
    }

    public void setAvgOutputPowerKw(double avgOutputPowerKw) {
        this.avgOutputPowerKw = avgOutputPowerKw;
    }

    public double getAvgGridPowerKw() {
        return avgGridPowerKw;
    }

    public void setAvgGridPowerKw(double avgGridPowerKw) {
        this.avgGridPowerKw = avgGridPowerKw;
    }

    public double getAvgGridVoltage() {
        return avgGridVoltage;
    }

    public void setAvgGridVoltage(double avgGridVoltage) {
        this.avgGridVoltage = avgGridVoltage;
    }

}

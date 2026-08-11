package com.rmls.middlelayer.repository;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.rmls.middlelayer.model.Inverter_Table_Model;

@Repository
public interface Inverter_Repository extends JpaRepository<Inverter_Table_Model, Integer> {

    @Query(value = "SELECT * FROM inverter_table WHERE mac_address = :mac_address order by id asc", nativeQuery = true)
    List<Inverter_Table_Model> findByMacAddress(@Param("mac_address") String mac_address);

    @Query(value = "SELECT * FROM inverter_table WHERE mac_address = :mac_address AND DATE(created_at) = :perday ORDER BY id ASC", nativeQuery = true)
    List<Inverter_Table_Model> findByMacAddressPerDay(@Param("mac_address") String mac_address,
            @Param("perday") String perday);

    @Query(value = "SELECT * FROM inverter_table WHERE mac_address = :mac_address AND DATE(created_at) BETWEEN :endDate AND :startDate ORDER BY id ASC", nativeQuery = true)
    List<Inverter_Table_Model> findByMacAddressAccordingToStartAndEnd(@Param("mac_address") String mac_address,
            @Param("startDate") String startDate, @Param("endDate") String endDate);

    @Query(value = "SELECT * FROM inverter_table order by id asc", nativeQuery = true)
    List<Inverter_Table_Model> findAllByOrderByIdAsc();

    // ------------------------------------------------------------------
    // Additions below this line support GET /api/inverter/stats and
    // GET /api/inverter/latest. Nothing above this line was modified.
    // ------------------------------------------------------------------

    @Query(value = "SELECT * FROM inverter_table WHERE mac_address = :mac ORDER BY id DESC LIMIT 1", nativeQuery = true)
    Inverter_Table_Model findFirstByMacAddressOrderByIdDesc(@Param("mac") String mac);

    // Hourly buckets: columns = [bucket_label, count, min_energy, max_energy, avg_gen_power,
    // avg_pv_voltage, avg_output_voltage, avg_output_current, min_solar_units, max_solar_units,
    // min_grid_units, max_grid_units, avg_solar_power, avg_output_power, avg_grid_power,
    // avg_grid_voltage]
    @Query(value = "SELECT DATE_FORMAT(created_at, '%Y-%m-%d %H:00') AS bucket_label, "
            + "COUNT(*) AS cnt, MIN(energy_consumed) AS min_energy, MAX(energy_consumed) AS max_energy, "
            + "AVG(gen_power) AS avg_gen_power, AVG(pv_voltage) AS avg_pv_voltage, "
            + "AVG(output_voltage) AS avg_output_voltage, AVG(output_current) AS avg_output_current "
            + ", MIN(solar_units) AS min_solar_units, MAX(solar_units) AS max_solar_units, "
            + "MIN(grid_units) AS min_grid_units, MAX(grid_units) AS max_grid_units, "
            + "AVG(solar_power) AS avg_solar_power, AVG(output_power) AS avg_output_power, "
            + "AVG(grid_power) AS avg_grid_power, AVG(grid_voltage) AS avg_grid_voltage "
            + "FROM inverter_table WHERE mac_address = :mac AND created_at BETWEEN :start AND :end "
            + "GROUP BY DATE_FORMAT(created_at, '%Y-%m-%d %H:00') ORDER BY bucket_label ASC", nativeQuery = true)
    List<Object[]> findHourlyBuckets(@Param("mac") String mac, @Param("start") LocalDateTime start,
            @Param("end") LocalDateTime end);

    // Daily buckets: bucket_label is DATE(created_at) (java.sql.Date, toString() == "yyyy-MM-dd").
    // Extra columns as documented on findHourlyBuckets above.
    @Query(value = "SELECT DATE(created_at) AS bucket_label, "
            + "COUNT(*) AS cnt, MIN(energy_consumed) AS min_energy, MAX(energy_consumed) AS max_energy, "
            + "AVG(gen_power) AS avg_gen_power, AVG(pv_voltage) AS avg_pv_voltage, "
            + "AVG(output_voltage) AS avg_output_voltage, AVG(output_current) AS avg_output_current "
            + ", MIN(solar_units) AS min_solar_units, MAX(solar_units) AS max_solar_units, "
            + "MIN(grid_units) AS min_grid_units, MAX(grid_units) AS max_grid_units, "
            + "AVG(solar_power) AS avg_solar_power, AVG(output_power) AS avg_output_power, "
            + "AVG(grid_power) AS avg_grid_power, AVG(grid_voltage) AS avg_grid_voltage "
            + "FROM inverter_table WHERE mac_address = :mac AND created_at BETWEEN :start AND :end "
            + "GROUP BY DATE(created_at) ORDER BY bucket_label ASC", nativeQuery = true)
    List<Object[]> findDailyBuckets(@Param("mac") String mac, @Param("start") LocalDateTime start,
            @Param("end") LocalDateTime end);

    // Weekly buckets (ISO week, mode 3): bucket_label is the representative start-of-week date
    // (MIN(DATE(created_at)) within the ISO week) - the service re-aligns this to the Monday of
    // that ISO week so padded and real buckets share the same map key. Extra columns as
    // documented on findHourlyBuckets above.
    @Query(value = "SELECT MIN(DATE(created_at)) AS bucket_label, "
            + "COUNT(*) AS cnt, MIN(energy_consumed) AS min_energy, MAX(energy_consumed) AS max_energy, "
            + "AVG(gen_power) AS avg_gen_power, AVG(pv_voltage) AS avg_pv_voltage, "
            + "AVG(output_voltage) AS avg_output_voltage, AVG(output_current) AS avg_output_current "
            + ", MIN(solar_units) AS min_solar_units, MAX(solar_units) AS max_solar_units, "
            + "MIN(grid_units) AS min_grid_units, MAX(grid_units) AS max_grid_units, "
            + "AVG(solar_power) AS avg_solar_power, AVG(output_power) AS avg_output_power, "
            + "AVG(grid_power) AS avg_grid_power, AVG(grid_voltage) AS avg_grid_voltage "
            + "FROM inverter_table WHERE mac_address = :mac AND created_at BETWEEN :start AND :end "
            + "GROUP BY YEARWEEK(created_at, 3) ORDER BY bucket_label ASC", nativeQuery = true)
    List<Object[]> findWeeklyBuckets(@Param("mac") String mac, @Param("start") LocalDateTime start,
            @Param("end") LocalDateTime end);

    // Monthly buckets: bucket_label is "yyyy-MM". Extra columns as documented on
    // findHourlyBuckets above.
    @Query(value = "SELECT DATE_FORMAT(created_at, '%Y-%m') AS bucket_label, "
            + "COUNT(*) AS cnt, MIN(energy_consumed) AS min_energy, MAX(energy_consumed) AS max_energy, "
            + "AVG(gen_power) AS avg_gen_power, AVG(pv_voltage) AS avg_pv_voltage, "
            + "AVG(output_voltage) AS avg_output_voltage, AVG(output_current) AS avg_output_current "
            + ", MIN(solar_units) AS min_solar_units, MAX(solar_units) AS max_solar_units, "
            + "MIN(grid_units) AS min_grid_units, MAX(grid_units) AS max_grid_units, "
            + "AVG(solar_power) AS avg_solar_power, AVG(output_power) AS avg_output_power, "
            + "AVG(grid_power) AS avg_grid_power, AVG(grid_voltage) AS avg_grid_voltage "
            + "FROM inverter_table WHERE mac_address = :mac AND created_at BETWEEN :start AND :end "
            + "GROUP BY DATE_FORMAT(created_at, '%Y-%m') ORDER BY bucket_label ASC", nativeQuery = true)
    List<Object[]> findMonthlyBuckets(@Param("mac") String mac, @Param("start") LocalDateTime start,
            @Param("end") LocalDateTime end);

    // Yearly buckets (full averages, used for groupBy=year): bucket_label is the calendar year.
    // Extra columns as documented on findHourlyBuckets above.
    @Query(value = "SELECT YEAR(created_at) AS bucket_label, "
            + "COUNT(*) AS cnt, MIN(energy_consumed) AS min_energy, MAX(energy_consumed) AS max_energy, "
            + "AVG(gen_power) AS avg_gen_power, AVG(pv_voltage) AS avg_pv_voltage, "
            + "AVG(output_voltage) AS avg_output_voltage, AVG(output_current) AS avg_output_current "
            + ", MIN(solar_units) AS min_solar_units, MAX(solar_units) AS max_solar_units, "
            + "MIN(grid_units) AS min_grid_units, MAX(grid_units) AS max_grid_units, "
            + "AVG(solar_power) AS avg_solar_power, AVG(output_power) AS avg_output_power, "
            + "AVG(grid_power) AS avg_grid_power, AVG(grid_voltage) AS avg_grid_voltage "
            + "FROM inverter_table WHERE mac_address = :mac AND created_at BETWEEN :start AND :end "
            + "GROUP BY YEAR(created_at) ORDER BY bucket_label ASC", nativeQuery = true)
    List<Object[]> findYearlyBuckets(@Param("mac") String mac, @Param("start") LocalDateTime start,
            @Param("end") LocalDateTime end);

    // Lifetime min/max energy_consumed meter reading for this device (columns: [min, max])
    @Query(value = "SELECT MIN(energy_consumed), MAX(energy_consumed) FROM inverter_table WHERE mac_address = :mac", nativeQuery = true)
    List<Object[]> lifetimeEnergyRange(@Param("mac") String mac);

    // Used for groupBy=total: columns = [year, min_energy, max_energy, count] - only years with
    // actual data are returned, on purpose (total mode is never zero-padded).
    @Query(value = "SELECT YEAR(created_at), MIN(energy_consumed), MAX(energy_consumed), COUNT(*) "
            + "FROM inverter_table WHERE mac_address = :mac GROUP BY YEAR(created_at) ORDER BY YEAR(created_at) ASC", nativeQuery = true)
    List<Object[]> yearlyEnergyDeltas(@Param("mac") String mac);

    // columns: [min(created_at), max(created_at)] - used to know the real calendar range to pad
    // against for groupBy=year when no explicit start/end date is supplied.
    @Query(value = "SELECT MIN(created_at), MAX(created_at) FROM inverter_table WHERE mac_address = :mac", nativeQuery = true)
    List<Object[]> firstAndLastRecordDate(@Param("mac") String mac);

}

package com.rmls.middlelayer.service;

import java.sql.Timestamp;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.rmls.middlelayer.model.Inverter_Table_Model;
import com.rmls.middlelayer.model.InverterStatsBucketDTO;
import com.rmls.middlelayer.repository.Inverter_Repository;
import com.rmls.middlelayer.repository.UserRepository;

@Service
public class Inverter_Service {

    private static final Logger logger = LoggerFactory.getLogger(Inverter_Service.class);

    @Autowired
    Inverter_Repository inverter_Repository;

    @Autowired
    UserRepository userRepository;

    public Boolean saveInverterData(Inverter_Table_Model inverter_Table_Model) {

        logger.info("Inverter_Service-saveInverterData-Called");

        LocalDateTime dateTimeNow = LocalDateTime.now();

        try {

            inverter_Table_Model.setCreatedAt(dateTimeNow);
            inverter_Repository.save(inverter_Table_Model);

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }

        return true;
    }

    // DELETE INVERTER DATA
    public Boolean deleteInverterDataByAdmin(Integer inverterId) {

        logger.info("Inverter_Service-deleteInverterDataByAdmin-Called");
        Inverter_Table_Model inverter_Model = new Inverter_Table_Model();
        Optional<Inverter_Table_Model> inverter = inverter_Repository.findById(inverterId);
        if (inverter.isPresent()) {

            inverter_Model = inverter.get();
            try {
                inverter_Repository.delete(inverter_Model);
            } catch (Exception e) {
                System.out.println("Data Not Deleted");
                return false;
            }
        }
        return true;
    }

    public List<Inverter_Table_Model> getAllInvertersData(boolean isAdmin) {

        logger.info("Inverter_Service-getAllInvertersData-Called");
        List<Inverter_Table_Model> ls = new ArrayList<>();
        List<Inverter_Table_Model> filteredList;

        if (isAdmin) {
            inverter_Repository.findAllByOrderByIdAsc().forEach(ls::add);
        }

        filteredList = ls.stream()
                .filter(inverter -> inverter.getUser() != null)
                .peek(inverter -> inverter.setUser(null))
                .collect(Collectors.toList());

        return filteredList;
    }

    public List<Inverter_Table_Model> findByMACAddress(String macAddress, Boolean perday, Boolean perweek,
            Boolean permonth, Boolean peryear) {

        logger.info("Inverter_Service-findByMACAddress-Called");
        LocalDate currentDate = LocalDate.now();
        logger.info("CurrentDate " + currentDate);

        if (perday) {
            // logger.info("PerDay " + currentDate.minusDays(1).toString());
            return inverter_Repository.findByMacAddressPerDay(macAddress, currentDate.toString());
        } else if (perweek) {
            logger.info("PerWeek " + currentDate.minusWeeks(1).toString());
            return inverter_Repository.findByMacAddressAccordingToStartAndEnd(macAddress, currentDate.toString(),
                    currentDate.minusWeeks(1).toString());
        } else if (permonth) {
            logger.info("PerMonth " + currentDate.minusMonths(1).toString());
            return inverter_Repository.findByMacAddressAccordingToStartAndEnd(macAddress, currentDate.toString(),
                    currentDate.minusMonths(1).toString());
        } else if (peryear) {
            logger.info("PerYear " + currentDate.minusYears(1).toString());
            return inverter_Repository.findByMacAddressAccordingToStartAndEnd(macAddress, currentDate.toString(),
                    currentDate.minusYears(1).toString());
        }

        return inverter_Repository.findByMacAddress(macAddress);

    }

    // ------------------------------------------------------------------
    // Additions below this line support GET /api/inverter/stats and
    // GET /api/inverter/latest. Nothing above this line was modified.
    // ------------------------------------------------------------------

    private static final DateTimeFormatter HOUR_BUCKET_FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:00");
    private static final DateTimeFormatter DAY_BUCKET_FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd");
    private static final DateTimeFormatter MONTH_BUCKET_FMT = DateTimeFormatter.ofPattern("yyyy-MM");

    public Inverter_Table_Model findLatestByMacAddress(String macAddress) {

        logger.info("Inverter_Service-findLatestByMacAddress-Called");
        return inverter_Repository.findFirstByMacAddressOrderByIdDesc(macAddress);
    }

    /**
     * Returns a bucketed, zero-padded time series (or, for groupBy=total, a per-year summary)
     * for a single device's telemetry. energy_consumed is a cumulative lifetime meter reading,
     * so every bucket's energy figure is computed as max(energy_consumed) - min(energy_consumed)
     * within that bucket, never a SUM.
     *
     * Default date ranges (used only when startDate/endDate are both omitted):
     * - hour, day  -> "today" only (LocalDate.now()), since these granularities are meant to be
     * viewed one day at a time by the caller.
     * - week -> the current calendar month, so the caller gets a handful of week buckets back.
     * - month -> the current calendar year, Jan 1 through today (never into the future).
     * - year, total -> the device's full lifetime, from the year of its very first recorded row
     * (via firstAndLastRecordDate) through the current year. Years are never padded/fabricated
     * beyond the current year - that was a real bug in the old frontend and must not reappear here.
     */
    public List<InverterStatsBucketDTO> getStats(String macAddress, String groupBy, String startDate,
            String endDate) {

        logger.info("Inverter_Service-getStats-Called");

        if (groupBy == null || groupBy.isBlank()) {
            throw new IllegalArgumentException("groupBy is required");
        }

        String normalizedGroupBy = groupBy.trim().toLowerCase();

        switch (normalizedGroupBy) {
            case "hour":
            case "day":
            case "week":
            case "month":
                return getTimeSeriesStats(macAddress, normalizedGroupBy, startDate, endDate);
            case "year":
                return getYearStats(macAddress, startDate, endDate);
            case "total":
                return getTotalStats(macAddress);
            default:
                throw new IllegalArgumentException(
                        "Unsupported groupBy value: " + groupBy + ". Expected one of hour, day, week, month, year, total.");
        }
    }

    private List<InverterStatsBucketDTO> getTimeSeriesStats(String macAddress, String groupBy, String startDate,
            String endDate) {

        LocalDate today = LocalDate.now();
        LocalDateTime start;
        LocalDateTime end;

        if (startDate != null && !startDate.isBlank() && endDate != null && !endDate.isBlank()) {
            start = LocalDate.parse(startDate).atStartOfDay();
            end = LocalDate.parse(endDate).atTime(23, 59, 59);
        } else {
            switch (groupBy) {
                case "hour":
                case "day":
                    start = today.atStartOfDay();
                    end = today.atTime(23, 59, 59);
                    break;
                case "week":
                    start = today.withDayOfMonth(1).atStartOfDay();
                    end = today.atTime(23, 59, 59);
                    break;
                case "month":
                    start = today.withDayOfYear(1).atStartOfDay();
                    end = today.atTime(23, 59, 59);
                    break;
                default:
                    throw new IllegalArgumentException("Unsupported groupBy value: " + groupBy);
            }
        }

        if (start.isAfter(end)) {
            throw new IllegalArgumentException("startDate must not be after endDate");
        }

        List<Object[]> rows;
        switch (groupBy) {
            case "hour":
                rows = inverter_Repository.findHourlyBuckets(macAddress, start, end);
                break;
            case "day":
                rows = inverter_Repository.findDailyBuckets(macAddress, start, end);
                break;
            case "week":
                rows = inverter_Repository.findWeeklyBuckets(macAddress, start, end);
                break;
            case "month":
                rows = inverter_Repository.findMonthlyBuckets(macAddress, start, end);
                break;
            default:
                throw new IllegalArgumentException("Unsupported groupBy value: " + groupBy);
        }

        LinkedHashMap<String, InverterStatsBucketDTO> bucketMap = new LinkedHashMap<>();

        // 1) Seed every expected calendar slot with a zero-valued, padded=true placeholder so the
        // series stays continuous even where there is no real data.
        switch (groupBy) {
            case "hour": {
                LocalDateTime cursor = start.withMinute(0).withSecond(0).withNano(0);
                LocalDateTime endHour = end.withMinute(0).withSecond(0).withNano(0);
                while (!cursor.isAfter(endHour)) {
                    String label = cursor.format(HOUR_BUCKET_FMT);
                    bucketMap.put(label, emptyBucket(label, cursor));
                    cursor = cursor.plusHours(1);
                }
                break;
            }
            case "day": {
                LocalDate cursor = start.toLocalDate();
                LocalDate endDay = end.toLocalDate();
                while (!cursor.isAfter(endDay)) {
                    String label = cursor.format(DAY_BUCKET_FMT);
                    bucketMap.put(label, emptyBucket(label, cursor.atStartOfDay()));
                    cursor = cursor.plusDays(1);
                }
                break;
            }
            case "week": {
                LocalDate cursor = start.toLocalDate().with(DayOfWeek.MONDAY);
                LocalDate endWeekStart = end.toLocalDate().with(DayOfWeek.MONDAY);
                while (!cursor.isAfter(endWeekStart)) {
                    String label = cursor.format(DAY_BUCKET_FMT);
                    bucketMap.put(label, emptyBucket(label, cursor.atStartOfDay()));
                    cursor = cursor.plusWeeks(1);
                }
                break;
            }
            case "month": {
                LocalDate cursor = start.toLocalDate().withDayOfMonth(1);
                LocalDate endMonth = end.toLocalDate().withDayOfMonth(1);
                while (!cursor.isAfter(endMonth)) {
                    String label = cursor.format(MONTH_BUCKET_FMT);
                    bucketMap.put(label, emptyBucket(label, cursor.atStartOfDay()));
                    cursor = cursor.plusMonths(1);
                }
                break;
            }
            default:
                break;
        }

        // 2) Overlay real query results on top of the padded placeholders, replacing them.
        for (Object[] row : rows) {
            String label = normalizeBucketLabel(groupBy, row[0]);
            int count = ((Number) row[1]).intValue();
            Double minEnergy = row[2] == null ? null : ((Number) row[2]).doubleValue();
            Double maxEnergy = row[3] == null ? null : ((Number) row[3]).doubleValue();
            double avgGenPower = row[4] == null ? 0.0 : ((Number) row[4]).doubleValue();
            double avgPvVoltage = row[5] == null ? 0.0 : ((Number) row[5]).doubleValue();
            double avgOutputVoltage = row[6] == null ? 0.0 : ((Number) row[6]).doubleValue();
            double avgOutputCurrent = row[7] == null ? 0.0 : ((Number) row[7]).doubleValue();
            double energyDelta = (minEnergy == null || maxEnergy == null) ? 0.0
                    : Math.max(0, maxEnergy - minEnergy);

            InverterStatsBucketDTO existing = bucketMap.get(label);
            String bucketStart = existing != null ? existing.getBucketStart() : label;

            bucketMap.put(label, new InverterStatsBucketDTO(label, bucketStart, count, energyDelta, avgGenPower,
                    avgPvVoltage, avgOutputVoltage, avgOutputCurrent, false));
        }

        return new ArrayList<>(bucketMap.values());
    }

    // Converts the raw first column of a bucketing query row into the same String key used by
    // the calendar padding pass above, so real rows correctly overlay (rather than duplicate)
    // their padded placeholder.
    private String normalizeBucketLabel(String groupBy, Object raw) {

        if ("week".equals(groupBy)) {
            // raw is the representative MIN(DATE(created_at)) for the ISO week - realign it to
            // the Monday of that same ISO week so it matches the padding pass's map key.
            LocalDate repDate = LocalDate.parse(raw.toString());
            return repDate.with(DayOfWeek.MONDAY).format(DAY_BUCKET_FMT);
        }

        return raw.toString();
    }

    private InverterStatsBucketDTO emptyBucket(String label, LocalDateTime bucketStart) {
        return new InverterStatsBucketDTO(label, bucketStart.toString(), 0, 0.0, 0.0, 0.0, 0.0, 0.0, true);
    }

    private List<InverterStatsBucketDTO> getYearStats(String macAddress, String startDate, String endDate) {

        int currentYear = LocalDate.now().getYear();
        int startYear;
        int endYear;

        if (startDate != null && !startDate.isBlank()) {
            startYear = LocalDate.parse(startDate).getYear();
        } else {
            List<Object[]> range = inverter_Repository.firstAndLastRecordDate(macAddress);
            if (!range.isEmpty() && range.get(0)[0] != null) {
                startYear = ((Timestamp) range.get(0)[0]).toLocalDateTime().getYear();
            } else {
                startYear = currentYear;
            }
        }

        endYear = (endDate != null && !endDate.isBlank()) ? LocalDate.parse(endDate).getYear() : currentYear;

        // Never fabricate future years.
        if (endYear > currentYear) {
            endYear = currentYear;
        }
        if (startYear > endYear) {
            startYear = endYear;
        }

        LocalDateTime queryStart = LocalDate.of(startYear, 1, 1).atStartOfDay();
        LocalDateTime queryEnd = LocalDate.of(endYear, 12, 31).atTime(23, 59, 59);

        List<Object[]> rows = inverter_Repository.findYearlyBuckets(macAddress, queryStart, queryEnd);

        LinkedHashMap<String, InverterStatsBucketDTO> bucketMap = new LinkedHashMap<>();
        for (int y = startYear; y <= endYear; y++) {
            String label = String.valueOf(y);
            bucketMap.put(label, emptyBucket(label, LocalDate.of(y, 1, 1).atStartOfDay()));
        }

        for (Object[] row : rows) {
            int year = ((Number) row[0]).intValue();
            String label = String.valueOf(year);
            int count = ((Number) row[1]).intValue();
            Double minEnergy = row[2] == null ? null : ((Number) row[2]).doubleValue();
            Double maxEnergy = row[3] == null ? null : ((Number) row[3]).doubleValue();
            double avgGenPower = row[4] == null ? 0.0 : ((Number) row[4]).doubleValue();
            double avgPvVoltage = row[5] == null ? 0.0 : ((Number) row[5]).doubleValue();
            double avgOutputVoltage = row[6] == null ? 0.0 : ((Number) row[6]).doubleValue();
            double avgOutputCurrent = row[7] == null ? 0.0 : ((Number) row[7]).doubleValue();
            double energyDelta = (minEnergy == null || maxEnergy == null) ? 0.0
                    : Math.max(0, maxEnergy - minEnergy);

            bucketMap.put(label, new InverterStatsBucketDTO(label, LocalDate.of(year, 1, 1).atStartOfDay().toString(),
                    count, energyDelta, avgGenPower, avgPvVoltage, avgOutputVoltage, avgOutputCurrent, false));
        }

        return new ArrayList<>(bucketMap.values());
    }

    // groupBy=total: one bucket per year that actually has data. avg* fields are not meaningful
    // for a whole-year total-mode bucket (only min/max energy are used), so they are left at 0.
    // Deliberately NOT zero-padded: a year with zero rows should simply not appear.
    private List<InverterStatsBucketDTO> getTotalStats(String macAddress) {

        List<Object[]> rows = inverter_Repository.yearlyEnergyDeltas(macAddress);
        List<InverterStatsBucketDTO> result = new ArrayList<>();

        for (Object[] row : rows) {
            int year = ((Number) row[0]).intValue();
            Double minEnergy = row[1] == null ? null : ((Number) row[1]).doubleValue();
            Double maxEnergy = row[2] == null ? null : ((Number) row[2]).doubleValue();
            int count = ((Number) row[3]).intValue();
            double energyDelta = (minEnergy == null || maxEnergy == null) ? 0.0
                    : Math.max(0, maxEnergy - minEnergy);
            String label = String.valueOf(year);

            result.add(new InverterStatsBucketDTO(label, LocalDate.of(year, 1, 1).atStartOfDay().toString(), count,
                    energyDelta, 0.0, 0.0, 0.0, 0.0, false));
        }

        return result;
    }

}

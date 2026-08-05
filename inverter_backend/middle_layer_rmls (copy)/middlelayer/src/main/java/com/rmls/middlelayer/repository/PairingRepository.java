package com.rmls.middlelayer.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.rmls.middlelayer.model.PairingDeviceModel;

@Repository
public interface PairingRepository extends JpaRepository<PairingDeviceModel, Integer> {
    
    @Query(value = "SELECT * FROM pairing_devices_table where user_id IN (:userId);", nativeQuery = true)
    List<PairingDeviceModel> findAgainstUserID(@Param("userId") Long userId);

    @Query(value = "SELECT * FROM pairing_devices_table WHERE mac_address = :device_id", nativeQuery = true)
    List<PairingDeviceModel> findByDeviceID(@Param("device_id") String device_id);

}

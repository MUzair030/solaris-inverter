package com.rmls.middlelayer.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.rmls.middlelayer.model.User_Devices_Model;

@Repository
public interface User_Devices_Repository extends JpaRepository<User_Devices_Model, Integer> {

    @Query(value = "SELECT * FROM user_devices_table where mac_address = :mac_address limit 1;", nativeQuery = true)
    Optional<User_Devices_Model> findAgainstMACAddress(@Param("mac_address") String mac_address);

    @Query(value = "SELECT * FROM user_devices_table where user_id IN (:userId);", nativeQuery = true)
    List<User_Devices_Model> findAgainstUserID(@Param("userId") Long userId);
    
    @Query(value = "SELECT * FROM user_devices_table where id = :id", nativeQuery = true)
    Optional<User_Devices_Model> findByDeviceId(@Param("id") Integer id);
}

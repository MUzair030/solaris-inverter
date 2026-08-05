package com.rmls.middlelayer.repository;

import java.time.LocalDateTime;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.rmls.middlelayer.model.TempUser_Model;

import jakarta.transaction.Transactional;

public interface TempUser_Repository extends JpaRepository<TempUser_Model, Integer> {

    @Query(value = "SELECT * FROM temp_user_table WHERE email = :email order by id desc limit 1", nativeQuery = true)
    Optional<TempUser_Model> findByEmailTempUser(@Param("email") String email);

    @Modifying
    @Transactional
    @Query("DELETE FROM TempUser_Model t WHERE t.createdAt < :threshold")
    void deleteOtpsOlderThan(@Param("threshold") LocalDateTime threshold);
}

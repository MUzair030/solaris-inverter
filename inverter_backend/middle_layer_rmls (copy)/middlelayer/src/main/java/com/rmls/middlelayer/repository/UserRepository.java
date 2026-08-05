package com.rmls.middlelayer.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.rmls.middlelayer.model.User;

import jakarta.transaction.Transactional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    @Query(value = "SELECT * FROM users WHERE phone = :phone", nativeQuery = true)
    Optional<User> findByPhone(@Param("phone") Long phone);

    @Query(value = "SELECT * FROM users WHERE email = :email", nativeQuery = true)
    Optional<User> findByEmail(@Param("email") String email);

    Optional<User> findByUsername(String username);

    Boolean existsByUsername(String username);

    Boolean existsByEmail(String email);

    List<User> findAllByOrderByIdDesc();

    @Query(value = "SELECT * FROM users WHERE mac_address = :mac_address", nativeQuery = true)
    Optional<User> findByMacAddress(@Param("mac_address") String mac_address);

    @Transactional
    @Modifying
    @Query(value = "UPDATE users set password = :password where id = :userId", nativeQuery = true)
    void changeUserPassword(@Param("password") String password, @Param("userId") Long userId);

}

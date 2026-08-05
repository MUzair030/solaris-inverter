package com.rmls.middlelayer.configuration;

import java.security.Key;
import java.util.Date;
import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Component;

import com.rmls.middlelayer.model.User;
import com.rmls.middlelayer.repository.UserRepository;
import com.rmls.middlelayer.service.UserDetailsImpl;

import io.jsonwebtoken.*;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;

@Component
public class JwtUtils {
    private static final Logger logger = LoggerFactory.getLogger(JwtUtils.class);

    @Value("${jwt.secret}")
    private String jwtSecret;

    @Value("${jwt.expirationDateInMs}")
    private Long jwtExpirationMs;

    @Autowired
    UserRepository userRepository;

    public String generateJwtToken(Authentication authentication) {

        UserDetailsImpl userPrincipal = (UserDetailsImpl) authentication.getPrincipal();

        return Jwts.builder()
                .setSubject((userPrincipal.getUsername()))
                .setIssuedAt(new Date())
                .setExpiration(new Date((new Date()).getTime() + jwtExpirationMs))
                .signWith(key(), SignatureAlgorithm.HS256)
                .compact();
    }

    public String generateJwtToken(String emailAddress) {

        return Jwts.builder()
                .setSubject((emailAddress))
                .setIssuedAt(new Date())
                .setExpiration(new Date((new Date()).getTime() + jwtExpirationMs))
                .signWith(key(), SignatureAlgorithm.HS256)
                .compact();
    }

    private Key key() {
        return Keys.hmacShaKeyFor(Decoders.BASE64.decode(jwtSecret));
    }

    public User getUserDetailsFromJwtToken(String authToken) {
        try {
            User userPresent = new User();
            Claims claims = Jwts.parserBuilder().setSigningKey(key()).build().parseClaimsJws(authToken).getBody();
            String email = claims.getSubject();
            // System.out.println("EmailAddress: " + email);

            Optional<User> user = null;

            if (email.contains(".com") || email.contains(".ae") || email.contains("@")) {
                user = userRepository.findByEmail(email);
            
                if (user.isPresent()) {
                    userPresent = user.get();
                    return userPresent;
                }
                
            } 
                
            return new User();
            
        } catch (Exception e) {
            e.printStackTrace();
            return new User();
        }
    }

    public String getEmailFromJwtToken(String authToken) {
        return Jwts.parserBuilder().setSigningKey(key()).build()
                .parseClaimsJws(authToken).getBody().getSubject();
    }

    // public UserDetails getUserDetailsFromJwtToken(String token) {
    //     try {
    //         Claims claims = Jwts.parserBuilder().setSigningKey(key()).build().parseClaimsJws(token).getBody();
    //         String username = claims.getSubject();
    //         // Log the username
    //         System.out.println("Username: " + username);
    //         UserDetails userDetails = new CustomUserDetails(username);
    //         return userDetails;
    //     } catch (Exception e) {
    //         e.printStackTrace();
    //         return null; 
    //     }
    // }

    public String getUserNameFromJwtToken(String token) {
        return Jwts.parserBuilder().setSigningKey(key()).build()
                .parseClaimsJws(token).getBody().getSubject();
    }

    public boolean validateJwtToken(String authToken) {
        try {
            Jwts.parserBuilder().setSigningKey(key()).build().parse(authToken);
            return true;
        } catch (MalformedJwtException e) {
            logger.error("Invalid JWT token: {}", e.getMessage());
        } catch (ExpiredJwtException e) {
            logger.error("JWT token is expired: {}", e.getMessage());
        } catch (UnsupportedJwtException e) {
            logger.error("JWT token is unsupported: {}", e.getMessage());
        } catch (IllegalArgumentException e) {
            logger.error("JWT claims string is empty: {}", e.getMessage());
        }

        return false;
    }

}

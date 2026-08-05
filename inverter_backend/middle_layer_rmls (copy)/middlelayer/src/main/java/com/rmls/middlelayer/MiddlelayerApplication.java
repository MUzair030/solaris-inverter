package com.rmls.middlelayer;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.web.client.RestTemplate;

@SpringBootApplication
@EnableScheduling
public class MiddlelayerApplication {

	//--------------------------------------
	// 3Pol BLI Backend Developed By AymanSk
	//--------------------------------------

	public static void main(String[] args) {
		SpringApplication.run(MiddlelayerApplication.class, args);

	}

	@Bean
	public RestTemplate getRestTemplate() {
		return new RestTemplate();
	}

}

package com.example.demo;

import java.util.Random;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;

@SpringBootApplication
@EnableScheduling
public class DemoApplication {

    private static final Logger logger = LoggerFactory.getLogger(DemoApplication.class);
    private static final Random random = new Random();

    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
    }

    @Scheduled(fixedRate = 5000)
    public void logMessages() {
        int logType = random.nextInt(3);
        switch (logType) {
            case 0:
                logger.info("[INFO] : This is an INFO message");
                break;
            case 1:
                logger.debug("[DEBUG]: This is a DEBUG message");
                break;
            case 2:
                logger.error("[ERROR]: This is an ERROR message");
                break;
        }
    }
}

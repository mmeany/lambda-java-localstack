package com.example.lambda;

import lombok.extern.slf4j.Slf4j;

/**
 * Processor class that handles the business logic for JSON processing.
 */
@Slf4j
public class Processor {

    /**
     * Processes the provided JSON string.
     * 
     * @param jsonInput The JSON string to process
     * @return A result string indicating successful processing
     */
    public String process(String jsonInput) {
        log.info("Processing JSON input: {}", jsonInput);
        return "JSON processed successfully";
    }
}

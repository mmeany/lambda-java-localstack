package com.example.lambda;

import java.time.Instant;

import com.amazonaws.services.lambda.runtime.RequestHandler;

import lombok.extern.slf4j.Slf4j;

/**
 * AWS Lambda handler that processes JSON input.
 */
@Slf4j
public class LambdaHandler implements RequestHandler<LambdaHandler.Input, String> {

    private final Processor processor;

    public record Input(String greeting, Instant timestamp) {
    }

    public LambdaHandler() {
        this.processor = new Processor();
    }

    @Override
    public String handleRequest(LambdaHandler.Input input, com.amazonaws.services.lambda.runtime.Context context) {
        String inputString = input.greeting();
        log.info("Received input: {}", input);
        context.getLogger().log("Received input: " + input.toString());

        try {

            // Process the JSON
            String result = processor.process(inputString);

            log.info("Processing completed successfully: {}", result);
            return result;

        } catch (Exception e) {
            log.error("Error processing input: {}", inputString, e);
            throw new RuntimeException("Failed to process input", e);
        }
    }
}

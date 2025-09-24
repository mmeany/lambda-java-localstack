package com.example.lambda;

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

/**
 * Unit tests for Processor.
 */
class ProcessorTest {

    private Processor processor;

    @BeforeEach
    void setUp() {
        processor = new Processor();
    }

    @Test
    void testProcess_ValidJson_ReturnsSuccessMessage() {
        // Given
        String validJson = "{\"message\": \"Hello World\", \"value\": 123}";

        // When
        String result = processor.process(validJson);

        // Then
        assertEquals("JSON processed successfully", result);
    }
}

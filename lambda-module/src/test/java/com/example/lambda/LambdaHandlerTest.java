package com.example.lambda;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

import java.time.Instant;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.amazonaws.services.lambda.runtime.LambdaLogger;
import com.example.lambda.LambdaHandler;

/**
 * Unit tests for LambdaHandler.
 */
@ExtendWith(MockitoExtension.class)
class LambdaHandlerTest {

    private LambdaHandler lambdaHandler;

    @Mock
    private com.amazonaws.services.lambda.runtime.Context context;

    @Mock
    private LambdaLogger logger;

    @BeforeEach
    void setUp() {
        lambdaHandler = new LambdaHandler();

        // Mock the logger
        when(context.getLogger()).thenReturn(logger);
        doNothing().when(logger).log(anyString());
    }

    @Test
    void testHandleRequest_ValidInput_ReturnsSuccessMessage() {
        // Given
        LambdaHandler.Input input = new LambdaHandler.Input("Hello World", Instant.now());

        // When
        String result = lambdaHandler.handleRequest(input, context);

        // Then
        assertEquals("JSON processed successfully", result);
    }

    @Test
    void testHandleRequest_ValidInput_DoesNotThrowException() {
        // Given
        LambdaHandler.Input input = new LambdaHandler.Input("Test message", Instant.now());

        // When & Then - Should work fine with valid Input
        assertDoesNotThrow(() -> {
            lambdaHandler.handleRequest(input, context);
        });
    }

    @Test
    void testHandleRequest_EmptyInput_ReturnsSuccessMessage() {
        // Given
        LambdaHandler.Input input = new LambdaHandler.Input("", Instant.now());

        // When
        String result = lambdaHandler.handleRequest(input, context);

        // Then
        assertEquals("JSON processed successfully", result);
    }

    @Test
    void testHandleRequest_ComplexInput_ReturnsSuccessMessage() {
        // Given
        String complexMessage = """
                {
                    "user": {
                        "id": 1,
                        "name": "John Doe",
                        "email": "john@example.com"
                    },
                    "items": [
                        {"id": 1, "name": "Item 1"},
                        {"id": 2, "name": "Item 2"}
                    ]
                }
                """;
        LambdaHandler.Input input = new LambdaHandler.Input(complexMessage, Instant.now());

        // When
        String result = lambdaHandler.handleRequest(input, context);

        // Then
        assertEquals("JSON processed successfully", result);
    }
}

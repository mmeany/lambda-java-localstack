package com.example.lambda;

import com.amazonaws.services.lambda.runtime.RequestHandler;
import lombok.extern.slf4j.Slf4j;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.CreateBucketRequest;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;
import software.amazon.awssdk.services.s3.model.S3Exception;

import java.nio.charset.StandardCharsets;
import java.time.Instant;

/**
 * AWS Lambda handler that processes JSON input.
 * See: <a href="https://docs.aws.amazon.com/lambda/latest/dg/java-handler.html">AWS Guide</a>
 */
@Slf4j
public class LambdaHandler implements RequestHandler<LambdaHandler.Input, String> {

    private static final boolean FORCE_PATH_STYLE = "true".equalsIgnoreCase(System.getenv("FORCE_PATH_STYLE"));
    private static final S3Client S3_CLIENT = S3Client.builder().forcePathStyle(FORCE_PATH_STYLE).build();

    public record Input(String greeting, Instant timestamp) {
    }

    @Override
    public String handleRequest(LambdaHandler.Input input, com.amazonaws.services.lambda.runtime.Context context) {
        log.info("Received input: {}", input);
        String bucketName = System.getenv("BUCKET");
        String key = "receipt/" + input.timestamp.toString() + ".txt";

        try {
            log.info("Using S3 client with path style access: {}", FORCE_PATH_STYLE);
            log.info("Listing buckets...");
            listBuckets();
            log.info("Creating bucket '{}'...", bucketName);
            createBucketIfNotExists(bucketName);
            log.info("Listing buckets...");
            listBuckets();
            log.info("Uploading message to S3 bucket '{}' with key '{}'", bucketName, key);
            uploadMessageToS3(bucketName, key, input.greeting);
            log.info("Reading message from S3 bucket '{}' with key '{}'", bucketName, key);
            String messageContent = getMessageFromS3(bucketName, key);
            log.info("Message from S3: {}", messageContent);
            return "Greeting saved to S3";

        } catch (Exception e) {
            throw new RuntimeException("Failed to process input", e);
        }
    }

    private void uploadMessageToS3(String bucketName, String key, String messageContent) {
        try {
            PutObjectRequest putObjectRequest = PutObjectRequest.builder()
                    .bucket(bucketName)
                    .key(key)
                    .build();

            // Convert the receipt content to bytes and upload to S3
            S3_CLIENT.putObject(putObjectRequest, RequestBody.fromBytes(messageContent.getBytes(StandardCharsets.UTF_8)));
        } catch (S3Exception e) {
            throw new RuntimeException("Failed to upload message to S3: " + e.awsErrorDetails().errorMessage(), e);
        }
    }

    private String getMessageFromS3(String bucketName, String key) {
        try {
            return new String(
                    S3_CLIENT.getObject(req -> req.bucket(bucketName).key(key))
                            .readAllBytes(),
                    StandardCharsets.UTF_8
            );
        } catch (S3Exception e) {
            throw new RuntimeException("Failed to get message from S3: " + e.awsErrorDetails().errorMessage(), e);
        } catch (Exception e) {
            throw new RuntimeException("Failed to process S3 response", e);
        }
    }

    private void createBucketIfNotExists(String bucketName) {
        if (!S3_CLIENT.listBuckets().buckets().stream().anyMatch(b -> b.name().equals(bucketName))) {
            S3_CLIENT.createBucket(CreateBucketRequest.builder().bucket(bucketName).build());
        }
    }

    private void listBuckets() {
        S3_CLIENT.listBuckets().buckets().forEach(b -> log.info("Bucket: {}", b.name()));
    }
}

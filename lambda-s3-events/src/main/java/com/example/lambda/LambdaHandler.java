package com.example.lambda;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.models.s3.S3EventNotification;
import lombok.extern.slf4j.Slf4j;

import java.util.ArrayList;
import java.util.List;

/**
 * AWS Lambda handler that processes S3 event notifications and returns a short description.
 */
@Slf4j
public class LambdaHandler implements RequestHandler<S3EventNotification, List<String>> {

    private final String bucket = System.getenv("BUCKET");

    public LambdaHandler() {
        log.info("------------------------ Environment Variables -----------------------");
        System.getenv().forEach((key, value) -> log.info("Environment variable - {}: {}", key, value));
        log.info("----------------------------------------------------------------------");
    }

    @Override
    public List<String> handleRequest(S3EventNotification event, Context context) {

        if (event == null || event.getRecords() == null || event.getRecords().isEmpty()) {
            log.info("Skipping empty or null S3 event");
            return List.of();
        }

        log.info("Received S3 event '{}' containing '{}' records", event, event.getRecords().size());

        List<String> processedEvents = new ArrayList<>();
        for (S3EventNotification.S3EventNotificationRecord record : event.getRecords()) {
            log.info("Record: {}", record);
            if (record != null && record.getS3() != null && bucket.equals(record.getS3().getBucket().getName()) && (
                    "ObjectCreated:Put".equals(record.getEventName()) ||
                            "ObjectCreated:Post".equals(record.getEventName()) ||
                            "ObjectCreated:Copy".equals(record.getEventName()) ||
                            "ObjectCreated:CompleteMultipartUpload".equals(record.getEventName())
            )) {
                String message = getMessage(record);
                log.info(message);
                processedEvents.add(message);
            } else {
                log.info("Ignoring S3 put for some other bucket");
            }
        }

        return processedEvents;
    }

    private static String getMessage(S3EventNotification.S3EventNotificationRecord record) {
        String eventName = record.getEventName();
        String bucket = record.getS3().getBucket().getName();
        String key = record.getS3().getObject().getKey();
        String eTag = record.getS3().getObject().geteTag();
        Long size = record.getS3().getObject().getSizeAsLong();
        String awsRegion = record.getAwsRegion();

        return String.format(
                "S3 Event: %s in %s, bucket=%s, key=%s, size=%s, eTag=%s",
                eventName, awsRegion, bucket, key, size != null ? size : "unknown", eTag != null ? eTag : "n/a"
        );
    }
}

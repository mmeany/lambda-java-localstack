# Lambda S3 Events

This is a sample Lambda function that processes S3 events.

## S3 Configuration

```json
{
  "LambdaFunctionConfigurations": [
    {
      "Id": "s3eventtriggerslambda",
      "LambdaFunctionArn": "arn:aws:lambda:ap-northeast-2:000000000000:function:my-lambda",
      "Events": [
        "s3:ObjectCreated:*"
      ]
    }
  ]
}
```
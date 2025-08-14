/**
 * Salesforce Apex Sentry Client
 * Copyright (c) 2025 Dave Otis
 * MIT License
 *
 * GitHub: https://github.com/otisdave/salesforce-apex-sentry-client
 * Medium post: https://medium.com/p/f5c53a9b60da
 *
 * This code is a representation of the concepts described in the Medium article above.
 */

 /**
  * SentryHttpClient: Utility for sending error/event data to Sentry via HTTP with configurable timeout and authentication.
  */
public class SentryHttpClient {
    private static final Integer SENTRY_VERSION = 7;
    private static final String SENTRY_CLIENT = 'salesforce-apex/64.0';
    private static final Integer DEFAULT_TIMEOUT_MS = 10000;

    /**
     * Sends a JSON payload to the Sentry endpoint using the provided configuration.
     *
     * @param payloadJson The JSON string to be sent to Sentry.
     * @param config The Sentry configuration metadata containing endpoint and authentication details.
     * @return HttpResponse The response received from the Sentry API.
     */
    public static HttpResponse sendToSentry(String payloadJson, Sentry_Config__mdt config) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(config.Endpoint__c);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('X-Sentry-Auth', buildAuthHeader(config.Public_Key__c));
        req.setBody(payloadJson);
        req.setTimeout(getTimeoutMilliseconds(config));

        Http http = new Http();
        return http.send(req);
    }

    /**
     * Builds the Sentry authentication header string required for API requests.
     *
     * @param publicKey The public key used for Sentry authentication.
     * @return A formatted authentication header string for Sentry.
     */
    private static String buildAuthHeader(String publicKey) {
        return 'Sentry sentry_version=' + SENTRY_VERSION + 
               ',sentry_key=' + publicKey + 
               ',sentry_client=' + SENTRY_CLIENT;
    }

    /**
     * Returns the timeout value in milliseconds based on the provided Sentry configuration.
     *
     * If the Timeout_Seconds__c field in the config is null, the default timeout value (DEFAULT_TIMEOUT_MS) is returned.
     * Otherwise, the timeout is calculated by converting the Timeout_Seconds__c value from seconds to milliseconds.
     *
     * @param config The Sentry configuration metadata object containing the timeout setting.
     * @return The timeout value in milliseconds.
     */
    private static Integer getTimeoutMilliseconds(Sentry_Config__mdt config) {
        return config.Timeout_Seconds__c == null
            ? DEFAULT_TIMEOUT_MS
            : Integer.valueOf(config.Timeout_Seconds__c * 1000);
    }
}
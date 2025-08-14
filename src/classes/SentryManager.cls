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
  * SentryManager captures exceptions and sends them to Sentry for error tracking.
  */
public class SentryManager {
    private static final String CONFIG_NAME = 'Default';
    private Sentry_Config__mdt config;

    public SentryManager(Sentry_Config__mdt config) {
        this.config = config;
    }

    public SentryManager() {
        this.config = Sentry_Config__mdt.getInstance(CONFIG_NAME);
    }


    public static Boolean captureException(Exception ex) {
        return new SentryManager().captureExceptionInternal(ex, null);
    }

    public static Boolean captureException(Exception ex, Map<String, Object> additionalData) {
        return new SentryManager().captureExceptionInternal(ex, additionalData);
    }

    /**
     * Captures an exception and sends it to Sentry if the configuration is valid.
     *
     * @param ex The exception to capture and report.
     * @param additionalData A map of additional data to include in the Sentry payload.
     * @return true if the exception was successfully sent to Sentry; false otherwise.
     */
    public Boolean captureExceptionInternal(Exception ex, Map<String, Object> additionalData) {
        if (!SentryConfigValidator.isValidForCapture(config)) {
            System.debug('Sentry not configured or inactive');
            return false;
        }

        try {
            Map<String, Object> sentryPayload = SentryExceptionFormatter.formatForSentry(ex, additionalData, config);
            sendToSentryAsync(JSON.serialize(sentryPayload));
            return true;
        } catch (Exception e) {
            System.debug('Error in SentryManager: ' + e.getMessage());
            return false;
        }
    }

    /**
     * Sends a payload to Sentry asynchronously using a future callout.
     *
     * This method retrieves the Sentry configuration, validates it, and then attempts to send
     * the provided JSON payload to Sentry using an HTTP client. The result of the callout is logged.
     * If the configuration is invalid, the method aborts without sending.
     * Any exceptions during the process are caught and logged.
     *
     * @param payloadJson The JSON string payload to send to Sentry.
     */
    @future(callout=true)
    public static void sendToSentryAsync(String payloadJson) {
        System.debug('SENTRY ASYNC CALL STARTED');
        
        Sentry_Config__mdt config = Sentry_Config__mdt.getInstance(CONFIG_NAME);
        if (!SentryConfigValidator.isValidForSending(config)) {
            System.debug('SENTRY CONFIG INVALID - ABORTING');
            return;
        }

        try {
            HttpResponse res = SentryHttpClient.sendToSentry(payloadJson, config);

            if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
                System.debug('✅ SENTRY SUCCESS: ' + res.getStatusCode());
            } else {
                System.debug('❌ SENTRY ERROR: ' + res.getStatusCode() + ' - ' + res.getBody());
            }
        } catch (Exception e) {
            System.debug('❌ SENTRY EXCEPTION: ' + e.getMessage());
        }
    }
}
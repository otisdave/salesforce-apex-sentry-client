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
 * Validates Sentry configuration metadata.
 */
public class SentryConfigValidator {

    /**
     * Checks if the provided Sentry configuration is valid for capturing events.
     *
     * @param config The Sentry_Config__mdt configuration object to validate.
     * @return Boolean True if the configuration is valid for capturing; otherwise, false.
     */
    public static Boolean isValidForCapture(Sentry_Config__mdt config) {
        return config != null && config.Active__c;
    }

    /**
     * Validates whether the provided Sentry configuration is suitable for sending data.
     *
     * @param config The Sentry_Config__mdt configuration object to validate.
     * @return Boolean True if the configuration is valid for sending; otherwise, false.
     */
    public static Boolean isValidForSending(Sentry_Config__mdt config) {
        return config != null 
            && config.Active__c 
            && String.isNotBlank(config.Endpoint__c) 
            && String.isNotBlank(config.Public_Key__c);
    }
}
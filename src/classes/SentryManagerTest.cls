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
 * Test class for SentryManager to validate error tracking functionality.
 */
@IsTest
public class SentryManagerTest {
    /**
     * Creates and returns a test instance of Sentry_Config__mdt with preset values.
     *
     * @param active Indicates whether the configuration should be active.
     * @return Sentry_Config__mdt A test configuration object with default values set for unit testing.
     */
    private static Sentry_Config__mdt getTestConfig(Boolean active) {
        Sentry_Config__mdt config = new Sentry_Config__mdt();

        config.MasterLabel = 'Default';
        config.Endpoint__c = 'https://example.com/api/test';
        config.Public_Key__c = 'testkey';
        config.Active__c = active;
        config.Environment__c = 'UnitTest';
        config.Timeout_Seconds__c = 5;
        
        return config;
    }

    /**
     * @description
     * Unit test for SentryManager.captureExceptionInternal method when the Sentry configuration is active.
     * Verifies that the method returns true when the configuration is active.
     *
     * Steps:
     * - Creates a test DML exception.
     * - Retrieves a test Sentry configuration with active status.
     * - Instantiates SentryManager with the active config.
     * - Calls captureExceptionInternal with the exception.
     * - Asserts that the result is true, indicating the exception is captured successfully.
     */
    @IsTest
    static void testCaptureException_activeConfig() {
        Exception ex = new DmlException('Test DML Exception');
        Sentry_Config__mdt config = getTestConfig(true);

        SentryManager manager = new SentryManager(config);
        Boolean result = manager.captureExceptionInternal(ex, null);

        System.assert(result, 'Should return true when config is active');
    }

    /**
     * @description
     * Unit test for SentryManager.captureExceptionInternal method when the Sentry configuration is inactive.
     * Verifies that the method returns false if the configuration is not active.
     *
     * Steps:
     * - Creates a test DML exception.
     * - Retrieves a test Sentry configuration with inactive status.
     * - Instantiates SentryManager with the inactive config.
     * - Calls captureExceptionInternal with the exception.
     * - Asserts that the result is false, indicating no exception is captured when config is inactive.
     */
    @IsTest
    static void testCaptureException_inactiveConfig() {
        Exception ex = new DmlException('Test DML Exception');
        Sentry_Config__mdt config = getTestConfig(false);

        SentryManager manager = new SentryManager(config);
        Boolean result = manager.captureExceptionInternal(ex, null);

        System.assertEquals(false, result, 'Should return false when config is inactive');
    }
}
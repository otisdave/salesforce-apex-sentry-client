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
 * Formats exceptions and related data for Sentry error reporting.
 */
public class SentryExceptionFormatter {
    
    /**
     * Formats an exception and related data into a payload suitable for Sentry error reporting.
     *
     * @param ex The Exception to be formatted.
     * @param additionalData A map of additional data to include in the payload.
     * @param config The Sentry configuration metadata.
     * @return A map representing the formatted payload for Sentry.
     */
    public static Map<String, Object> formatForSentry(Exception ex, Map<String, Object> additionalData, Sentry_Config__mdt config) {
        Map<String, Object> payload = buildBasePayload(ex);

        addUserInfo(payload);
        addTags(payload, ex, config);
        addExtraData(payload, ex, additionalData);
        
        return payload;
    }

    /**
     * Builds the base payload for Sentry error reporting.
     *
     * @param ex The exception to format.
     * @return A map containing the formatted error message, timestamp in GMT, error level, and platform.
     */
    private static Map<String, Object> buildBasePayload(Exception ex) {
        return new Map<String, Object>{
            'message' => ex.getTypeName() + ': ' + ex.getMessage(),
            'timestamp' => System.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'GMT'),
            'level' => 'error',
            'platform' => 'apex'
        };
    }

    /**
     * Adds the current Salesforce user's information to the provided payload map.
     *
     * The user information includes:
     * - id: The user's Salesforce ID.
     * - username: The user's username.
     * - email: The user's email address.
     *
     * @param payload The map to which user information will be added under the 'user' key.
     */
    private static void addUserInfo(Map<String, Object> payload) {
        payload.put('user', new Map<String, Object>{
            'id' => UserInfo.getUserId(),
            'username' => UserInfo.getUserName(),
            'email' => UserInfo.getUserEmail()
        });
    }
    
    /**
     * Adds contextual tags to the provided payload for Sentry exception reporting.
     *
     * Tags include organization ID, user profile ID, exception type, and environment.
     * The environment tag is set from the Sentry configuration if available; otherwise,
     * it defaults to the organization name.
     *
     * @param payload The map to which tags will be added.
     * @param ex The exception to extract type information from.
     * @param config The Sentry configuration metadata, used to determine the environment.
     */
    private static void addTags(Map<String, Object> payload, Exception ex, Sentry_Config__mdt config) {
        Map<String, Object> tags = new Map<String, Object>{
            'org_id' => UserInfo.getOrganizationId(),
            'user_profile' => UserInfo.getProfileId(),
            'exception_type' => ex.getTypeName()
        };

        if (config != null && String.isNotBlank(config.Environment__c)) {
            tags.put('environment', config.Environment__c);
        } else {
            tags.put('environment', UserInfo.getOrganizationName());
        }

        payload.put('tags', tags);
    }

    
    /**
     * Adds extra data to the provided payload map, including the exception's stack trace and any additional data.
     *
     * @param payload         The map to which extra data will be added.
     * @param ex              The exception whose stack trace will be included.
     * @param additionalData  Optional map containing additional data to be included.
     */
    private static void addExtraData(Map<String, Object> payload, Exception ex, Map<String, Object> additionalData) {
        Map<String, Object> extra = new Map<String, Object>();
        
        String stackTrace = ex.getStackTraceString();
        extra.put('stack_trace', String.isNotBlank(stackTrace) ? stackTrace : 'No stack trace available');
        
        if (additionalData != null) {
            extra.put('additional_data', additionalData);
        }
        
        payload.put('extra', extra);
    }

    /**
     * Formats the subject line for an exception by including the exception type and an abbreviated message.
     *
     * @param ex The Exception to format.
     * @return A string in the format 'Error: [ExceptionType] AbbreviatedMessage', where the message is limited to 80 characters.
     */
    public static String formatSubject(Exception ex) {
        return 'Error: [' + ex.getTypeName() + '] ' + ex.getMessage().abbreviate(80);
    }

    /**
     * Formats an email body containing detailed information about an exception.
     *
     * @param ex The Exception to format details for.
     * @param additionalData A map of additional key-value data to include in the email body.
     * @return A formatted string containing exception details, user and organization info, timestamp, and any additional data.
     */
    public static String formatEmailBody(Exception ex, Map<String, Object> additionalData) {
        String body = 'Error: ' + ex.getTypeName() + '\n';
        body += 'Message: ' + ex.getMessage() + '\n';
        body += 'Stack Trace: ' + ex.getStackTraceString() + '\n';
        body += 'User: ' + UserInfo.getUserName() + '\n';
        body += 'Org: ' + UserInfo.getOrganizationName() + '\n';
        body += 'Time: ' + System.now() + '\n';

        if (additionalData != null && !additionalData.isEmpty()) {
            body += '\nAdditional Data:\n';
            for (String key : additionalData.keySet()) {
                body += key + ': ' + additionalData.get(key) + '\n';
            }
        }

        return body;
    }
}
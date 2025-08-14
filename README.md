
# Salesforce Sentry Client

<table>
    <tr>
        <td>
            <a href="https://githubsfdeploy.herokuapp.com?owner=otisdave&repo=salesforce-apex-sentry-client&ref=main">
                <img alt="Deploy to Salesforce"
                         src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
            </a>
        </td>
        <td>
            <a href="https://buymeacoffee.com/dotiss" target="_blank">
                <img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" height="40">
            </a>
        </td>
    </tr>
</table>

<p align="center">
    <b>If this project helps you, consider <a href="https://buymeacoffee.com/dotiss" target="_blank">buying me a coffee</a> to support future development!</b>
</p>

## What is it?

A plug-and-play Apex module for Salesforce that automatically captures exceptions, enriches them with context, and sends them to Sentry for real-time error tracking and analysis. This helps teams monitor, debug, and improve their Salesforce apps with modern observability.

---

## How It Works

- **Manager (`SentryManager`)**: Captures exceptions and coordinates async delivery.
- **Client (`SentryHttpClient`)**: Sends error data to Sentry via HTTP.
- **Utils**: Format exceptions and validate configuration.

---

## Quick Start

**1. Configure Remote Site Settings**

Authorize the Sentry endpoint for callouts:
- Go to Salesforce Setup → Remote Site Settings
- Click "New Remote Site"
- Enter a name (e.g., `Sentry`)
- Enter the Remote Site URL: `https://o000000.ingest.us.sentry.io` (use your Sentry DSN base URL)
- Save

**2. Configure Sentry Metadata**

Create a `Sentry_Config__mdt` record with:
- `Endpoint__c`: Sentry API endpoint (DSN)
- `Public_Key__c`: Sentry public key
- `Active__c`: Enable/disable integration
- `Environment__c`: e.g., "Production", "Sandbox"
- `Timeout_Seconds__c`: (Optional) HTTP timeout

**3. Capture Exceptions in Apex**

```apex
try {
    // ... your logic ...
} catch (Exception e) {
    SentryManager.CaptureException(e, new Map<String, Object>{
        'param1' => variableParam1,
        'param2' => variableParam2
    });
}
```

---

## Features

- **Async Delivery**: Non-blocking error reporting using `@future(callout=true)`.
- **Rich Context**: Sends user, org, environment, stack trace, and custom data.
- **Config-Driven**: Enable/disable or switch environments via metadata.
- **Extensible**: Add custom formatters, validators.

---

## Why Use This?

- **Centralized Error Tracking**: All your Salesforce errors in Sentry.
- **Faster Debugging**: Detailed context for every exception.
- **Easy Integration**: Minimal code changes required.
- **Scalable**: Works in any Salesforce org, supports custom logic.

---

## Contributing & Support

Feel free to open issues, suggest features, or contribute improvements!

---

## Further Reading

Check out [my mind blog on Medium](https://medium.com/p/f5c53a9b60da) for more insights and ideas.

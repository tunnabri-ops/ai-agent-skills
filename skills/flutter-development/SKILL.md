---
name: flutter-development
description: Plan, build, test and ship maintainable Flutter applications for mobile, web or desktop with appropriate state management, navigation, data and platform integration.
---

# Flutter Development

## Platform and architecture selection

Confirm target platforms, offline requirements, device capabilities, accessibility, store distribution, background work and native integrations before choosing packages or architecture.

- Use feature-first organization for multi-feature apps.
- Keep presentation, application/state, domain and data responsibilities distinct where complexity warrants it.
- Avoid imposing Clean Architecture ceremony on a tiny app.
- Choose a state management solution based on team familiarity, testability and app complexity; do not combine competing state systems without reason.
- Use repository abstractions when data sources or caching/offline policies require them.

## Implementation baseline

- Pin Flutter/Dart constraints and commit dependency lockfiles for applications.
- Use null safety and sound typing.
- Separate widgets from business logic.
- Keep widgets small and composable; avoid giant build methods.
- Model loading, success, empty and error states explicitly.
- Handle navigation, deep links, permissions and platform-specific behavior deliberately.
- Store secrets outside the app binary; client apps cannot safely contain privileged secrets.
- Use secure storage for sensitive local tokens where appropriate.
- Design offline cache, sync conflicts and retry semantics explicitly.
- Support localization, text scaling, screen readers and keyboard navigation.

## Data and networking

- Centralize API client configuration, timeouts and error mapping.
- Handle token refresh safely and avoid infinite retry loops.
- Validate server responses and tolerate schema evolution.
- Use local persistence only with a defined retention and migration strategy.
- Avoid logging personal data or credentials.

## Testing

- Unit-test domain logic and state transitions.
- Widget-test user interactions, accessibility semantics and rendering states.
- Integration-test critical flows on representative platforms.
- Test offline, slow network, permission denied, app resume and deep-link behavior.
- Run analyzer, formatter, tests and release build for each supported target.
- Verify signing, permissions, icons, splash screen and store metadata before release.

## Handover

Document supported platforms, SDK requirements, flavor/environment setup, signing steps, API configuration, release process and known platform limitations.

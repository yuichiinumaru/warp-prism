---
name: security
parent: flutter
description: Audit Flutter source and Android APK/AAB artifacts for permissions, secrets, cleartext traffic, exported components, WebView, deep links, signing, and release risk.
---

# Flutter Security

Use this route for Flutter source security, Android APK/AAB release artifact review, permissions, embedded secrets, WebView/deep-link risk, signing evidence, and third-party SDK exposure.

## Safety Boundary

Do not silently modify authentication, payment logic, signing, Android permissions, production endpoints, API-key strategy, publishing config, privacy behavior, dependency graph, or data collection. Produce evidence and ask for approval before editing those areas.

## Source-Level Checks

- [ ] No privileged secrets, long-lived bearer tokens, private keys, signing material, or payment secrets in source, assets, config, or generated files.
- [ ] Public mobile identifiers are documented as public and restricted server/provider-side where needed.
- [ ] WebView use is constrained: URL allowlist, no broad file access, no unsafe JS bridge, no mixed content unless justified.
- [ ] Deep links/app links validate target flows and do not bypass auth, checkout, password reset, or sensitive account checks.
- [ ] Storage of sensitive data uses platform-appropriate secure storage and explicit threat-model notes.
- [ ] Error reporting and logs redact PII, tokens, and credentials.

## APK/AAB Artifact Checks

When the user provides an APK/AAB or asks for release artifact review, inspect read-only evidence:

- Manifest: package, SDKs, permissions, exported components, app flags, network security config, intent filters.
- Assets/resources: backend URLs, staging/test endpoints, bundled certs/db/config, large unexpected files.
- Native Flutter signals: `flutter_assets`, `libapp.so`, `libflutter.so`, embedding classes.
- Strings: URLs, tokens, feature flags, service IDs, debug markers in `libapp.so` and decompiled resources.
- Signing: certificate subject, verification status, debug certificate, v2/v3/v4 scheme signals when tooling reports them.
- Third-party SDKs: Firebase, Sentry, Stripe, RevenueCat, Supabase, Amplitude, AppsFlyer, etc.

## Risk Classification

- **Critical**: debuggable release, global cleartext without release exception, exported sensitive component, privileged secret, production artifact signed with debug/invalid cert.
- **High**: dangerous permission without product reason, sensitive deep link without validation evidence, risky WebView bridge, broad backup/file-provider/network trust.
- **Warning**: excessive permissions, staging URLs as observable strings, large unexplained assets, public SDK keys missing restriction evidence.
- **Info**: Flutter/version/ABI/method-channel/service-provider signals.

## Safe Tool Examples

Use whatever is available locally and capture missing-tool blockers:

```bash
file app-release.apk
unzip -l app-release.apk
aapt2 dump badging app-release.apk
aapt2 dump xmltree app-release.apk AndroidManifest.xml
apksigner verify --print-certs app-release.apk
keytool -printcert -jarfile app-release.apk
jadx -d /tmp/flutterguard-jadx app-release.apk
strings path/to/libapp.so
```

Never modify, rebuild, resign, align, or delete the original artifact during review.

## Automated Scanning (OWASP Mobile Top 10)

When Python is available and the project involves mobile release, the reference corpus includes executable OWASP scanners:

- `references/flutter-claude-skills/owasp-mobile-security-checker/scripts/scan_hardcoded_secrets.py` — M1: detects API keys, tokens, passwords, AWS credentials, Firebase keys, private keys via regex with false-positive filtering.
- `references/flutter-claude-skills/owasp-mobile-security-checker/scripts/check_dependencies.py` — M2: analyzes pubspec.yaml for `any` constraints, missing versions, outdated packages, known dangerous versions.
- `references/flutter-claude-skills/owasp-mobile-security-checker/scripts/check_network_security.py` — M5: checks HTTP/HTTPS usage, badCertificateCallback bypass, certificate pinning, Android Network Security Config, iOS ATS.
- `references/flutter-claude-skills/owasp-mobile-security-checker/scripts/analyze_storage_security.py` — M9: checks insecure SharedPreferences, unencrypted file writes, unencrypted SQLite, SQL injection patterns, backup config.

Run these as read-only evidence collectors. Do not trust them as complete proof — they supplement manual review.

### Reference corpus paths

- `references/FlutterGuard/SKILL.md` — full APK/AAB inspection workflow and scoring formula.
- `references/flutter-claude-skills/owasp-mobile-security-checker/references/owasp_mobile_top_10_2024.md` — OWASP Mobile Top 10 2024 reference.

# Changelog Entry: 2025-05-20

## Summary
Security audit and improvements for the Reviewer Agent with enhanced vulnerability detection.

## Changes

### Added
- OWASP Top 10 vulnerability scanning
- Dependency vulnerability checking via Snyk integration
- Secrets detection in code (API keys, passwords, tokens)
- Security score calculation for reviewed code

### Changed
- Security findings now include CVSS scores
- Improved false positive filtering for security warnings
- Updated security rules database to latest standards

### Fixed
- Fixed false negatives in SQL injection detection
- Resolved issue with XSS pattern matching
- Fixed authentication bypass detection edge cases

### Security
- All security scan results are now encrypted at rest
- Audit logs include full provenance chain

## Affected Assets
- Agent: reviewer (v1.3.1 -> v1.3.2)
- Skill: code-review (v1.9.0 -> v2.0.0)
- Workflow: review-cycle (v1.4.0 -> v1.5.0)

## Evidence
- Security audit report #SA-2025-05
- Penetration test results: All critical findings addressed
- Compliance check: SOC 2 Type II requirements met

## Author
@security-team

## Tags
- security
- compliance
- reviewer

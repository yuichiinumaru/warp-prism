# Failure Taxonomy

Use with `remediation` when diagnosing an active failure.

## Boundary design failures
- duplicated canonical state;
- semantic owner unclear;
- generated transport becomes public/domain API;
- excessively chatty boundary;
- wrong value/handle choice.

## Build/codegen failures
- runtime/codegen/package version mismatch;
- stale generated artifacts;
- clean checkout cannot regenerate/build;
- generated path assumptions drift.

Primary router: `dependency` + `implement-frb`.

## Native load/init failures
- library not packaged/found;
- platform initialization missing;
- plugin/native host unavailable;
- symbol/ABI mismatch.

## Projection failures
- unsupported type;
- lossy conversion;
- ad-hoc JSON escape hatch;
- nullability/enum mismatch.

## Lifecycle failures
- producer survives consumer unexpectedly;
- cancel request does not stop native work;
- stream never closes;
- resource/handle leaks;
- callback outlives owner.

## Data-plane failures
- excessive copies;
- Dart GC pressure;
- missed frame/audio deadlines;
- unbounded high-frequency streams;
- CPU/GPU round trips.

## Evidence/oracle failures
- adapter fake passes while native path is broken;
- test catches/logs exception then reports PASS;
- codegen PASS treated as runtime PASS;
- host not exercised.

Diagnosis belongs to `remediation`; this taxonomy helps route the cross-boundary mechanism once identified.

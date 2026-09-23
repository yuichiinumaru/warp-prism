# Domain Ontology — Flutter↔Rust Boundaries

This reference expands the root ontology without adding new authority.

## Semantic Owner

The side that owns the authoritative meaning/state/behavior.

Examples:
- Rust owns project state, job state, audio engine, persistence.
- Flutter owns hover/focus/ephemeral visual composition.

A projection may exist on the non-owning side without creating a second owner.

## Contract

A promise meaningful independently of the transport.

Examples:
- `execute(command) -> execution_id`
- stream execution events for an ID
- cancel execution
- query current health/capabilities

## Projection

The representation of a contract across a language/runtime boundary.

A semantic enum may project to generated enums, discriminated records, DTOs, or a bridge-safe representation.

## Adapter

An anti-corruption layer between semantic code and transport/generated mechanics.

Adapters may translate:
- generated DTO ↔ semantic DTO;
- transport error ↔ semantic failure;
- stream representation ↔ domain event stream;
- native handle ↔ semantic resource ID.

## Transport

The physical crossing mechanism: FRB, direct FFI, native surface/texture, local IPC/RPC, etc.

Transport is replaceable unless project evidence proves otherwise.

## Payload

Classify payloads by:
- size;
- frequency;
- lifetime;
- mutability;
- ownership;
- fanout;
- ordering;
- copy cost.

## Resource / Handle

A stable identity for state/resource that should not be copied as a normal value.

A handle requires validity and lifecycle semantics.

## Lifetime / Flow

Creation → active use → cancellation/close → terminal state → cleanup.

Cross-boundary lifetime is a protocol, not a destructor on one side.

## Failure

Keep semantic failure independent from transport encoding.

Useful categories:
- domain/validation;
- unavailable capability;
- resource invalid;
- cancelled;
- transport/native load;
- internal/native failure.

## Evidence

Evidence must be capable of observing the claim. Static import checks cannot prove runtime crossings; host tests cannot prove Rust unsafe soundness by themselves.

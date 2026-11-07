# Deepening

How to deepen a cluster of shallow modules safely, given its dependencies. It assumes the
vocabulary of [SKILL.md](SKILL.md): module, interface, seam and adapter.

## Dependency categories

Classify a candidate's dependencies. The category sets how the deepened module is tested across
its seam.

### 1. In-process

Pure computation and in-memory state, with no I/O. It can always be deepened: merge the modules
and test through the new interface. No adapter is needed.

### 2. Controlled I/O

I/O that you control and can run for a test, such as a database, a file system or a message
broker. It can always be deepened. The suite runs the deepened module against the real service, in
a throwaway instance of its own, as `tdd` says. It never runs against an embedded or in-memory
stand-in, whose behaviour differs from production's. The seam is internal, and the module's
external interface has no port.

### 3. Remote but owned

Your own services across a network, such as microservices or internal APIs. Define a port, an
interface, at the seam. The deep module owns the logic, and the transport is injected as an
adapter. The production adapter, HTTP, RPC or a queue, is tested against the real service in a
throwaway instance. Other tests may use an in-memory adapter that passes the same tests.

Word the recommendation so: define a port at the seam. Give it an HTTP adapter for production,
tested against the real service, and an in-memory adapter that passes the same tests. The logic
then sits in one deep module, though it deploys across a network.

### 4. True external

Third-party services that you do not control, such as a payment or messaging provider. The
deepened module takes the dependency as an injected port, and tests give it a mock adapter. Mock
only this category. In the others, use the real dependency.

## Seam discipline

- **One adapter makes a hypothetical seam. Two make a real one.** Add a port only where two
  adapters are justified, typically production and test. A seam with one adapter is only
  indirection.
- **Internal seams and external seams.** A deep module can have internal seams, private to its
  implementation and used by its own tests, besides the external seam at its interface. Do not
  expose an internal seam through the interface because tests use it.

## Testing: replace, do not layer

- Old unit tests of the shallow modules become waste once tests exist at the deepened module's
  interface. Delete them.
- Write the new tests at the deepened module's interface, which is the test surface.
- Assert on observable outcomes through the interface, not on internal state.
- Tests should survive an internal refactor, as they describe behaviour and not implementation.
  A test that must change when the implementation changes tests past the interface.

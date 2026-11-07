# When to mock

Mock only a true external dependency. The deepening page of `codebase-design` lists the dependency
categories, and the fourth is this one: a third-party service that you do not control, such as a
payment or messaging provider. Time and randomness count with it, as they are not yours to control.

In the other categories, do not mock. Use the real dependency:

- In-process code: your own classes and modules, and any internal collaborator. Call them.
- I/O that you control, such as a database, a file system or a message broker: run the real
  service, isolated, as the next section says. An embedded or in-memory stand-in is no substitute:
  its dialect, transactions and limits differ from production's, so a test passes that production
  fails.
- A remote service that you own: put a port at the seam, and test its production adapter against
  the real service, isolated. The module's other tests may use an in-memory adapter, where it
  passes the same tests as the real one.

Anything you control is not mocked.

## Real services, isolated

- Each run gets its own throwaway instance of each service, at the version production runs, such
  as a Docker container started for the suite. A service that people or other runs share, such as
  a team's development database, never serves a test.
- The repository's one test command starts the services, and stops and removes them after, on a
  pass and on a failure. No step is done by hand, and CI runs the same command.
- Start each service once a run, not once a test, so that the loop stays fast. Each test then
  starts from a known state of its own: a fresh schema, a rolled-back transaction, or a key prefix
  no other test uses. No test depends on what another left.
- Each test loads the data it needs. No test reads a copy of real data.
- A file system needs no container: a temporary directory of the test's own is the real one.
- Where no instance can run, the test is skipped and says why. A stand-in never takes its place.

A network alone does not make a service yours: a third party's service is still mocked.

## Designing for mockability

At a seam to a true external dependency, design an interface that is easy to stand in for.

### 1. Accept the dependency, do not create it

Pass an external dependency in, rather than building it inside:

```text
// Easy to mock
function process_payment(order, payment_client):
    return payment_client.charge(order.total)

// Hard to mock
function process_payment(order):
    client = new payment client(read secret key from the environment)
    return client.charge(order.total)
```

### 2. Prefer specific operations to a generic fetcher

Give each external operation its own function, not one generic function with conditional logic:

```text
// GOOD: each operation can be replaced on its own
api = {
    get_user(id),
    get_orders(user_id),
    create_order(data),
}

// BAD: a replacement needs conditional logic inside it
api = {
    fetch(endpoint, options),
}
```

Specific operations mean that:

- Each replacement returns one specific shape
- No conditional logic is needed in the test's setup
- A reader sees which operations a test exercises
- Each operation can be typed on its own

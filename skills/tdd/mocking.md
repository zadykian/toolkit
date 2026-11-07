# When to mock

Mock only a true external dependency. The deepening page of `codebase-design` lists the dependency
categories, and the fourth is this one: a third-party service that you do not control, such as a
payment or messaging provider. Time and randomness count with it, as they are not yours to control.

In the other categories, do not mock. Use the real dependency, or a local stand-in for it:

- In-process code: your own classes and modules, and any internal collaborator. Call them.
- Local-substitutable code, such as a database or a file system: run against an embedded or
  in-memory stand-in, in place of a mock.
- A remote service that you own: put a port at the seam, and give tests an in-memory adapter.

Anything you control is not mocked.

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

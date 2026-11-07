# Good and bad tests

The examples are pseudocode. Use the repository's own language and test tools.

## Good tests

**Integration-style**: test through real interfaces, not mocks of internal parts.

```text
// GOOD: tests behaviour that can be seen
test "user can check out with a valid cart":
    cart = new cart
    cart.add(product)
    result = checkout(cart, payment_method)
    expect result.status equals "confirmed"
```

Characteristics:

- Tests behaviour that users and callers care about
- Uses the interface alone
- Survives internal refactors
- Describes what, not how
- One logical assertion per test

## Bad tests

**Implementation-detail tests**: coupled to the internal structure.

```text
// BAD: tests an implementation detail
test "checkout calls the payment service":
    mock_payment = mock(payment_service)
    checkout(cart, payment)
    expect mock_payment.process was called with cart.total
```

Red flags:

- Mocking an internal collaborator
- Testing a private method
- Asserting on the count or order of calls
- The test breaks on a refactor that changes no behaviour
- The test's name says how, not what
- Checking through other means than the interface

```text
// BAD: goes round the interface to check
test "create_user saves to the database":
    create_user(name: "Alice")
    row = database.query("select * from users where name = 'Alice'")
    expect row exists

// GOOD: checks through the interface
test "create_user makes the user retrievable":
    user = create_user(name: "Alice")
    retrieved = get_user(user.id)
    expect retrieved.name equals "Alice"
```

**Tautological tests**: the expected value restates the implementation, so the test passes by
construction.

```text
// BAD: the expected value is worked out the way the code works it out
test "calculate_total sums the line items":
    items = [{price: 10}, {price: 5}]
    expected = sum of each item's price
    expect calculate_total(items) equals expected

// GOOD: the expected value is an independent, known literal
test "calculate_total sums the line items":
    expect calculate_total([{price: 10}, {price: 5}]) equals 15
```

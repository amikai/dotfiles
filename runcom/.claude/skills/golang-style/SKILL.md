---
name: golang-style
description: Use when writing Go code - enforces style conventions for initialization, mutexes, slices, maps, defer, time, testing, and performance
---

# Go Style Guide

## Overview

Personal Go coding conventions for consistent, safe, and idiomatic code.

## Quick Reference

### Use Built-in min/max

Use built-in `min` and `max` functions (Go 1.21+) instead of if-else.

```go
// Bad
func min(a, b int) int {
    if a < b {
        return a
    }
    return b
}
x := min(a, b)

// Good
x := min(a, b)
y := max(a, b, c)  // supports multiple arguments
```

### Struct Initialization

**Omit zero-value fields** unless they provide meaningful context:

```go
// Bad - noisy
user := User{
    FirstName:  "John",
    LastName:   "Doe",
    MiddleName: "",
    Admin:      false,
}

// Good - only meaningful values
user := User{
    FirstName: "John",
    LastName:  "Doe",
}
```

**Exception:** In test tables, include zero values when field names clarify intent:
```go
tests := []struct{
    give string
    want int
}{
    {give: "0", want: 0},  // zero value is meaningful here
}
```

**Use `var` for zero values** (all types):

```go
// Bad
user := User{}
nums := []int{}
m := map[string]int{}

// Good - clearly signals zero-value
var user User
var nums []int
var m map[string]int
```

### Avoid Mutable Globals

Avoid mutating global variables. Use dependency injection instead (applies to function pointers and other values).

```go
// Bad - mutable global, hard to test
var _timeNow = time.Now

func sign(msg string) string {
    now := _timeNow()
    return signWithTime(msg, now)
}

// Test mutates global - not safe for parallel tests
func TestSign(t *testing.T) {
    oldTimeNow := _timeNow
    _timeNow = func() time.Time { return someFixedTime }
    defer func() { _timeNow = oldTimeNow }()
    // ...
}

// Good - dependency injection via struct
type signer struct {
    now func() time.Time
}

func newSigner() *signer {
    return &signer{now: time.Now}
}

func (s *signer) Sign(msg string) string {
    now := s.now()
    return signWithTime(msg, now)
}

// Test - clean, parallel-safe
func TestSigner(t *testing.T) {
    s := newSigner()
    s.now = func() time.Time { return someFixedTime }
    // ...
}
```

### Mutexes

| Rule | Example |
|------|---------|
| Zero-value is valid | `var mu sync.Mutex` not `new(sync.Mutex)` |
| Named field in structs | `mu sync.Mutex` not embedded `sync.Mutex` |

```go
// Bad - mutex embedded, Lock/Unlock exposed in API
type SMap struct {
    sync.Mutex
    data map[string]string
}

// Good - mutex is implementation detail
type SMap struct {
    mu   sync.Mutex
    data map[string]string
}
```

### Slices and Maps

| Rule | Why |
|------|-----|
| Copy when receiving | Caller can modify original after passing |
| Copy when returning | Caller can modify internal state |

```go
// Receiving - copy the slice
func (d *Driver) SetTrips(trips []Trip) {
    d.trips = make([]Trip, len(trips))
    copy(d.trips, trips)
}

// Returning - return a copy
func (s *Stats) Snapshot() map[string]int {
    s.mu.Lock()
    defer s.mu.Unlock()

    result := make(map[string]int, len(s.counters))
    for k, v := range s.counters {
        result[k] = v
    }
    return result
}
```

**When operations seem too complex:** Check stdlib helpers first.
- `go doc -all maps` - map utilities (Clone, Copy, Keys, Values, etc.)
- `go doc -all slices` - slice utilities (Clone, Contains, Sort, etc.)

**nil is a valid slice:**

```go
// Return nil, not empty slice
if x == "" {
    return nil  // not []int{}
}

// Check empty with len, not nil
func isEmpty(s []string) bool {
    return len(s) == 0  // not s == nil
}

// Zero-value slice is usable without make()
var nums []int          // not nums := []int{} or make([]int)
nums = append(nums, 1)  // works fine
```

**Note:** nil slice vs `[]int{}` may serialize differently (e.g., JSON: `null` vs `[]`).

### Defer

**Always use `defer` to clean up resources (locks, files) - no exceptions.**

```go
// Good - defer ensures unlock on all paths
p.Lock()
defer p.Unlock()

if p.count < 10 {
    return p.count
}
p.count++
return p.count
```

Defer overhead is negligible. Only avoid if function execution is nanoseconds.

### Time Handling

| Type | Use For |
|------|---------|
| `time.Time` | Instants (points in time) |
| `time.Duration` | Periods (lengths of time) |
| `Time.AddDate` | Calendar operations (same time, next day) |
| `Time.Add` | Exact durations (24 hours later) |

```go
// Bad - ambiguous int
func poll(delay int) { ... }
poll(10) // seconds? milliseconds?

// Good - explicit duration
func poll(delay time.Duration) { ... }
poll(10 * time.Second)
```

**Time comparisons:**
```go
// Bad
return start <= now && now < stop

// Good
return (start.Before(now) || start.Equal(now)) && now.Before(stop)
```

### Time with External Systems

| System | Support |
|--------|---------|
| CLI flags | `time.Duration` via `time.ParseDuration` |
| JSON | `time.Time` as RFC 3339 string |
| SQL | `DATETIME`/`TIMESTAMP` to `time.Time` |
| YAML | `time.Time` as RFC 3339, `time.Duration` via `time.ParseDuration` |

**When `time.Duration` not possible:** Use `int`/`float64` with unit in field name.

```go
// Bad
type Config struct {
    Interval int `json:"interval"`
}

// Good
type Config struct {
    IntervalMillis int `json:"intervalMillis"`
}
```

**When `time.Time` not possible:** Use `string` with RFC 3339 format (`time.RFC3339`).

**When unsure about time handling:** Run `go doc --all time` to find the proper function.

**Note:** Go's `time` package doesn't support leap seconds.

### Testing

**Always use `github.com/stretchr/testify`** for assertions:

```go
import (
    "testing"

    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/require"
)

func TestSomething(t *testing.T) {
    // assert - continues on failure
    assert.Equal(t, expected, actual)
    assert.NoError(t, err)

    // require - stops on failure
    require.NotNil(t, obj)
}
```

### Performance

**Prefer `strconv` over `fmt`** for primitive conversions:

```go
// Bad - 143 ns/op, 2 allocs
s := fmt.Sprint(rand.Int())

// Good - 64 ns/op, 1 alloc
s := strconv.Itoa(rand.Int())
```

**Avoid repeated string-to-byte conversions** in loops:

```go
// Bad - 22 ns/op, converts every iteration
for i := 0; i < b.N; i++ {
    w.Write([]byte("Hello world"))
}

// Good - 3 ns/op, convert once
data := []byte("Hello world")
for i := 0; i < b.N; i++ {
    w.Write(data)
}
```

**Specify container capacity** when size is known:

```go
// Maps - capacity is a hint (not guaranteed)
m := make(map[string]os.DirEntry, len(files))

// Slices - capacity is guaranteed, append won't allocate until full
data := make([]int, 0, size)  // 10x faster with capacity
for k := 0; k < size; k++ {
    data = append(data, k)
}

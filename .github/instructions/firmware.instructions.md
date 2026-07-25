---
applyTo: "firmware/**"
---

# Firmware Rules (PlatformIO / embedded targets)

> **Provisional (set at E0 onboarding, #17).** There is no `firmware/` tree
> yet — it arrives with Epic E3. The board, env names, and blocking threshold
> below come from the plan-intake bundle (`docs/context/stackchan-hw/` and
> the E3 epic draft) and must be re-verified against the real
> `platformio.ini` during E3 hardware bring-up.

## Target (provisional until E3)

- Device: StackChan kit on an M5Stack CoreS3 (M5Stack K151 in the plan
  intake), ESP32-S3 MCU — 2.4 GHz Wi-Fi only, no 5 GHz.
- PlatformIO envs: `m5stack-cores3` (device build, StackChan-BSP/M5Unified
  stack) and `native` (host-side unit tests).

## Environment reality

- Cloud agents and CI runners have **no physical device**: no serial port, no
  flashing, no sensors. Anything that needs real hardware belongs to a task
  labeled `exec:ide` (see `.github/skills/task-routing/SKILL.md`). Never mark a
  hardware-dependent acceptance criterion as verified from a cloud environment.
- Host-side verification that *is* possible anywhere: `pio run -e m5stack-cores3`
  (build) and `pio test -e native` (unit tests in the `native` environment).

## Design for testability

- Keep business logic (state machines, protocol parsing, message formatting)
  behind hardware-abstraction interfaces so it compiles and runs in the
  `native` env. Hardware access lives in thin adapter layers.
- Every new logic module ships with at least one `native` test. Tests are what
  allow agents to work on this code autonomously; untested firmware logic
  forces every change back to a human with a device.

## Coding constraints

- Respect the memory budget of the target MCU: prefer static allocation,
  avoid unbounded `String`/heap growth in long-running loops, and document any
  buffer size assumptions next to the buffer.
- No blocking waits in the main loop beyond 50 ms (provisional until E3);
  use non-blocking patterns or the project's scheduler.
- Pin assignments, credentials, and endpoints come from `platformio.ini`
  build flags or config headers — never hard-code them in logic files.
- When changing `platformio.ini`, state in the PR which envs were rebuilt and
  paste the resulting RAM/Flash usage lines as evidence.

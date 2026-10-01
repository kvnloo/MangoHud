# MangoHud observer-effect latency experiment

References:

- issue 2117: high mangoapp CPU with VRR enabled
- issue 2142: request for display / PC latency metrics

## First question

How much does the measurement layer perturb the workload?

Run the same deterministic workload in A/B/B/A order:

```sh
bash experiments/e2e-latency/run-abba.sh -- <workload>
```

The default comparison is overlay off vs the minimal FPS+frametime configuration.

Then repeat manually with `detailed.conf`, VRR off/on, and high-rate mouse movement.

Pair the run with the same external frame-time or presentation trace used in the other latency experiments. `perf` alone cannot establish input-to-display latency.

## MangoApp-specific follow-up

For issue 2117, profile the `mangoapp` process itself with VRR off/on and capture a flamegraph or `perf report`. The existing report points at X11/GLFW window-query and wait paths, so first verify whether current master still spends time there.

## Display-latency feasibility

Before implementing issue 2142, inventory timing already available from:

- gamescope
- Vulkan present timing
- compositor presentation feedback
- DRM/pageflip timing

A latency HUD should consume an existing timestamp stream rather than introduce a new busy polling source.

No upstream promotion from this branch.

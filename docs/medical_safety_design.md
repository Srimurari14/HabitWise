# Medical and psychiatric safety design

## Purpose

HabitWise personalizes behavioral support while avoiding diagnosis, medication advice, restrictive eating guidance, and emergency-treatment calculations. The design uses three explicit hooks around the original craving tree.

## Hook A: pre-tree safety

Only relevant safety questions are shown:

- Everyone is asked about physical hunger. Yes or meaningful uncertainty exits to a nourishment plan.
- A glucose warning-state question appears only when the user enables glucose safety. A positive answer exits to an established care plan or urgent help; HabitWise does not invent a treatment plan.
- A restriction/compensation question appears only in eating-concern safety mode. A positive answer exits to nourishment and human support.

Safety exits are persisted for history but cannot train trigger or intervention rankings.

## Hook B: source-tagged soft priors

The adaptive ranking combines base priors, learned local history, and optional profile context. Each suggestion retains its source. The current answer receives a dominant score and cannot be overruled by profile data.

ADHD-medication appetite support is user-specific. If a person reports appetite increasing as medication wears off and provides a usual window, the physiological category and `medication_rebound` subtrigger receive a small boost during that window. No drug name produces an inferred duration.

Other contexts make similarly small adjustments: sensory needs may elevate a specific sensory branch; optional mood/stress contexts may gently elevate emotional exploration. These are prompts, not conclusions.

## Hook C: terminal plan filter

Before a plan reaches the screen, incompatible plans are removed. Eating-concern safety mode removes tags for delay, resistance, restriction, and portion control, and disables every remaining timer. Digestive context removes high-volume-food suggestions. Additional filters can be added as versioned rules without rewriting the tree.

## Persistent eating-concern mode

Once enabled, routine profile editing cannot disable this mode. The repository enforces persistence even if a caller attempts to save `false`. Deleting the entire local profile is the only in-app reset in version 1. A future supported-reset flow should require deliberate safety copy and must never be triggered by editing another answer.

## Non-learnable plan invariant

The following plans are protected by ID in the repository, independent of JSON flags:

- `permission-to-eat`
- `steady-snack`
- `wear-off-meal`
- `cycle-support`
- `permission-and-support`
- `glucose-safety-exit`

They never update adaptive trigger weights or plan efficacy statistics. This prevents “eating helped” or “urgent safety route used” from being optimized as if it were a resistance intervention.

## Copy constraints

- No “gave in,” “won,” “lost,” “good food,” “bad food,” or moral scoring.
- No calorie, portion, weight, or compensation targets.
- Eating the desired food remains an explicit valid outcome.
- Health insights say “in your entries” and “associated,” never “caused.”
- Medication copy can recommend contacting a prescriber, never altering treatment.
- Crisis or severe warning states direct the person out of the craving coach.

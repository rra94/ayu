# M8: Smart Nutrition — Recommendations + Bioavailability

## Overview

Two features that turn raw nutrient data into actionable intelligence:
1. **Smart food recommendations** that suggest specific foods to fill micronutrient gaps
2. **Bioavailability panel** showing estimated real absorption based on food combinations and context

## Why

Tracking nutrients is pointless if the user doesn't know (a) what to eat to fix deficiencies or (b) how much their body actually absorbs. Most apps show "Iron: 8mg / 18mg RDA" but don't mention that only 2-5mg of that 8mg is actually absorbed if it's from spinach with no vitamin C.

## Features

| ID | Feature | Plan File |
|----|---------|-----------|
| 1 | Smart Food Recommendations | [recommendations.md](recommendations.md) |
| 2 | Bioavailability / Absorption Panel | [bioavailability.md](bioavailability.md) |

## Checkpoint

- Micronutrient tracker shows "Top up" suggestions for low nutrients
- Each nutrient row shows estimated absorption % based on today's food mix
- Enhancer/inhibitor tips shown contextually (e.g., "Add vitamin C to boost iron absorption 2-6x")

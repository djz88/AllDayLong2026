<!-- SPDX-FileCopyrightText: 2026 AllDayLong 2026 project contributors -->
<!-- SPDX-License-Identifier: GPL-3.0-or-later -->

# AllDayLong – Prompt Instructions

This document specifies future regeneration and improvement of the AllDayLong wallpapers. It does not describe the exact process used to create the current files in `../images/`; the actual properties of the current version are summarized in `IMAGE-QUALITY.md`.

The goal is to create eight visually connected sci-fi wallpapers showing one surreal landscape changing over 24 hours. The historical images serve as visual references.

The result must not look like eight independent illustrations. It should depict one consistent world in which time passes.

## Input references

Use all eight historical images:

- `original-AllDayLong/01.jpg`
- `original-AllDayLong/02.jpg`
- `original-AllDayLong/03.jpg`
- `original-AllDayLong/04.jpg`
- `original-AllDayLong/05.jpg`
- `original-AllDayLong/06.jpg`
- `original-AllDayLong/07.jpg`
- `original-AllDayLong/08.jpg`

The original schedule is stored in `original-AllDayLong/AllDayLong.xml`.

The reference images are 1280 × 800 with a 16:10 aspect ratio. The output wallpapers must be 3840 × 2160 with a 16:9 aspect ratio. Conversion must therefore not consist of merely stretching and distorting the image; the composition must be extended or cropped with care.

## 1. Core visual concept

- Style: cinematic atmospheric sci-fi, surreal ambient art, ethereal space fantasy.
- Composition: an ocean of clouds, a distant horizon, a planet in the upper-right area, white ionization streams on the left, and golden orbital curves on the right.
- Atmosphere: dreamlike, peaceful, mysterious, deep, and subtly cosmic. Not realistic photography.
- Color: deep, saturated, yet clean colors. Rich gradients without banding, noise, or clipped highlights.
- Signature motif: modern white ionization streams resembling aerodynamic or condensation trails from an energy object, not tentacles.
- Resolution: genuinely detailed 3840 × 2160 px, 16:9, PNG, sRGB.

## 2. Main prompt

```

PROJECT: AllDayLong 2026 – Cinematic Atmospheric Edition

TASK:
Recreate the supplied sequence of eight sci-fi wallpapers
as a cohesive, cinematic, time-evolving environment.

Use the original images as strict composition and art
direction references.

Create a unified master scene depicting a surreal,
ethereal world above a vast ocean of clouds, with an
enormous distant celestial planet, elegant luminous
energy streams, orbital arcs and atmospheric light.

ART DIRECTION:
- Modern cinematic sci-fi illustration, not photography.
- Dreamlike, mysterious, peaceful and atmospheric.
- Rich color depth, smooth gradients, clean silhouettes.
- High-quality volumetric clouds and atmospheric depth.
- Elegant lighting with physically plausible diffusion,
  but artistic and stylized geometry.
- Luminous details with controlled bloom.
- Visually clean, premium digital artwork.
- Suitable for a sophisticated 4K desktop wallpaper.

PRESERVE:
- Overall geometry and composition of the original scene.
- Planet in the upper-right region.
- Large cloud formations and established horizon.
- Recognizable left-side luminous streams.
- Golden orbital structures and light points on the right.
- Balance between the foreground, atmosphere and sky.

MODERNIZE THE WHITE SPIRALS:
Replace the old, tentacle-like white spirals with
sophisticated aerodynamic ionization trails.

They should resemble luminous atmospheric flow lines,
distorted aircraft contrails, or electromagnetic
plasma streams traveling through the upper atmosphere.

Use:
- Multiple elegant, flowing, layered filaments.
- Thin luminous cores and subtle transparent halos.
- Smooth curvature and natural dissipating ends.
- Controlled, volumetric white-cyan glow.
- Delicate turbulence and restrained motion.
- Consistent recognizable shapes throughout all frames.

Avoid thick, solid tentacles, ornamental curls,
excessively bright white strokes and tangled lines.

TIME EVOLUTION:
All eight images represent the SAME environment
at different times of day.

Maintain stable scene geometry while introducing
controlled, subtle changes:

1. Planet:
   Gentle positional drift and changing illumination.

2. White ionization streams:
   Subtle endpoint deformation, brightness modulation,
   changing filament density and delicate flowing motion.

3. Golden orbital arcs:
   Gradual changes in luminous intensity, color
   temperature, and slight opening or contraction.

4. Energy nodes:
   Small visible movements along existing orbital paths.

5. Clouds:
   Subtle atmospheric drift and depth-dependent
   parallax between cloud layers.

6. Sky and cosmic atmosphere:
   Natural progression from deep cosmic night through
   dawn, morning, midday, golden hour, dusk and night.

CRITICAL CONSISTENCY:
Every image must look like a frame from the same
continuous cinematic scene.

Keep the planetary identity, major cloud topology,
horizon, and orbital structure consistent.

Motion must be subtle and cumulative, not random.

The last image must transition naturally into the first.

IMAGE QUALITY:
Generate genuine high-frequency detail at the target
resolution, rather than simply resizing a smaller image.

Maintain smooth gradients, clean volumetric lighting,
crisp but natural edges, and fine cloud structures.

Never add artificial grain or procedural noise
as a substitute for real detail.

OUTPUT:
Eight individual, full-frame wallpapers:
01.png, 02.png, 03.png, 04.png,
05.png, 06.png, 07.png, 08.png.

Each at 3840 x 2160 pixels, 16:9, PNG, sRGB.

No text, labels, borders, logos, UI elements
or contact sheets inside the wallpaper images.

```

## 3. Definition of all eight images

Use these specifications together with the main prompt.

| Image | Time of day | Required appearance and dynamics |
|---|---|---|
| 01 | Dawn | Deep nighttime indigo transitions into pink, coral, and warm orange. Fading stars, subtle light below the horizon. The streams gradually become brighter. |
| 02 | Morning | Pastel blue, turquoise, and subtle golden tones. Clouds gain volume, the planet receives brighter illumination, and the light points shift slightly. |
| 03 | Late morning | A clear azure sky, brighter white clouds, and high atmospheric clarity. The ionization streams become more delicate and their endpoints spread slightly. |
| 04 | Midday | The brightest daytime image, with deep blue and turquoise and clearly visible cloud detail. Light effects remain present without overpowering daylight. |
| 05 | Afternoon | Richer cobalt blue with gradually warmer illumination. Clouds drift subtly, and the golden loops begin to gain visual intensity. |
| 06 | Golden hour | Amber, orange, and copper light above the clouds. Dramatic but clean illumination. The golden orbital curves are at their most prominent. |
| 07 | Dusk | A transition into violet, purple, and deep blue. The first stars appear, the planet becomes more prominent, the white streams become cooler, and warmth gradually recedes from the horizon. |
| 08 | Night | Deep cosmic blue approaching black. Stars, subtle nebulae, and a visible planet. Dimly lit clouds and more prominent ionization streams. |

## 4. Moving elements — required rules

This is an important part of the original specification that was repeatedly lost during earlier regeneration attempts.

| Element | Recommended movement at 4K |
|---|---|
| Planet | Approximately 24–32 px over the full day |
| Light points | 8–16 px between adjacent states |
| Clouds and mist | 10–30 px between adjacent states |
| White streams | Endpoint-filament deformation up to 10 px |
| Golden curves | Subtle changes in curvature, openness, and intensity |

These values are approximate artistic limits, not requirements for an exact physical simulation.

Critical: movement must be visible when comparing adjacent frames, but it must not produce distracting doubled contours during blending.

## 5. Negative prompt

```

Avoid:
- Photorealistic landscape photography
- Cartoon aesthetics
- Plastic-looking clouds
- Tentacle-shaped white spirals
- Oversized ornamental curls
- Excessive bloom and white clipping
- Artificial microtexture or film grain
- Oversharpening and sharpening halos
- Double edges and ghosting
- Randomly changing cloud formations
- Changing planetary identity or scale
- Inconsistent perspective and horizon
- Unnatural positional jumps
- Excessive HDR or oversaturation
- Flat cloud layers
- Color banding and compression artifacts
- Blurry upscaled details
- Unrelated sci-fi spacecraft or buildings
- Text, logos, labels, frames or UI elements

```

## 6. Recommended production workflow

The prompt alone cannot guarantee consistency. A disciplined workflow is also essential for a high-quality regeneration.

1. Create one master image with a fixed composition, planet, clouds, streams, and golden loops.
2. Separate elements into layers: sky, planet, clouds, white streams, golden arcs, and light nodes.
3. Preserve geometry: change illumination and predefined motion between frames instead of regenerating every object independently.
4. Create eight time states according to the table, paying particular attention to continuity between adjacent images and the `08 → 01` transition.
5. Export genuine 4K: prefer a model or rendering tool capable of native 3840 × 2160 output. If AI reconstruction is necessary, distinguish it clearly from a native render.
6. Inspect at 100% scale: check gradient smoothness, cloud sharpness, the planet, light lines, and possible artifacts.

## 7. Metadata for future runs

Record the following before every new run:

- model and version,
- tool used,
- seed, if supported by the tool,
- method used to supply the reference images,
- input and output resolutions,
- method used to convert 16:10 to 16:9,
- any upscaling and post-processing,
- run date,
- known deviations from this specification.

## 8. Most important requirement

Use the following order of priority during regeneration:

Fidelity to the original artistic concept → consistency and movement → clean detail → resolution.

An image with more pixels but synthetic noise, doubled streams, or an altered composition is worse than the original clean source.

This prompt can serve as a base specification for another generative model or a 3D/multilayer rendering workflow. To achieve the closest result, use all eight images from `original-AllDayLong/` together with the separately approved design of the modernized white ionization streams.

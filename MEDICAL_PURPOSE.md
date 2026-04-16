# Isobar — Medical Purpose & Clinical Rationale

---

## Overview

Isobar is a symptom tracking application built for a patient with a complex, progressive, multisystem illness that remains undiagnosed after years of fragmented specialist care. The app exists to solve a specific clinical problem: **the absence of objective longitudinal data at the point of specialist evaluation.**

This patient sees multiple specialists independently with no coordinating physician. Each appointment begins from near zero — the specialist has no context for how symptoms have evolved, what triggers them, how severe they are relative to baseline, or how frequently they occur. The patient's own ability to report symptoms in clinical settings is further compromised by autistic masking, high pain tolerance, and variable cognitive function on any given day.

Isobar addresses this by capturing structured, time-stamped, environmentally-contextualized symptom data in the patient's own environment — including during active events — and generating reports formatted for clinical use.

---

## The Diagnostic Gap This App Fills

### Problem 1 — Episodic events are never witnessed clinically

The patient experiences episodic myoclonic events lasting 30 minutes to 4 hours, occurring every few days. These events have never been captured on monitoring. The 4-day EEG was negative — expected, as the events are not epileptic. The EMG was performed during active twitching but the SPS-specific co-contraction protocol was not used. No neurologist has witnessed a full event.

The app captures the precise prodromal sequence, limb distribution, timing, duration, and post-event functional state for every event — building a documented record that substitutes for direct clinical observation.

### Problem 2 — Symptom reporting is unreliable in clinical settings

The patient is a lifelong autistic masker with high pain tolerance. She consistently presents as more functional than she is. Strength testing appears normal in clinic while she experiences genuine weakness requiring a cane at home. Gait appears normal under observation while she must consciously direct her walking in daily life.

Standard 0-10 numeric pain scales systematically underreport her actual state due to alexithymia and interoceptive differences documented in the autism research literature. A doctor asking "how are you feeling?" receives a masked, compressed answer that does not reflect functional reality.

The app bypasses these barriers by using validated autism-appropriate assessment methods — functional impact anchors, body map locations, sensation descriptors, communication capacity as a severity proxy, and personal baseline comparison — capturing data that does not depend on real-time interoceptive translation.

### Problem 3 — Environmental triggers are not documented at time of occurrence

The patient's events are strongly correlated with barometric pressure drops, temperature change, fasting, and allergen exposure. These correlations are clinically significant but have never been formally documented. By the time she reaches a specialist appointment she cannot accurately recall the environmental conditions during events two weeks prior.

The app automatically captures barometric pressure and 6-hour trend at the time of every logged event using GPS-based weather data. This creates an objective environmental record that accompanies every symptom entry.

### Problem 4 — No care coordinator exists

The patient is navigating neurology, rheumatology, spine surgery evaluation, and autonomic testing independently with no physician holding the full picture. Critical tests have not been ordered (anti-GAD65 antibody, anti-Ro/SSA, tilt-table test, lumbar spine imaging). Relevant history is fragmented across providers who do not communicate.

The app generates structured reports that can be brought to any specialist appointment, establishing a documented clinical timeline that compensates for the absence of coordinated care.

---

## Clinical Hypotheses Being Tracked

The app is specifically designed to capture data relevant to evaluating the following leading diagnostic hypotheses. None are confirmed. All are under active investigation.

### Hypothesis 1 — Stiff Person Syndrome / PERM Spectrum
**Why this matters for app design:**
SPS produces episodic spasms with a specific prodromal pattern, continuous motor unit activity between episodes, and dramatic response to GABAergic agents. The prodromal sequence — lower back pressure building, energy in the legs, then facial tingling — is characteristic of spinal interneuron disinhibition propagating rostrally before the motor release.

**What the app tracks:**
- Precise prodromal sequence with individual symptom timestamps
- Limb distribution and propagation order (right leg → bilateral → left arm is the documented pattern)
- Left facial tingling as final prodromal sign — clinically specific for brainstem involvement
- Post-event weakness severity and cane requirement
- Chest tightness / breathing involvement (PERM brainstem feature)
- Duration and jerk frequency
- Benzodiazepine response is documented in patient history (week 1 felt "phenomenal" — GABAergic mechanism)

**Anti-GAD65 antibody has never been ordered.** This is the primary SPS diagnostic marker. The app data supports urgency of ordering this test.

### Hypothesis 2 — Autoimmune Connective Tissue Disease
**Why this matters for app design:**
Sjögren's syndrome, UCTD, or lupus spectrum disease would explain the 19-year history of photosensitivity, Raynaud's, cold urticaria, dry eyes, and the indeterminate anti-dsDNA result. Autoimmune conditions fluctuate with hormonal cycles, stress, infection, and environmental load — all of which need tracking to establish patterns.

**What the app tracks:**
- Perimenopausal symptom flares and correlation with episode frequency
- Overall severity trend over time
- Post-exertional malaise pattern (delayed crash 24-48 hours — ME/CFS pattern)
- Sleep quality and restorative function
- Functional impact on work capacity

### Hypothesis 3 — Post-COVID Dysautonomia / POTS
**Why this matters for app design:**
The patient had four COVID infections with progressive autonomic decline following the spring 2023 infection. Temperature dysregulation, palpitations never captured on monitoring, floor-drop sensation (not true vertigo), bladder urgency, and the narrow functional temperature window (50-90°F stable) all suggest autonomic dysfunction.

**What the app tracks:**
- Barometric pressure at every event (autonomic systems are sensitive to pressure change)
- Temperature at time of events
- Heat therapy use — hot baths, saunas, heating pads (relieves symptoms — distinct from ambient heat above 90°F which worsens symptoms)
- Fasting duration — gut hypoperfusion from autonomic dysfunction is worsened by fasting
- Orthostatic symptoms (floor-drop sensation) are not yet in the app but could be added

**Orthostatic vital signs have never been formally measured in a clinical setting.** Tilt-table test has never been ordered.

### Hypothesis 4 — MCAS (Mast Cell Activation Syndrome)
**Why this matters for app design:**
Both cold below ~50°F and heat above ~90°F trigger reactions. Chemical sensitivities to perfumes, cleaning products, gasoline, and paint are documented. Red wine causes mouth irritation. Dog exposure preceded tonight's episode. MCAS frequently co-occurs with dysautonomia and connective tissue disease.

**What the app tracks:**
- Animal exposure as a logged trigger
- Chemical / perfume exposure as a logged trigger
- New environment trigger (mold exposure — both current and previous homes have musty basements, patient lived in a moldy Boston basement for approximately one year)
- Fasting duration — mast cell activation thresholds are lower under metabolic stress

### Hypothesis 5 — Cervical Myelopathy Contributing to Neurological Symptoms
**Why this matters for app design:**
The patient has documented moderate central canal stenosis at C6-C7 with premature multilevel cervical disc degeneration. The right-sided neurological pattern — right leg initiating episodes first, right arm and hand symptoms, right neck rotation matching grandmother — has been present since high school. The cervical spinal cord, even without MRI signal change, can have functional impairment from chronic compression that alters spinal interneuron circuit behavior.

**What the app tracks:**
- Limb distribution — right leg first is consistently documented
- Post-episode weakness pattern
- Body pain locations including neck and upper back
- Throat tightening and breathing difficulty (C6-C7 compression can affect descending autonomic pathways to laryngeal and pharyngeal muscles)

**Lumbar spine has never been imaged.** Right hip and leg pain since high school, right foot sensory changes, and right leg initiating myoclonus all indicate lumbar imaging is needed.

---

## Why Standard Symptom Tracking Tools Are Insufficient

### 1. Numeric pain scales are clinically invalid for this patient

The autism research literature documents that autistic adults with alexithymia systematically underreport pain on numeric scales. The 2025 Pain Awareness Scale validation study (Journal of Pain) found autistic adults score significantly higher on difficulties in pain recognition, characterization, and verbal communication compared to neurotypical controls. This patient has documented high pain tolerance confirmed by clinical providers.

Using a 0-10 scale would generate data that underrepresents actual symptom burden and would be misleading to clinicians reviewing the log.

### 2. Standard apps do not capture environmental context automatically

Weather, barometric pressure, and temperature are manually entered in most apps — or not captured at all. For this patient, environmental data is not supplementary; it is primary. Barometric pressure drop is the strongest documented trigger. Manual entry during an active episode is not feasible.

### 3. Standard apps are not designed for use during active neurological events

Most symptom trackers assume the user is cognitively intact at time of logging. This patient needs to log during active events when communication is impaired, cognition is compromised, and fine motor control may be affected. The episode logging form is designed around this: minimal required input, large tap targets, one question at a time, auto-populated environmental data.

### 4. Standard apps do not generate clinically formatted reports

The export function generates a plain text report structured in the format a neurologist or rheumatologist would expect to read — chronological episodes with environmental context, trigger frequency analysis, functional impact trend, and severity anchored to a documented personal baseline.

---

## The Fasting Risk System — Clinical Rationale

The app includes a meal logging function with escalating alerts at 4, 5, and 7 hours of fasting, and a compound alert when falling barometric pressure coincides with fasting.

**Clinical basis:**

Fasting reduces GABAergic inhibitory tone. In a patient with suspected impaired GABAergic inhibition (the proposed SPS mechanism), metabolic stress from fasting directly lowers the threshold for motor neuron hyperexcitability. Dysautonomia guidelines explicitly recommend against fasting for autonomic patients — stable fuel delivery is critical for autonomic function.

The compound alert (falling pressure + fasting ≥4 hours) reflects the clinical observation that multiple converging vulnerabilities — not any single trigger — produce the most severe events. Tonight's documented episode involved: barometric pressure 976.5 hPa and falling, 7+ hours fasted, first return to a dog-present environment in over a month, driving through an active weather front.

Food suggestions are calibrated for the patient's specific dietary restrictions (vegetarian, gluten-free, egg-free, limited dairy, low-histamine) and are timed to the neurological rationale — protein + fat + small carbohydrate together, not carbohydrate alone, because the goal is stable glucose delivery with protein-mediated glucagon support, not a rapid glucose spike.

---

## The Muscle Event Log — Clinical Rationale

Sub-episode neurological events — intercostal spasms, limb twitching without full episode progression, jaw muscle spasming, truncal rigidity — are not currently captured. These represent lower-threshold neurological activity that:

1. Demonstrates the neurological process is more continuous than full episodes suggest
2. May share the same trigger correlations as full episodes at lower threshold
3. Is clinically relevant for SPS evaluation — continuous motor unit activity between spasms is a feature of SPS that standard EMG missed because the SPS-specific co-contraction protocol was not used
4. The left-sided pattern of sub-episode events (left intercostal spasms, left facial tingling, left arm involvement) has diagnostic significance and needs longitudinal documentation

The muscle event log captures these with minimal user burden — single screen, 3-4 taps, auto-populated weather.

---

## Data the App Will Generate for Specialist Use

After 4-6 weeks of consistent logging the app will produce:

**For neurology:**
- Episode frequency and trend
- Prodromal sequence documented across multiple events
- Limb distribution pattern (right leg first — consistent with spinal myoclonus origin)
- Environmental conditions at time of every event (pressure, temperature, trend)
- Post-event functional state (cane requirement, weakness duration, myalgia duration)
- Sub-episode muscle event frequency and distribution
- Communication capacity as severity proxy across events

**For rheumatology:**
- Symptom fluctuation correlated with hormonal cycle
- Post-exertional malaise pattern and delayed crash timing
- Functional impact trend (work capacity, nap frequency, cancelled plans)
- Heat therapy effectiveness as symptom management data

**For autonomic neurology:**
- Pressure sensitivity threshold documentation
- Temperature trigger pattern (delta not absolute)
- Fasting threshold for symptom onset
- Compound trigger analysis

**For spine surgery evaluation:**
- Right-sided symptom distribution over time
- Breathing and swallowing difficulty event frequency
- Correlation between neck pain days and neurological event frequency

---

## Limitations and What the App Cannot Do

The app generates observational data, not diagnostic data. It cannot replace:
- Anti-GAD65 antibody testing (primary SPS marker — not yet ordered)
- Tilt-table test (POTS evaluation — not yet ordered)
- Lumbar spine MRI (never performed)
- SPS-protocol EMG (not yet performed with correct protocol)
- Rheumatology panel (anti-Ro/SSA, anti-La/SSB, anti-Sm, anti-U1 RNP — not yet ordered)
- Formal sleep study (referred but never attended)
- Orthostatic vital signs (never formally measured)

The app data supports urgency of all of the above by establishing the pattern, frequency, and severity of symptoms that these tests are needed to evaluate.

---

## Summary Statement for Clinicians

This application was built because the patient's symptom burden, diagnostic complexity, and the absence of coordinating care created a situation where the most important clinical information — what is actually happening in her daily life — was not being captured or communicated effectively.

The data this app generates is not anecdotal. It is structured, time-stamped, environmentally contextualized, and captured using assessment methods validated for autistic adults. It represents what clinical monitoring would show if monitoring were possible in her daily environment.

The goal is not self-diagnosis. The goal is to give the specialists evaluating this patient the longitudinal objective data they need to make informed diagnostic and treatment decisions — data that the fragmented specialist system has not been generating on its own.

---

*Built April 2026. Patient: Cotopaxi Lyon, Marquette MI.*
*App repository: https://github.com/cotopaxilyon/Isobar*

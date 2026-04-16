# UAT Write-Up — Ticket 9A: Remove Patient Name from Header

**Date:** 2026-04-15
**Environment:** http://localhost:8000 (local dev)
**Execution:** Automated (Playwright spec uat-wave-1.spec.ts)
**Scenarios tested:** 4 | **Pass:** 4 | **Fail:** 0 | **Blocked:** 0

## Result: ALL PASS

### Scenario 1: PASS
As a user on the home screen after PIN entry, when I look at the top-left of the header, then I see "Isobar" in small uppercase monospace text and there is no large title element below it.

**Evidence:** Assertion passed — `#view-home .page-subtitle` contains "Isobar"; `#view-home .page-title` has count 0.

### Scenario 2: PASS
As a user on the home screen, when I inspect the page content, then there is no "Cotopaxi" text anywhere in the home view.

**Evidence:** Assertion passed — `#view-home` textContent does not contain "Cotopaxi".

### Scenario 3: PASS
As a user navigating between views, when I open View Log then I see the header "Log" in large title style; when I open Settings then I see the header "Settings"; when I return home then "Isobar" is still the only text on the left with no page-title element.

**Evidence:** Assertion passed — Log `.page-title` = "Log", Settings `.page-title` = "Settings", Home `.page-subtitle` = "Isobar" with no `.page-title`.

### Scenario 4: PASS
As a user on the home screen at 375px viewport width, when I inspect the header, then the subtitle sits comfortably in the header bar with no horizontal overflow or clipping.

**Evidence:** Assertion passed — scrollWidth <= clientWidth, subtitle boundingBox has positive height.

## Findings

No issues found. All acceptance criteria covered:

- S1: Home screen shows "ISOBAR" only (no large title text)
- S2: No "Cotopaxi" text anywhere on the home screen
- S3: Log and Settings headers unaffected
- S4: Header layout integrity at 375px — no overflow or clipping

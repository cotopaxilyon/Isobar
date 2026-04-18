#!/usr/bin/env node
// Validates an autopilot dossier (docs/autopilot/<ticket>.dossier.json) against
// the schema the /autopilot harness requires. Exits non-zero on any missing or
// malformed field. No deps; runs on Node 18+.
//
// Usage:
//   node scripts/autopilot/validate-dossier.mjs docs/autopilot/ISO-21.dossier.json
//   node scripts/autopilot/validate-dossier.mjs --critic docs/autopilot/ISO-21.critic.json

import { readFileSync } from 'node:fs';
import { argv, exit } from 'node:process';

const errors = [];
const warns = [];

const args = argv.slice(2);
const isCritic = args.includes('--critic');
const path = args.filter(a => !a.startsWith('--'))[0];

if (!path) {
  console.error('usage: validate-dossier.mjs [--critic] <path-to-json>');
  exit(2);
}

let doc;
try {
  doc = JSON.parse(readFileSync(path, 'utf8'));
} catch (e) {
  console.error(`failed to read/parse ${path}: ${e.message}`);
  exit(2);
}

const REQUIRED_DOSSIER = [
  'ticket_id',
  'ticket_url',
  'ticket_labels',
  'picked_at',
  'executor_model',
  'ac_verbatim',
  'ac_paraphrase_check',
  'scope_gate',
  'files_to_touch',
  'adjacent_surfaces',
  'root_cause_one_sentence',
  'approach_chosen',
  'approach_alternatives_considered',
  'premortem_embarrassment',
  'drift_tripwire_grep',
  'self_qa_plan',
  'confidence',
  'confidence_justification',
  'decision',
];

const REQUIRED_CRITIC = [
  'ticket_id',
  'critic_model',
  'executor_decision',
  'critic_decision',
  'agreement',
  'disagreements',
  'would_have_chosen_same_approach',
  'approach_critique',
];

const required = isCritic ? REQUIRED_CRITIC : REQUIRED_DOSSIER;

function require(key, predicate, msg) {
  if (!predicate(doc[key])) errors.push(`${key}: ${msg}`);
}

const isStr = v => typeof v === 'string' && v.trim().length > 0;
const isNonEmptyArr = v => Array.isArray(v) && v.length > 0;
const isArr = v => Array.isArray(v);
const isBool = v => typeof v === 'boolean';
const isNum = v => typeof v === 'number' && !Number.isNaN(v);

for (const key of required) {
  if (!(key in doc)) errors.push(`missing required field: ${key}`);
}

if (!isCritic) {
  require('ticket_id', v => isStr(v) && /^ISO-\d+$/.test(v), 'must match /^ISO-\\d+$/');
  require('ticket_labels', isNonEmptyArr, 'must be a non-empty array');
  require('ac_verbatim', isNonEmptyArr, 'must list at least one AC, quoted verbatim from the ticket');
  require('ac_paraphrase_check', isStr, 'must explicitly affirm no paraphrase was used');
  require('scope_gate', isNonEmptyArr, 'must list at least one scope-gate row');
  require('files_to_touch', isNonEmptyArr, 'must list at least one file');
  require('adjacent_surfaces', isArr, 'must be an array (empty allowed only with explicit justification)');
  require('root_cause_one_sentence', v => isStr(v) && v.length < 280, 'must be a single sentence (< 280 chars)');
  require('approach_chosen', isStr, 'must name the chosen approach');
  require('approach_alternatives_considered', isArr, 'must list alternatives considered (empty array if none — say so)');
  require('premortem_embarrassment', v => isStr(v) && v.length >= 80, 'must be a substantive named failure mode (>= 80 chars)');
  require('drift_tripwire_grep', isNonEmptyArr, 'must list at least one post-implementation tripwire');
  require('confidence', v => isNum(v) && v >= 0 && v <= 100, 'must be a number 0..100');
  require('confidence_justification', isStr, 'must justify the confidence number');
  require('decision', v => ['proceed', 'bail-out', 'needs-clarification'].includes(v), 'must be one of: proceed, bail-out, needs-clarification');

  // structural checks on nested arrays
  if (Array.isArray(doc.scope_gate)) {
    doc.scope_gate.forEach((row, i) => {
      ['rule', 'evidence_cmd', 'result', 'verdict'].forEach(k => {
        if (!isStr(row?.[k])) errors.push(`scope_gate[${i}].${k} missing or not a string`);
      });
      if (!['pass', 'fail'].includes(row?.verdict)) {
        errors.push(`scope_gate[${i}].verdict must be 'pass' or 'fail'`);
      }
    });
  }

  if (Array.isArray(doc.adjacent_surfaces)) {
    doc.adjacent_surfaces.forEach((row, i) => {
      ['string_or_symbol', 'grep_cmd'].forEach(k => {
        if (!isStr(row?.[k])) errors.push(`adjacent_surfaces[${i}].${k} missing or not a string`);
      });
      if (!Array.isArray(row?.all_call_sites)) {
        errors.push(`adjacent_surfaces[${i}].all_call_sites must be an array`);
      }
    });
  }

  if (Array.isArray(doc.drift_tripwire_grep)) {
    doc.drift_tripwire_grep.forEach((row, i) => {
      ['name', 'cmd', 'expected'].forEach(k => {
        if (!isStr(row?.[k])) errors.push(`drift_tripwire_grep[${i}].${k} missing or not a string`);
      });
    });
  }

  if (doc.decision === 'proceed') {
    const failingScope = (doc.scope_gate || []).filter(r => r?.verdict === 'fail');
    if (failingScope.length > 0) {
      errors.push(`decision is 'proceed' but ${failingScope.length} scope_gate row(s) failed; should be 'bail-out'`);
    }
  }

  if (typeof doc.confidence === 'number' && doc.confidence < 70 && doc.decision === 'proceed') {
    warns.push(`confidence ${doc.confidence} < 70 with decision 'proceed' — consider bail-out or needs-clarification`);
  }
} else {
  require('ticket_id', v => isStr(v) && /^ISO-\d+$/.test(v), 'must match /^ISO-\\d+$/');
  require('agreement', isBool, 'must be boolean');
  require('disagreements', isArr, 'must be an array (empty if agreement true)');
  require('would_have_chosen_same_approach', isBool, 'must be boolean');
  require('approach_critique', isStr, 'must be a string (one line if approach matched)');

  if (doc.agreement === true && Array.isArray(doc.disagreements) && doc.disagreements.length > 0) {
    errors.push(`agreement: true but disagreements[] is non-empty — these contradict`);
  }
  if (doc.agreement === false && Array.isArray(doc.disagreements) && doc.disagreements.length === 0) {
    errors.push(`agreement: false but disagreements[] is empty — explain or flip agreement`);
  }
  if (Array.isArray(doc.disagreements)) {
    doc.disagreements.forEach((d, i) => {
      ['field', 'executor_value', 'critic_value', 'reason', 'severity'].forEach(k => {
        if (d?.[k] === undefined || d?.[k] === null || d?.[k] === '') {
          errors.push(`disagreements[${i}].${k} missing or empty`);
        }
      });
    });
  }
}

if (warns.length) {
  for (const w of warns) console.warn(`warn: ${w}`);
}

if (errors.length) {
  console.error(`\nvalidation FAILED (${errors.length} error${errors.length === 1 ? '' : 's'}):`);
  for (const e of errors) console.error(`  - ${e}`);
  exit(1);
}

console.log(`ok: ${path}${isCritic ? ' (critic)' : ' (dossier)'}`);
exit(0);

## MODIFIED Requirements

### Requirement: Emit normalized event schema
The system MUST produce a table where each row represents a single membership event and includes the organization metadata (`name`, `identifier`, `site`, `created`), event type, event date in ISO format, and a current-state flag.

#### Scenario: Required columns and date format
- **WHEN** the history table is generated
- **THEN** each row MUST include `name`, `identifier`, `site`, `created`, `evento`, `data`, `corrente`
- **THEN** `data` MUST be formatted as `YYYY-MM-DD`

#### Scenario: Current-state flag based on latest snapshot
- **WHEN** a row is evaluated against the latest revision of `docs/datasetDatiGovIt/organizzazioni.jsonl`
- **THEN** `corrente` MUST be `1` if the pair (`name`, `identifier`) is present in that latest revision
- **THEN** `corrente` MUST be `0` otherwise

#### Scenario: Re-entry handling
- **WHEN** an organization exits and later re-enters
- **THEN** the system MUST emit multiple rows for the same `name`, preserving each `uscita` and later `ingresso` event

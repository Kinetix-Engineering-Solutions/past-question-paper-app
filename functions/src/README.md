# Functions `src` Architecture

This document describes the modular layout for Cloud Functions in `functions/src`.

## Entrypoints

- `../index.js`
  - Thin root entrypoint that exports from `./src/app`.
- `app.js`
  - Aggregates all deployed function exports.

Current exported functions:
- `generateTest`
- `gradeTest`
- `onUserDeleteCleanup`

## Folder Layout

- `core/`
  - `firebase.js`: shared Firebase Admin initialization (`admin.initializeApp()` once).

- `helpers/`
  - Shared helper utilities/validators used across modules.

- `modules/`
  - `test_generation/`
    - `controller.js`: callable function handler for test generation.
    - `services/`: test generation business logic.
      - `test.service.js`
      - `enhancedTest.service.js`
      - `shortAnswerTest.service.js`
      - `__tests__/enhancedTest.service.test.js`

  - `grading/`
    - `controller.js`: callable function handler for grading.
    - `services/`: grading business logic.
      - `grading.service.js`
      - `shortAnswerGrading.service.js`

  - `user_lifecycle/`
    - `controller.js`: auth trigger wiring.
    - `cleanup.service.js`: account cleanup logic.

  - `shared/`
    - Shared Firestore/data access services consumed by multiple modules.
      - `database.service.js`
      - `shortAnswerSingleDoc.service.js`
      - `shortAnswerDatabase.service.js`

## Dependency Rules

To keep the structure maintainable:

1. Controllers should orchestrate request validation/auth/rate-limiting and call services.
2. Services should contain domain/business logic and call shared services/helpers.
3. Shared services should avoid depending on module-specific controllers.
4. `core/firebase.js` is the single source of Admin initialization.

## Request Flow

### `generateTest`
1. `modules/test_generation/controller.js`
2. Validates auth + request constraints
3. Calls `modules/test_generation/services/test.service.js`
4. Uses `modules/shared/database.service.js` as needed
5. Returns sanitized question payload

### `gradeTest`
1. `modules/grading/controller.js`
2. Validates auth + submission constraints
3. Calls `modules/grading/services/grading.service.js`
4. Uses shared database services and short-answer grading service
5. Returns results + statistics

### `onUserDeleteCleanup`
1. `modules/user_lifecycle/controller.js`
2. Calls `modules/user_lifecycle/cleanup.service.js`
3. Removes user-owned Firestore + Storage data

## Notes

- Legacy `src/services/` has been retired in favor of module-local `services/` plus `modules/shared/`.
- Tooling scripts under `functions/tools/` should import module services via `src/modules/...` paths.

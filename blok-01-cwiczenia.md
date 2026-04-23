# Blok 1: Cwiczenia - Pipeline as Code, GitHub Actions

## Cwiczenie 1.1: Pierwszy workflow GitHub Actions

### Cel
Utworzenie repozytorium z dzialajacym CI pipeline w GitHub Actions.

### Przygotowanie
```bash
mkdir -p ~/cicd-lab
cd ~/cicd-lab

# Utworz nowe repo na GitHub (przez UI lub gh CLI)
gh repo create cicd-devops-lab --public --clone
cd cicd-devops-lab
```

### Zadania

**a) Utworz prosta aplikacje Node.js:**

```bash
npm init -y
```

Utworz `index.js`:
```javascript
function add(a, b) {
  return a + b;
}

function subtract(a, b) {
  return a - b;
}

function multiply(a, b) {
  return a * b;
}

function divide(a, b) {
  if (b === 0) throw new Error("Division by zero");
  return a / b;
}

module.exports = { add, subtract, multiply, divide };
```

Utworz `index.test.js`:
```javascript
const { add, subtract, multiply, divide } = require("./index");

describe("Calculator", () => {
  test("add", () => expect(add(2, 3)).toBe(5));
  test("subtract", () => expect(subtract(5, 3)).toBe(2));
  test("multiply", () => expect(multiply(3, 4)).toBe(12));
  test("divide", () => expect(divide(10, 2)).toBe(5));
  test("divide by zero", () => expect(() => divide(1, 0)).toThrow());
});
```

```bash
npm install --save-dev jest
```

Dodaj do `package.json`:
```json
{
  "scripts": {
    "test": "jest",
    "test:coverage": "jest --coverage"
  }
}
```

```bash
# Sprawdz lokalnie
npm test
```

**b) Utworz pierwszy workflow:**

Utworz `.github/workflows/ci.yml`:
```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run tests
        run: npm test
```

```bash
git add .
git commit -m "feat: initial CI pipeline"
git push origin main
```

**c) Sprawdz wyniki:**
- Wejdz na GitHub > repo > Actions
- Powinien byc widoczny workflow "CI" z zielonym checkmarkiem
- Kliknij w workflow i przejrzyj logi kazdego stepu

**d) Dodaj badge do README:**

Utworz `README.md`:
```markdown
# CI/CD DevOps Lab

![CI](https://github.com/<YOUR_USERNAME>/cicd-devops-lab/actions/workflows/ci.yml/badge.svg)
```

```bash
git add README.md
git commit -m "docs: add CI badge"
git push
```

---

## Cwiczenie 1.2: Workflow z wieloma jobami i zaleznosci

### Cel
Pipeline z lint, test, build jako osobne joby z zaleznosci.

### Zadania

**a) Dodaj ESLint:**

```bash
npm install --save-dev eslint
```

Utworz `eslint.config.mjs`:
```javascript
export default [
  {
    rules: {
      "no-unused-vars": "error",
      "no-console": "warn",
      eqeqeq: "error",
    },
  },
];
```

Dodaj do `package.json` scripts:
```json
{
  "scripts": {
    "lint": "eslint .",
    "test": "jest",
    "test:coverage": "jest --coverage",
    "build": "echo 'Build successful'"
  }
}
```

**b) Rozbuduj workflow o wiele jobow:**

Zaktualizuj `.github/workflows/ci.yml`:
```yaml
name: CI Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm run lint

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm run test:coverage

      - name: Upload coverage
        uses: actions/upload-artifact@v4
        with:
          name: coverage-report
          path: coverage/
          retention-days: 5

  build:
    needs: [lint, test]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm run build

      - name: Upload build artifact
        uses: actions/upload-artifact@v4
        with:
          name: build-output
          path: |
            index.js
            package.json
          retention-days: 5
```

```bash
git add .
git commit -m "feat: multi-job CI pipeline with lint, test, build"
git push
```

**c) Sprawdz na GitHub:**
- Actions > CI Pipeline
- Powinny byc 3 joby: lint i test rownolegle, build po nich
- Sprawdz graf zaleznosci (widok wizualny)
- Pobierz artefakt coverage-report

---

## Cwiczenie 1.3: Matrix strategy

### Cel
Testowanie na wielu wersjach Node.js i systemach operacyjnych.

### Zadania

**a) Dodaj matrix do workflow:**

Utworz `.github/workflows/matrix-test.yml`:
```yaml
name: Matrix Test

on:
  push:
    branches: [main]
  pull_request:

jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      fail-fast: false
      matrix:
        os: [ubuntu-latest, macos-latest]
        node: [18, 20, 22]
        exclude:
          - os: macos-latest
            node: 18
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js ${{ matrix.node }}
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node }}
          cache: 'npm'

      - run: npm ci
      - run: npm test

      - name: Report
        if: always()
        run: |
          echo "OS: ${{ matrix.os }}"
          echo "Node: ${{ matrix.node }}"
          echo "Status: ${{ job.status }}"
```

```bash
git add .
git commit -m "feat: matrix testing across OS and Node versions"
git push
```

**b) Sprawdz wyniki:**
- Actions > Matrix Test
- Powinno byc 5 jobow (2 OS x 3 Node - 1 excluded)
- Sprawdz czy wszystkie przeszly
- Zwroc uwage na czas wykonania na roznych OS

---

## Cwiczenie 1.4: Secrets, zmienne srodowiskowe i konteksty

### Cel
Praca z secrets, zmiennymi i kontekstami GitHub Actions.

### Zadania

**a) Dodaj secret do repozytorium:**
- GitHub > repo > Settings > Secrets and variables > Actions
- New repository secret: `DEPLOY_TOKEN` = `my-secret-deploy-token-123`

**b) Utworz workflow uzywajacy secrets i kontekstow:**

Utworz `.github/workflows/env-and-secrets.yml`:
```yaml
name: Environment and Secrets Demo

on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Target environment'
        required: true
        type: choice
        options:
          - development
          - staging
          - production
      debug:
        description: 'Enable debug mode'
        type: boolean
        default: false

env:
  APP_NAME: cicd-devops-lab
  GLOBAL_VAR: "I am global"

jobs:
  show-context:
    runs-on: ubuntu-latest
    env:
      JOB_VAR: "I am job-level"
    steps:
      - name: GitHub context
        run: |
          echo "Repository: ${{ github.repository }}"
          echo "Branch: ${{ github.ref_name }}"
          echo "SHA: ${{ github.sha }}"
          echo "Actor: ${{ github.actor }}"
          echo "Event: ${{ github.event_name }}"
          echo "Run ID: ${{ github.run_id }}"
          echo "Run number: ${{ github.run_number }}"

      - name: Input parameters
        run: |
          echo "Environment: ${{ inputs.environment }}"
          echo "Debug: ${{ inputs.debug }}"

      - name: Environment variables
        env:
          STEP_VAR: "I am step-level"
        run: |
          echo "Global: $GLOBAL_VAR"
          echo "Job: $JOB_VAR"
          echo "Step: $STEP_VAR"
          echo "App: $APP_NAME"

      - name: Use secret (masked in logs)
        env:
          TOKEN: ${{ secrets.DEPLOY_TOKEN }}
        run: |
          echo "Token length: ${#TOKEN}"
          # Secret jest maskowany - nie wyswietli sie w logach
          echo "Token: $TOKEN"

      - name: Conditional step
        if: ${{ inputs.debug == true }}
        run: echo "Debug mode is ON"

      - name: Set output
        id: version
        run: echo "value=1.0.${{ github.run_number }}" >> $GITHUB_OUTPUT

      - name: Use output
        run: echo "Version: ${{ steps.version.outputs.value }}"
```

```bash
git add .
git commit -m "feat: environment and secrets demo workflow"
git push
```

**c) Uruchom workflow manualnie:**
- Actions > Environment and Secrets Demo > Run workflow
- Wybierz environment: staging, debug: true
- Sprawdz logi - zwroc uwage na maskowanie secretu

---

## Cwiczenie 1.5: Reusable Workflows i Composite Actions

### Cel
Tworzenie reusable komponentow - DRY w pipeline.

### Zadania

**a) Utworz Composite Action:**

Utworz `.github/actions/setup-and-test/action.yml`:
```yaml
name: 'Setup and Test'
description: 'Setup Node.js, install dependencies, run tests'

inputs:
  node-version:
    description: 'Node.js version'
    required: false
    default: '20'
  run-coverage:
    description: 'Run with coverage'
    required: false
    default: 'false'

outputs:
  test-result:
    description: 'Test result status'
    value: ${{ steps.test.outputs.result }}

runs:
  using: 'composite'
  steps:
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: ${{ inputs.node-version }}
        cache: 'npm'

    - name: Install dependencies
      shell: bash
      run: npm ci

    - name: Run tests
      id: test
      shell: bash
      run: |
        if [ "${{ inputs.run-coverage }}" = "true" ]; then
          npm run test:coverage
        else
          npm test
        fi
        echo "result=success" >> $GITHUB_OUTPUT
```

**b) Utworz Reusable Workflow:**

Utworz `.github/workflows/reusable-ci.yml`:
```yaml
name: Reusable CI

on:
  workflow_call:
    inputs:
      node-version:
        required: false
        type: string
        default: '20'
      run-lint:
        required: false
        type: boolean
        default: true
    outputs:
      test-passed:
        description: 'Whether tests passed'
        value: ${{ jobs.ci.outputs.test-result }}

jobs:
  ci:
    runs-on: ubuntu-latest
    outputs:
      test-result: ${{ steps.test.outputs.result }}
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: ${{ inputs.node-version }}
          cache: 'npm'

      - run: npm ci

      - name: Lint
        if: ${{ inputs.run-lint }}
        run: npm run lint

      - name: Test
        id: test
        run: |
          npm test
          echo "result=passed" >> $GITHUB_OUTPUT
```

**c) Uzyj obu w glownym workflow:**

Utworz `.github/workflows/main-pipeline.yml`:
```yaml
name: Main Pipeline

on:
  push:
    branches: [main]

jobs:
  # Uzycie Composite Action
  quick-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run tests with composite action
        uses: ./.github/actions/setup-and-test
        with:
          node-version: '20'
          run-coverage: 'true'

  # Uzycie Reusable Workflow
  full-ci:
    uses: ./.github/workflows/reusable-ci.yml
    with:
      node-version: '20'
      run-lint: true

  # Job zalezny od reusable workflow
  report:
    needs: [quick-test, full-ci]
    runs-on: ubuntu-latest
    steps:
      - name: Report
        run: |
          echo "Quick test: done"
          echo "Full CI test result: ${{ needs.full-ci.outputs.test-passed }}"
          echo "All checks passed!"
```

```bash
git add .
git commit -m "feat: reusable workflows and composite actions"
git push
```

**d) Sprawdz na GitHub:**
- Actions > Main Pipeline
- Powinny byc 3 joby: quick-test, full-ci, report
- Sprawdz jak reusable workflow wyglada w grafie

---

## Cwiczenie 1.6: Pull Request workflow z automatycznym review

### Cel
Workflow uruchamiany na PR z komentarzem wynikow.

### Zadania

**a) Utworz PR workflow:**

Utworz `.github/workflows/pr-check.yml`:
```yaml
name: PR Check

on:
  pull_request:
    branches: [main]

permissions:
  contents: read
  pull-requests: write

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - run: npm ci

      - name: Lint
        id: lint
        run: |
          npm run lint 2>&1 | tee lint-output.txt
          echo "status=$?" >> $GITHUB_OUTPUT
        continue-on-error: true

      - name: Test with coverage
        id: test
        run: |
          npm run test:coverage 2>&1 | tee test-output.txt
          echo "status=$?" >> $GITHUB_OUTPUT
        continue-on-error: true

      - name: Comment PR
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const lintOutput = fs.readFileSync('lint-output.txt', 'utf8');
            const testOutput = fs.readFileSync('test-output.txt', 'utf8');

            const lintStatus = '${{ steps.lint.outcome }}' === 'success' ? '✅' : '❌';
            const testStatus = '${{ steps.test.outcome }}' === 'success' ? '✅' : '❌';

            const body = `## CI Results

            | Check | Status |
            |-------|--------|
            | Lint | ${lintStatus} |
            | Tests | ${testStatus} |

            <details>
            <summary>Test Output</summary>

            \`\`\`
            ${testOutput.slice(-2000)}
            \`\`\`
            </details>
            `;

            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: body
            });

      - name: Fail if checks failed
        if: steps.lint.outcome == 'failure' || steps.test.outcome == 'failure'
        run: exit 1
```

**b) Przetestuj na PR:**
```bash
git checkout -b feature/test-pr
echo "// new feature" >> index.js
git add .
git commit -m "feat: test PR workflow"
git push origin feature/test-pr
```

- Utworz PR na GitHub (feature/test-pr -> main)
- Sprawdz czy workflow sie uruchomil
- Sprawdz komentarz z wynikami na PR

---

## Cwiczenie 1.7: Rozwiaz samodzielnie

### Zadanie A: Scheduled workflow z notyfikacja

Wykonaj nastepujace kroki:
1. Utworz workflow `nightly.yml` uruchamiany codziennie o 2:00 UTC (cron)
2. Workflow powinien: checkout, install, run tests, run lint
3. Dodaj step ktory tworzy GitHub Issue jesli testy failuja (uzyj `actions/github-script`)
4. Dodaj `workflow_dispatch` zeby mozna bylo uruchomic recznie
5. Przetestuj uruchamiajac recznie

### Zadanie B: Workflow z cache i artefaktami

Wykonaj nastepujace kroki:
1. Dodaj do projektu prosty build step (np. kopiowanie plikow do `dist/`)
2. Utworz workflow z 3 jobami: install, test, build
3. Job `install` powinien cachowac `node_modules` i przekazac jako artefakt
4. Job `test` pobiera artefakt i uruchamia testy
5. Job `build` pobiera artefakt i buduje
6. Zmierz czas z cache vs bez cache (usun cache w Settings > Actions > Caches)

### Zadanie C: Dynamic matrix z JSON

Wykonaj nastepujace kroki:
1. Utworz plik `test-matrix.json` z konfiguracja:
   ```json
   {
     "include": [
       {"os": "ubuntu-latest", "node": 20, "name": "Ubuntu Node 20"},
       {"os": "ubuntu-latest", "node": 22, "name": "Ubuntu Node 22"},
       {"os": "macos-latest", "node": 22, "name": "macOS Node 22"}
     ]
   }
   ```
2. Utworz workflow ktory czyta matrix z pliku JSON
3. Uzyj `fromJSON()` do dynamicznego generowania matrix
4. Kazdy job powinien wyswietlic swoja nazwe z matrix

### Zadanie D: Branch protection i required checks

Wykonaj nastepujace kroki:
1. W Settings > Branches > Add rule dla `main`:
   - Require pull request reviews (1 reviewer)
   - Require status checks to pass (wybierz "test" job)
   - Require branches to be up to date
2. Sprobuj pushowac bezposrednio na main - powinno byc zablokowane
3. Utworz PR, poczekaj na CI, zmerguj

> Rozwiazania: [rozwiazania/blok-01-rozwiazania.md](../rozwiazania/blok-01-rozwiazania.md)

---

## Zadanie koncowe bloku 1

Zbuduj kompletny CI pipeline dla aplikacji Node.js:

1. Workflow `ci.yml` triggerowany na push (main, develop) i PR (main)
2. Job `lint` - ESLint
3. Job `test` - Jest z coverage, upload coverage jako artefakt
4. Job `build` - zalezy od lint i test, buduje aplikacje
5. Matrix: Node 20 i 22 na Ubuntu
6. Composite Action `.github/actions/node-setup/` - setup Node + install deps (reusable)
7. Uzyj composite action we wszystkich jobach
8. PR workflow z komentarzem wynikow
9. `workflow_dispatch` z inputem `node-version` (choice: 18, 20, 22)

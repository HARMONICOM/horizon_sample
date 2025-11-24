# AGENTS.md

This document provides guidelines for AI agents to understand and appropriately assist with this Zig project.


## Project Overview

This project is a sample application demonstrating the "Horizon" web framework and "Dig" ORM written in Zig. It includes a full-stack application with a Zig backend and a React frontend.


## Technology Stack

### Backend
- **Language**: Zig 0.15.2
- **Framework**: Horizon web framework
- **ORM**: Dig ORM mapper
- **Database Drivers**: PostgreSQL (enabled by default), MySQL (optional)

### Frontend
- **Language**: TypeScript
- **Framework**: React 19
- **Build Tool**: Vite
- **Runtime**: Bun
- **UI Libraries**: Material-UI, TailwindCSS, DaisyUI
- **Testing**: Playwright (E2E tests)

### Infrastructure
- **Container**: Docker (Based on Debian Trixie Slim)
- **Orchestration**: Docker Compose
- **Databases**: PostgreSQL, MySQL
- **Cache**: Redis
- **External Dependencies**:
  - PCRE2 (libpcre2-dev) - Regular expression processing library
  - libpq-dev - PostgreSQL client library


## Project Structure

```
.
├── compose.yml                  # Docker Compose configuration
├── compose.override.sample.yml # Sample override compose.yml file
├── compose.override.yml         # Local override (gitignored)
├── infra/                       # Infrastructure definitions
│   └── docker/
│       ├── app/                 # App container
│       │   └── Dockerfile
│       ├── cache/               # Redis container
│       │   └── redis.conf
│       ├── mysql/               # MySQL container
│       │   ├── Dockerfile
│       │   ├── my.cnf
│       │   └── docker-entrypoint-initdb.d/
│       └── pg/                  # PostgreSQL container
│           ├── Dockerfile
│           ├── postgresql.conf
│           └── docker-entrypoint-initdb.d/
├── src/                         # Backend source code
│   ├── main.zig                 # Application entry point
│   ├── root.zig                 # Root module wiring
│   ├── models/                  # Data models
│   │   └── users.zig
│   ├── routes/                  # Route handlers
│   │   ├── admin/               # Admin routes
│   │   ├── api/                 # API routes
│   │   ├── index.zig
│   │   └── routes.zig
│   ├── utils/                   # Utilities
│   │   └── db.zig
│   └── views/                   # View templates
│       ├── admin/
│       └── index.zts
├── frontend/                    # Frontend source code
│   ├── admin/                   # Admin frontend
│   │   ├── admin.tsx
│   │   ├── login.tsx
│   │   ├── changePassword.tsx
│   │   ├── routes.tsx
│   │   └── index.css
│   ├── index.tsx                # Main frontend entry
│   └── routes.tsx
├── public/                      # Served build artifacts
│   ├── assets/                  # Bundled vendor JS/CSS
│   ├── index.js
│   ├── script.js
│   ├── static.html
│   └── styles.css
├── static/                      # Raw static files
│   ├── assets/
│   ├── script.js
│   ├── static.html
│   └── styles.css
├── database/                    # Database files
│   ├── migrations/              # Migration SQL files
│   │   └── *.sql
│   └── seeders/                 # Seeder SQL files
│       ├── development/
│       └── production/
├── tests/                       # Test files
│   ├── backend/                 # Backend test files (Zig)
│   ├── frontend/                # Frontend test files (TypeScript)
│   └── e2e/                     # E2E test files (Playwright)
├── dig/                         # Dig ORM module (dependency)
├── horizon/                     # Horizon framework module (dependency)
├── node_modules/                # Node.js dependencies
├── zig-out/                     # Build output directory
│   └── bin/
│       ├── horizon_sample
│       ├── migrate
│       └── seeder
├── build.zig                    # Zig build configuration
├── build.zig.zon                # Zig module definition
├── package.json                 # Frontend tooling config
├── bun.lock                     # Bun dependency lockfile
├── tsconfig.json                # TypeScript config
├── eslint.config.ts             # ESLint shared config
├── vite.config.ts               # Vite dev server config
├── Makefile                     # Make execution configuration
└── AGENTS.md                    # This file
```


## Build and Execution

### Initial Setup

```bash
# Copy compose override file and build containers
make setup

# Start all services
make up
```

The application will be accessible at `http://localhost:5000/`.

### Build Environment Using Docker Compose

```bash
# Build and start container
make up

# Open shell in container
make run bash

# Check Zig version
make zig version

# Use formatter
make zig fmt [target directory]

# Build backend
make zig build [target (all if omitted)]

# Execute backend
make zig build run
```

**Note:** Error code `Error 3` indicates normal termination

### Frontend Development

```bash
# Build frontend
make front-build

# Lint frontend code
make front-lint

# Run frontend tests
make front-test
```

### Database Operations

```bash
# Run migrations (using Dig migrate tool)
make run zig-out/bin/migrate up

# Run seeders (using Dig seeder tool)
make run zig-out/bin/seeder development

# Reset databases (removes volumes)
make resetdb
```

### E2E Testing

```bash
# Run E2E tests (Chromium only)
make e2e

# Run E2E tests (all browsers)
make e2e-all
```

Note: "Error 3" is normal.


## Development Guidelines

### Zig Coding Conventions

1. **Naming Rules**
   - Functions: `PascalCase` (e.g., `HandleRequest`)
   - Types: `PascalCase` (e.g., `HttpServer`)
   - Constants: `SCREAMING_SNAKE_CASE` (e.g., `MAX_CONNECTIONS`)
   - Variables: `snake_case` (e.g., `request_count`)
   - File names: `camelCase` (e.g., `loggingMiddleware.zig`) *Test files should end with `_test.zig`

2. **Error Handling**
   - Actively use Zig's error handling features
   - Use `!` type to handle errors explicitly
   - Use `try` and `catch` appropriately

3. **Memory Management**
   - Be conscious of explicit memory management
   - Choose allocators appropriately (`std.heap.page_allocator`, `std.heap.ArenaAllocator`, etc.)
   - Avoid memory leaks

4. **Comments**
   - Use `///` for documentation comments on public APIs
   - Add inline comments for complex logic
   - Write all comments in English

5. **Other**
   - Refer to `.editorconfig` for indentation and other EditorConfig settings

### TypeScript/React Coding Conventions

1. **Naming Rules**
   - Components: `PascalCase` (e.g., `UserProfile`)
   - Functions: `PascalCase` (e.g., `HandleSubmit`)
   - Constants: `SCREAMING_SNAKE_CASE` (e.g., `API_BASE_URL`)
   - Variables: `camelCase` (e.g., `userName`)

2. **Code Style**
   - Follow ESLint configuration in `eslint.config.ts`
   - Use TypeScript for type safety
   - Prefer functional components with hooks

3. **Comments**
   - Write all comments in English
   - Use JSDoc for function documentation

### File Structure Example

```
src/
├── main.zig               # Application entry point
├── root.zig               # Root module wiring
├── models/                # Data models
│   └── users.zig
├── routes/                # Route handlers
│   ├── admin/             # Admin routes
│   ├── api/               # API routes
│   ├── index.zig
│   └── routes.zig
├── utils/                 # Utilities
│   └── db.zig
└── views/                 # View templates
    ├── admin/
    └── index.zts
```


## Dependencies

### External Libraries

#### Backend
- **PCRE2** (libpcre2-dev): For regular expression processing
  - Used for path parameter regex matching
  - Included in Docker container
  - Linked as a C library
- **PostgreSQL** (libpq-dev): PostgreSQL client library
  - Used for database connectivity
  - Included in Docker container

#### Frontend
- **React**: UI framework
- **Material-UI**: Component library
- **TailwindCSS**: Utility-first CSS framework
- **DaisyUI**: TailwindCSS component library
- **Vite**: Build tool and dev server
- **Playwright**: E2E testing framework

### Build Configuration

Frontend dependencies are managed in `package.json` and installed via Bun.

When adding new dependencies:
- Backend: Manage in `build.zig` or `build.zig.zon`
- Frontend: Add to `package.json` and run `bun install`


## Environment Configuration

The project uses Docker Compose with environment-specific overrides:

1. Copy `compose.override.sample.yml` to `compose.override.yml`
2. Configure environment variables in `compose.override.yml`:
   - Database connection settings
   - Redis connection settings
   - Application settings

**Note:** `compose.override.yml` is gitignored and should not be committed.


## Debugging

### Log Output

Check Docker Compose logs:

```bash
# All services
make logs

# Specific service
make logs app
```

### Debugging in Container

```bash
# Zig debug build
make zig build -Doptimize=Debug

# Open shell in container
make run bash
```

### Frontend Debugging

```bash
# Run Vite dev server (if configured)
make bun run dev
```


## Performance

- Use `-Doptimize=ReleaseFast` or `-Doptimize=ReleaseSafe` for release builds
- Use appropriate tools for profiling when needed
- Frontend builds are optimized by Vite automatically


## Formatter

### Backend

Use Zig's standard formatter:

```bash
# Run formatter
make zig fmt .
```

### Frontend

ESLint handles formatting:

```bash
# Format and fix issues
make front-lint
```


## Testing

### Backend Tests

Backend test files are located in `tests/backend/`. Use Zig's standard testing framework:

```bash
# Run all tests
make zig build test

# Run specific test file
make zig build test tests/backend/[test_file].zig
```

### Frontend Tests

Frontend test files are located in `tests/frontend/`:

```bash
# Run unit tests
make front-test
```

### E2E Tests

E2E test files are located in `tests/e2e/`:

```bash
# Run E2E tests (Chromium only)
make e2e

# Run E2E tests (all browsers)
make e2e-all
```


## Database Migrations and Seeders

### Migrations

Migration files are located in `database/migrations/`:
- Files are named with timestamp prefix: `YYYYMMDD_description.sql`
- Run migrations using Dig's migrate tool

### Seeders

Seeder files are located in `database/seeders/`:
- Organized by environment: `development/`, `production/`
- Files are numbered: `01_description.sql`, `02_description.sql`
- Run seeders using Dig's seeder tool


## AI Agent Roles

### Understanding Specifications
- **Role**: Read and understand specifications from specification documents
- **Target**: Files under `/docs` directory (if exists)

### Development Support

#### Feature Implementation Agent
- **Role**: Implement features based on specification documents
- **Target**: Feature implementation (both backend and frontend)
- **Execution Command**:
  - Backend: Run `make zig fmt .` after implementation
  - Frontend: Run `make front-lint` after implementation
- **Note**: No need to consider backward compatibility at this point. Remove unnecessary parts
- **Note**: Comment should be written in English
- **Note**: Increment version numbers as well. Version numbers are specified in `build.zig.zon`, `package.json`, `README.md`, and `docs/index.html` (if exists), so update these files

#### Test Implementation Agent
- **Role**: Create unit tests and integration tests
- **Target**:
  - Backend: Test files in `/tests/backend` directory
  - Frontend: Test files in `/tests/frontend` directory
  - E2E: Test files in `/tests/e2e` directory
- **Execution Command**:
  - Backend: `make zig build test` for all tests, `make zig build test tests/backend/[target file]` for individual test files
  - Frontend: `make front-test` for unit tests
  - E2E: `make e2e` for E2E tests (Chromium only), `make e2e-all` for all browsers


## Notes

1. **Zig Version**: This project is developed with Zig 0.15.2
2. **Docker Environment**: It is recommended to develop in Docker containers
3. **Memory Safety**: Zig does not guarantee memory safety, so careful coding is required
4. **Dependencies**: This project depends on local `horizon` and `dig` modules (referenced via paths in `build.zig.zon`)
5. **Database**: Both PostgreSQL and MySQL are available, but PostgreSQL is enabled by default in `build.zig`
6. **Frontend Build**: Frontend is built using Vite and served as static files by the Horizon backend


## Reference Resources

- [Zig Official Documentation](https://ziglang.org/documentation/)
- [Zig Standard Library](https://ziglang.org/documentation/master/std/)
- [Zig Learn](https://ziglearn.org/)
- [React Documentation](https://react.dev/)
- [Vite Documentation](https://vitejs.dev/)
- [Bun Documentation](https://bun.sh/docs)
- [Playwright Documentation](https://playwright.dev/)


## Instructions for AI Agents

When assisting with this project, please note the following:

1. Understand Zig's type system and memory management model
2. Use error handling patterns appropriately
3. Suggest performance-conscious code
4. Prioritize the use of standard library functions
5. Consider operation in container environments
6. Be aware of both backend (Zig) and frontend (TypeScript/React) codebases
7. Understand the relationship between Horizon framework and Dig ORM
8. Consider database migrations and seeders when making schema changes
9. Ensure frontend builds are properly integrated with backend static file serving


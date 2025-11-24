# Horizon sample

Sample project for the Horizon web framework and Dig ORM written in Zig. This is a full-stack application with a Zig backend and a React frontend.

## Technology Stack

### Backend
- **Language**: Zig 0.15.2
- **Framework**: Horizon web framework
- **ORM**: Dig ORM mapper
- **Database Drivers**: PostgreSQL (enabled by default), MySQL (optional)
- **Email**: SMTP client for sending emails

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

## Build and Run

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

## Project Structure

```
.
├── src/
│   ├── main.zig                 # Application entry point
│   ├── root.zig                 # Root module wiring
│   ├── models/                  # Data models
│   │   ├── users.zig
│   │   └── passwordResetTokens.zig
│   ├── routes/                  # Route handlers
│   │   ├── admin/               # Admin routes
│   │   │   ├── dashboard.zig
│   │   │   ├── index.zig
│   │   │   ├── logout.zig
│   │   │   ├── passwordReset.zig
│   │   │   └── routes.zig
│   │   ├── api/                 # API routes
│   │   │   ├── index.zig
│   │   │   ├── routes.zig
│   │   │   └── users.zig
│   │   ├── index.zig
│   │   └── routes.zig
│   ├── utils/                   # Utilities
│   │   ├── db.zig
│   │   └── email.zig
│   └── views/                   # View templates
│       ├── admin/               # Admin views
│       │   ├── dashboard.zts
│       │   ├── index.zts
│       │   ├── logoutComplete.zts
│       │   ├── requestPasswordReset.zts
│       │   └── resetPassword.zts
│       ├── mail/                # Email templates
│       │   ├── passwordResetHtml.zts
│       │   └── passwordResetText.zts
│       └── index.zts
├── frontend/                    # Frontend source code
│   ├── admin/                   # Admin frontend
│   │   ├── admin.tsx
│   │   ├── login.tsx
│   │   ├── logoutComplete.tsx
│   │   ├── requestPasswordReset.tsx
│   │   ├── resetPassword.tsx
│   │   ├── routes.tsx
│   │   └── index.css
│   ├── index.tsx                # Main frontend entry
│   ├── routes.tsx
│   └── index.css
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
│   │   └── 20251122_create_table_users.sql
│   └── seeders/                 # Seeder SQL files
│       ├── development/
│       │   └── 01_seed_users.sql
│       └── production/
│           └── 01_seed_admin.sql
├── tests/                       # Test files
│   ├── backend/                 # Backend test files (Zig)
│   │   ├── db_test.zig
│   │   ├── passwordResetTokens_test.zig
│   │   ├── routes_test.zig
│   │   └── users_test.zig
│   ├── frontend/                # Frontend test files (TypeScript)
│   │   ├── admin.test.tsx
│   │   ├── index.test.tsx
│   │   ├── login.test.tsx
│   │   └── test-utils.tsx
│   └── e2e/                     # E2E test files (Playwright)
│       ├── admin.spec.ts
│       ├── api.spec.ts
│       ├── fixtures.ts
│       └── index.spec.ts
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
│       │       └── 00_create_database.sql
│       └── pg/                  # PostgreSQL container
│           ├── Dockerfile
│           ├── postgresql.conf
│           └── docker-entrypoint-initdb.d/
│               └── 00_create_database.sql
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
├── playwright.config.ts         # Playwright E2E test config
├── compose.yml                  # Base Docker Compose
├── compose.override.sample.yml  # Sample override compose.yml file
├── compose.override.yml         # Local override (gitignored)
├── Makefile                     # Make execution configuration
├── .editorconfig
├── .gitignore
└── README.md                    # This file
```

## Dependencies

### Backend Dependencies

This project depends on the following Zig packages:

- **Horizon**: Web framework for Zig
- **Dig**: ORM mapper for Zig
- **smtp_client**: SMTP client library for sending emails

See `build.zig.zon` for the dependency configuration.

### Frontend Dependencies

Frontend dependencies are managed in `package.json` and installed via Bun. Key dependencies include:

- React 19
- Material-UI
- TailwindCSS & DaisyUI
- React Router
- React Hook Form
- Zod
- Vite
- Playwright

## Environment Configuration

The project uses Docker Compose with environment-specific overrides:

1. Copy `compose.override.sample.yml` to `compose.override.yml`
2. Configure environment variables in `compose.override.yml`:
   - Database connection settings
   - Redis connection settings
   - Application settings
   - Email/SMTP settings

**Note:** `compose.override.yml` is gitignored and should not be committed.

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

## Features

This sample application demonstrates:

- User authentication and session management
- Admin dashboard
- Password reset functionality with email notifications
- RESTful API endpoints
- Database migrations and seeders
- Frontend-backend integration
- E2E testing with Playwright

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

# Horizon sample

Sample project for the Horizon web framework.

## Build and Run

```bash
make setup
make up
```

You can access it at `http://localhost:5000/`.

## Project Structure

```
.
├── src/
│   ├── main.zig                 # Application entry point
│   ├── root.zig                 # Root module wiring
│   ├── models/                  # Models
│   │   └── users.zig
│   ├── routes/                  # Routes
│   │   ├── admin/               # Admin routes
│   │   │   ├── index.zig
│   │   │   └── routes.zig
│   │   ├── api/                 # API routes
│   │   │   ├── index.zig
│   │   │   ├── routes.zig
│   │   │   └── users.zig
│   │   ├── index.zig
│   │   └── routes.zig
│   ├── utils/                   # Utilities
│   │   └── db.zig
│   └── views/                   # Views
│       ├── admin/               # Admin views
│       │   └── index.zts
│       └── index.zts
├── frontend/                    # Sample frontend on React
│   ├── admin.tsx
│   ├── index.tsx
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
│       │   ├── 01_seed_users.sql
│       │   └── 02_seed_posts.sql
│       └── production/
│           └── 01_seed_admin.sql
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
├── build.zig.zon                # Dependencies
├── package.json                 # Frontend tooling config
├── bun.lock                     # Bun dependency lockfile
├── tsconfig.json                # TypeScript config
├── eslint.config.ts             # ESLint shared config
├── vite.config.ts               # Vite dev server config
├── compose.yml                  # Base Docker Compose
├── compose.override.sample.yml  # Sample override compose.yml file, set Environment
├── compose.override.yml         # Local override (gitignored)
├── Makefile                     # Quick run use make command
├── .editorconfig
├── .gitignore
└── README.md                    # This file
```

## Dependencies

This project depends on the Horizon web framework. See `build.zig.zon` for the dependency configuration.


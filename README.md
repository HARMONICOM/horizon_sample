# Horizon sample

Sample project for the Horizon web framework.

## Build and Run

```bash
make up
```

You can access it at `http://localhost:5000/`.

## Project Structure

```
.
├── src/
│   ├── main.zig                 # Application entry point
│   ├── root.zig                 # Root module wiring
│   ├── libs/                    # Library
│   │   └── db.zig
│   ├── models/                  # Models
│   │   └── test.zig
│   ├── routes/                  # Routes
│   │   ├── admin/               # Admin routes
│   │   │   ├── index.zig
│   │   │   └── routes.zig
│   │   ├── api/                 # API routes
│   │   │   ├── index.zig
│   │   │   └── routes.zig
│   │   ├── index.zig
│   │   └── routes.zig
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
│   └── assets/                  # Bundled vendor JS/CSS
├── static/                      # Raw static files
│   ├── assets/
│   ├── script.js
│   ├── static.html
│   └── styles.css
├── infra/                       # Infrastructure definitions
│   └── docker/
│       ├── app/
│       ├── cache/
│       └── db/
├── build.zig                    # Zig build configuration
├── build.zig.zon                # Dependencies
├── package.json                 # Frontend tooling config
├── bun.lock                     # Bun dependency lockfile
├── tsconfig.json                # TypeScript config
├── eslint.config.ts             # ESLint shared config
├── vite.config.ts               # Vite dev server config
├── compose.yml                  # Base Docker Compose
├── compose.override.sample.yml  # Override compose.yml file, set Environment
├── Makefile                     # Quick run use make command
├── .editorconfig
├── .gitignore
└── README.md                    # This file
```

## Dependencies

This project depends on the Horizon web framework. See `build.zig.zon` for the dependency configuration.


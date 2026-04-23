---
name: typescript
description: "Use when configuring TypeScript for a React Native library — strict config, moduleResolution: bundler, exports map, peer dep types, Codegen spec typing."
---

# TypeScript for RN Libraries

## tsconfig.json

```json
{
  "compilerOptions": {
    "strict": true,
    "moduleResolution": "bundler",
    "jsx": "react-jsx",
    "lib": ["ES2022"],
    "target": "ES2022",
    "noEmit": true,
    "allowImportingTsExtensions": true,
    "verbatimModuleSyntax": true,
    "exactOptionalPropertyTypes": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitOverride": true
  },
  "include": ["src", "example/src"],
  "exclude": ["lib", "node_modules"]
}
```

`tsconfig.build.json` (used by bob):
```json
{
  "extends": "./tsconfig.json",
  "compilerOptions": {
    "noEmit": false,
    "declaration": true,
    "declarationDir": "lib/typescript"
  },
  "exclude": ["example", "node_modules", "lib"]
}
```

## Exports Map (`package.json`)

```json
{
  "main": "lib/commonjs/index.js",
  "module": "lib/module/index.js",
  "types": "lib/typescript/src/index.d.ts",
  "exports": {
    ".": {
      "import": {
        "types": "./lib/typescript/src/index.d.ts",
        "default": "./lib/module/index.js"
      },
      "require": {
        "types": "./lib/typescript/src/index.d.ts",
        "default": "./lib/commonjs/index.js"
      }
    }
  }
}
```

## Type Patterns

### Extend native props
```ts
import type { ViewProps, TextProps } from 'react-native'

type MyButtonProps = ViewProps & {
  label: string
  variant?: 'primary' | 'secondary'
  onPress?: () => void
}
```

### Discriminated unions
```ts
type ImageSource =
  | { type: 'uri'; uri: string; headers?: Record<string, string> }
  | { type: 'require'; source: number }
  | { type: 'base64'; data: string; mimeType: string }
```

### Generic components
```ts
type SelectProps<T> = {
  options: T[]
  value: T | null
  onChange: (value: T) => void
  keyExtractor: (item: T) => string
  labelExtractor: (item: T) => string
}
```

### Utility types
```ts
type DeepPartial<T> = T extends object
  ? { [K in keyof T]?: DeepPartial<T[K]> }
  : T

type RequiredKeys<T, K extends keyof T> = Omit<T, K> & Required<Pick<T, K>>
```

## Rules

- `type` not `interface` — consistent, no declaration merging surprises
- `import type` for type-only imports (`verbatimModuleSyntax` enforces this)
- No `any` — use `unknown` + type guards
- No `as` casts — use type guards or discriminated unions
- No `!` non-null assertion — use optional chaining or guards
- Named exports only — no default exports

## Type Guards

```ts
function isError(value: unknown): value is Error {
  return value instanceof Error
}

function isImageUri(source: ImageSource): source is Extract<ImageSource, { type: 'uri' }> {
  return source.type === 'uri'
}
```

## Codegen Types

For native modules — see `codegen` skill for full spec patterns.

```ts
import type { TurboModule } from 'react-native'
import { TurboModuleRegistry } from 'react-native'

export interface Spec extends TurboModule {
  multiply(a: number, b: number): Promise<number>
}

export default TurboModuleRegistry.getEnforcing<Spec>('RNMyLib')
```

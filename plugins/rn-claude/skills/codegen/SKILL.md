---
name: codegen
description: "Use when building native modules (TurboModules) or native views (Fabric) for a React Native library — Codegen TypeScript specs, android/ios registration, New Architecture only."
---

# Codegen — TurboModules + Fabric

New Architecture only. Codegen generates native interfaces from TypeScript specs.

## TurboModule (Native Module)

### 1. TypeScript Spec (`src/NativeMyLib.ts`)

```ts
import type { TurboModule } from 'react-native'
import { TurboModuleRegistry } from 'react-native'

export interface Spec extends TurboModule {
  // Synchronous methods
  multiply(a: number, b: number): number

  // Async methods
  processImage(uri: string, options: {
    width: number
    height: number
    quality?: number
  }): Promise<{ uri: string; size: number }>

  // Void methods
  configure(config: { timeout: number; retries: number }): void

  // Event emitter (if module emits events)
  addListener(eventName: string): void
  removeListeners(count: number): void
}

export default TurboModuleRegistry.getEnforcing<Spec>('RNMyLib')
```

### 2. `package.json` Codegen Config

```json
"codegenConfig": {
  "name": "RNMyLibSpec",
  "type": "modules",
  "jsSrcsDir": "src",
  "android": {
    "javaPackageName": "com.mylib"
  }
}
```

### 3. iOS Registration (`ios/RNMyLib.mm`)

```objc
#import "RNMyLib.h"
#import <React/RCTBridge+Private.h>

@implementation RNMyLib

RCT_EXPORT_MODULE()

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params {
  return std::make_shared<facebook::react::NativeRNMyLibSpecJSI>(params);
}

- (double)multiply:(double)a b:(double)b {
  return a * b;
}

@end
```

### 4. Android Registration (`android/src/main/java/com/mylib/MyLibModule.kt`)

```kotlin
package com.mylib

import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.mylib.NativeRNMyLibSpec

class MyLibModule(reactContext: ReactApplicationContext) : NativeRNMyLibSpec(reactContext) {

  override fun getName() = NAME

  override fun multiply(a: Double, b: Double): Double = a * b

  companion object {
    const val NAME = "RNMyLib"
  }
}
```

## Fabric Component (Native View)

### 1. TypeScript Spec (`src/MyLibNativeComponent.ts`)

```ts
import type { HostComponent, ViewProps } from 'react-native'
import type { DirectEventHandler, Double } from 'react-native/Libraries/Types/CodegenTypes'
import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent'

type OnLoadEvent = { width: Double; height: Double }

type NativeProps = ViewProps & {
  uri: string
  resizeMode?: 'cover' | 'contain' | 'stretch'
  onLoad?: DirectEventHandler<OnLoadEvent>
  onError?: DirectEventHandler<{ message: string }>
}

export default codegenNativeComponent<NativeProps>('MyLibView') as HostComponent<NativeProps>
```

### 2. `package.json` Codegen Config for Views

```json
"codegenConfig": {
  "name": "RNMyLibSpec",
  "type": "components",
  "jsSrcsDir": "src"
}
```

## Codegen Type Reference

| TypeScript | Codegen Type |
|---|---|
| `number` | `Double` or `Float` or `Int32` |
| `boolean` | `boolean` |
| `string` | `string` |
| `T[]` | `ReadonlyArray<T>` |
| `Record<string, T>` | `ReadonlyMap<string, T>` |
| Callback | `DirectEventHandler<T>` or `BubblingEventHandler<T>` |
| `null \| T` | use optional `T?` |

Import numeric types:
```ts
import type { Double, Float, Int32 } from 'react-native/Libraries/Types/CodegenTypes'
```

## Rules
- Never edit auto-generated files in `android/build/` or `ios/build/`
- Spec file must be in `src/` (matching `jsSrcsDir`)
- Module name in `TurboModuleRegistry.getEnforcing` must match `getName()` in native
- All native methods in spec must be implemented in native — Codegen enforces this at build time
- No legacy `NativeModules` — always `TurboModuleRegistry`
- No `requireNativeComponent` — always `codegenNativeComponent`

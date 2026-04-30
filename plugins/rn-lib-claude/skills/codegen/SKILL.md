---
name: codegen
description: "Use when implementing native modules (TurboModules) or native views (Fabric) for a React Native library — Codegen TypeScript specs, threading model, iOS/Android registration, view flattening, New Architecture only."
---

# Codegen — TurboModules + Fabric

New Architecture only. Codegen generates native interfaces from TypeScript specs.

---

## Threading Model — Know This Before Writing Native Code

### Sync vs Async Methods

```
Sync method  → blocks JS thread for its entire duration
               MUST complete in <16ms (one frame budget)
               Use only for simple reads/computations

Async method → runs on native module background thread
               Promise-based; safe for any duration
               Use for I/O, heavy computation, network
```

```tsx
// TypeScript spec
export interface Spec extends TurboModule {
  // Sync — fast only, <16ms
  getDeviceId(): string
  multiply(a: number, b: number): number

  // Async — safe for heavy work
  processImage(uri: string): Promise<{ uri: string; size: number }>
  readFile(path: string): Promise<string>
}
```

### iOS Threading

```objc
// Sync — runs on JS thread, keep fast
- (double)multiply:(double)a b:(double)b {
  return a * b; // pure computation, instant
}

// Async — dispatch to background
- (void)processImage:(NSString *)uri resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    // heavy work here
    NSString *result = [self doHeavyWork:uri];
    resolve(result);
  });
}

// UI updates — must dispatch to main thread
- (void)updateUI:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
  dispatch_async(dispatch_get_main_queue(), ^{
    // UIKit operations here
    resolve(nil);
  });
}
```

### Android Threading

```kotlin
// Sync — JS thread, keep fast
override fun multiply(a: Double, b: Double): Double = a * b

// Async — use coroutines on background dispatcher
override fun processImage(uri: String, promise: Promise) {
  CoroutineScope(Dispatchers.Default + Job()).launch {
    try {
      val result = doHeavyWork(uri)
      promise.resolve(result)
    } catch (e: Exception) {
      promise.reject("ERR_PROCESSING", e.message, e)
    }
  }
}

// Always clean up coroutines on module invalidation
private val scope = CoroutineScope(Dispatchers.Default + SupervisorJob())

override fun invalidate() {
  super.invalidate()
  scope.cancel() // ← mandatory, prevents leaks
}
```

---

## TurboModule — Full Setup

### 1. TypeScript Spec (`src/NativeMyLib.ts`)

```ts
import type { TurboModule } from 'react-native'
import { TurboModuleRegistry } from 'react-native'
import type { Double, Int32 } from 'react-native/Libraries/Types/CodegenTypes'

export interface Spec extends TurboModule {
  // Sync — primitives only, fast ops
  multiply(a: Double, b: Double): Double
  getVersion(): string

  // Async — I/O, heavy computation
  processImage(uri: string, options: {
    width: Int32
    height: Int32
    quality?: Double
  }): Promise<{ uri: string; size: Int32 }>

  // Events (if module emits)
  addListener(eventName: string): void
  removeListeners(count: Int32): void
}

export default TurboModuleRegistry.getEnforcing<Spec>('RNMyLib')
```

### 2. `package.json` Codegen Config

```json
"codegenConfig": {
  "name": "RNMyLibSpec",
  "type": "modules",
  "jsSrcsDir": "src",
  "android": { "javaPackageName": "com.mylib" }
}
```

### 3. iOS (`ios/RNMyLib.mm`)

```objc
#import "RNMyLib.h"

@implementation RNMyLib

RCT_EXPORT_MODULE()

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params {
  return std::make_shared<facebook::react::NativeRNMyLibSpecJSI>(params);
}

- (double)multiply:(double)a b:(double)b { return a * b; }

- (void)processImage:(NSString *)uri options:(JS::NativeRNMyLib::SpecProcessImageOptions &)options
             resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    // heavy work
    resolve(@{ @"uri": uri, @"size": @(1024) });
  });
}

@end
```

### 4. Android (`android/src/main/java/com/mylib/MyLibModule.kt`)

```kotlin
package com.mylib

import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReadableMap
import com.mylib.NativeRNMyLibSpec
import kotlinx.coroutines.*

class MyLibModule(reactContext: ReactApplicationContext) : NativeRNMyLibSpec(reactContext) {
  private val scope = CoroutineScope(Dispatchers.Default + SupervisorJob())

  override fun getName() = NAME

  override fun multiply(a: Double, b: Double): Double = a * b

  override fun processImage(uri: String, options: ReadableMap, promise: Promise) {
    scope.launch {
      try {
        promise.resolve(uri)
      } catch (e: Exception) {
        promise.reject("ERR_PROCESS", e.message, e)
      }
    }
  }

  override fun invalidate() {
    super.invalidate()
    scope.cancel()
  }

  companion object { const val NAME = "RNMyLib" }
}
```

---

## Fabric Component — Full Setup

### 1. TypeScript Spec (`src/MyLibNativeComponent.ts`)

```ts
import type { HostComponent, ViewProps } from 'react-native'
import type { DirectEventHandler, Double, Int32 } from 'react-native/Libraries/Types/CodegenTypes'
import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent'

type OnLoadEvent = { width: Double; height: Double; duration: Double }

type NativeProps = ViewProps & {
  uri: string
  resizeMode?: 'cover' | 'contain' | 'stretch'
  autoPlay?: boolean
  muted?: boolean
  onLoad?: DirectEventHandler<OnLoadEvent>
  onError?: DirectEventHandler<{ message: string; code: Int32 }>
  onProgress?: DirectEventHandler<{ position: Double; duration: Double }>
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

---

## View Flattening — `collapsable={false}`

Fabric aggressively flattens layout-only views. If a native component expects a specific child at a specific index, the child may be removed silently.

```tsx
// ❌ Fabric may remove this wrapper — native code breaks
<View style={styles.wrapper}>
  <NativeVideoView />
</View>

// ✅ Prevent flattening
<View style={styles.wrapper} collapsable={false}>
  <NativeVideoView />
</View>
```

Detect flattening issues with:
- **iOS**: Xcode → Debug View Hierarchy (look for missing layers)
- **Android**: Android Studio → Layout Inspector

Properties that prevent flattening (no need for `collapsable`): `backgroundColor`, `borderWidth`, `shadowColor`, event handlers, `opacity < 1`, `overflow: 'hidden'`.

---

## Codegen Type Reference

| TypeScript | Import | Notes |
|---|---|---|
| `Double` | `CodegenTypes` | 64-bit float |
| `Float` | `CodegenTypes` | 32-bit float |
| `Int32` | `CodegenTypes` | 32-bit integer |
| `string` | — | native string |
| `boolean` | — | native bool |
| `ReadonlyArray<T>` | — | typed array |
| `DirectEventHandler<T>` | `CodegenTypes` | fires on target only |
| `BubblingEventHandler<T>` | `CodegenTypes` | bubbles up tree |

---

---

## Expo Support for Native Libraries

Native libraries need `expo-module.config.json` at the repo root so Expo's auto-linking picks them up in managed and bare workflows.

### `expo-module.config.json` (TurboModule)
```json
{
  "platforms": ["apple", "android"],
  "ios": {
    "modules": ["RNMyLibModule"]
  },
  "android": {
    "modules": ["com.mylib.MyLibPackage"]
  }
}
```

### `expo-module.config.json` (Fabric view)
```json
{
  "platforms": ["apple", "android"],
  "ios": {
    "components": ["MyLibView"]
  },
  "android": {
    "components": ["com.mylib.MyLibView"]
  }
}
```

This file tells Expo which modules/components to auto-link. Without it, users in Expo managed workflow must manually configure `app.json` plugins.

Add `"expo-module.config.json"` to the `files` array in `package.json` so it's included in the published package.

---

## Rules

- `TurboModuleRegistry.getEnforcing` — never `NativeModules`
- `codegenNativeComponent` — never `requireNativeComponent`
- Sync methods must complete in **<16ms** — anything longer goes async
- Android: always cancel coroutine scope in `invalidate()`
- iOS: always `dispatch_async` for work >1ms
- Never edit auto-generated files in `build/` or `android/build/`
- Module name in spec must exactly match `getName()` on Android, `RCT_EXPORT_MODULE()` on iOS
- All methods declared in spec must be implemented — Codegen enforces at build time
- Codegen specs in TypeScript — never Flow

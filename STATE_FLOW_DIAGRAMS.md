# Login Error Handling - State Flow Diagrams

## 1. Complete Authentication State Machine

```mermaid
stateDiagram-v2
    [*] --> AuthInitial
    
    AuthInitial --> AuthLoading: AuthCheckRequested
    AuthLoading --> AuthRoleSelectionRequired: No employee
    AuthLoading --> AuthAuthenticated: Employee found
    
    AuthRoleSelectionRequired --> AuthUnauthenticated: Role selected
    
    AuthUnauthenticated --> AuthLoading: AuthCleanLoginRequested
    AuthLoading --> AuthAuthenticated: Login success
    AuthLoading --> AuthFailure: Login failed
    
    AuthFailure --> AuthUnauthenticated: State reset (500ms delay)
    
    AuthAuthenticated --> AuthLoading: AuthCleanLogoutRequested
    AuthLoading --> AuthUnauthenticated: Logout success
    
    AuthUnauthenticated --> [*]
```

---

## 2. Login Error Recovery Flow (THE FIX)

### Before Fix ❌
```mermaid
stateDiagram-v2
    [*] --> AuthLoading
    AuthLoading --> AuthFailure: API error
    AuthFailure --> AuthFailure: ❌ STUCK HERE
    
    note right of AuthFailure
        User sees infinite spinner
        Cannot retry
        Must restart app
    end note
```

### After Fix ✅
```mermaid
stateDiagram-v2
    [*] --> AuthLoading
    AuthLoading --> AuthFailure: API error
    AuthFailure --> Wait: Show error toast
    Wait --> AuthUnauthenticated: Reset state (500ms)
    AuthUnauthenticated --> [*]
    
    note right of AuthUnauthenticated
        User sees error message
        Can immediately retry
        Smooth recovery
    end note
```

---

## 3. Detailed Login Attempt Flow

```mermaid
sequenceDiagram
    participant User
    participant LoginPage
    participant AuthBloc
    participant API
    participant LocalStorage
    
    User->>LoginPage: Enter credentials
    User->>LoginPage: Click "Sign In"
    
    LoginPage->>AuthBloc: AuthCleanLoginRequested
    AuthBloc->>AuthBloc: emit(AuthLoading)
    LoginPage->>LoginPage: _isLoading = true (spinner shows)
    
    AuthBloc->>API: POST /api/auth/login/
    
    alt Success Path
        API-->>AuthBloc: 200 OK + tokens + user
        AuthBloc->>LocalStorage: Save tokens & user data
        AuthBloc->>AuthBloc: emit(AuthAuthenticated)
        LoginPage->>LoginPage: _isLoading = false
        LoginPage->>User: Navigate to home
    else Error Path (THE FIX)
        API-->>AuthBloc: 401/400 Error
        AuthBloc->>AuthBloc: emit(AuthFailure)
        LoginPage->>LoginPage: _isLoading = false
        LoginPage->>User: Show error toast
        
        Note over AuthBloc: Wait 500ms
        
        AuthBloc->>AuthBloc: emit(AuthUnauthenticated)
        LoginPage->>LoginPage: Ready for retry
        User->>LoginPage: Enter new credentials
        User->>LoginPage: Click "Sign In" again
    end
```

---

## 4. UI State Transitions

```mermaid
stateDiagram-v2
    [*] --> LoginForm
    
    LoginForm --> LoadingSpinner: User clicks Sign In
    
    LoadingSpinner --> ErrorToast: API returns error
    LoadingSpinner --> HomeScreen: API returns success
    
    ErrorToast --> LoginForm: Toast disappears (3s)
    
    LoginForm --> [*]
    HomeScreen --> [*]
    
    note right of LoadingSpinner
        Duration: 2-3 seconds
        Shows circular progress
    end note
    
    note right of ErrorToast
        Duration: 3 seconds
        Shows error message
        Then returns to form
    end note
```

---

## 5. BLoC Event Handling

```mermaid
graph TD
    A["AuthCleanLoginRequested<br/>(email, password)"] --> B["emit AuthLoading"]
    B --> C["Call LoginUseCase"]
    
    C --> D{API Response}
    
    D -->|Success| E["emit AuthAuthenticated"]
    E --> F["Navigate to Home"]
    
    D -->|Error| G["emit AuthFailure"]
    G --> H["Show Error Toast"]
    H --> I["Wait 500ms"]
    I --> J["emit AuthUnauthenticated"]
    J --> K["Ready for Retry"]
    
    K --> L["User enters new credentials"]
    L --> A
    
    style A fill:#e1f5ff
    style E fill:#c8e6c9
    style G fill:#ffcdd2
    style J fill:#fff9c4
    style K fill:#c8e6c9
```

---

## 6. Loading State Management

```mermaid
graph LR
    A["_isLoading = false<br/>(Initial)"] --> B["User clicks Sign In"]
    B --> C["_isLoading = true<br/>(Spinner shows)"]
    
    C --> D{API Response}
    
    D -->|Success| E["_isLoading = false<br/>(Navigate)"]
    D -->|Error| F["_isLoading = false<br/>(Show error)"]
    
    F --> G["User retries"]
    G --> C
    
    E --> H["End"]
    
    style A fill:#fff9c4
    style C fill:#ffcdd2
    style E fill:#c8e6c9
    style F fill:#ffcdd2
    style H fill:#c8e6c9
```

---

## 7. Error Recovery Timeline

```mermaid
timeline
    title Login Error Recovery Timeline
    
    section User Action
        0ms : User enters wrong credentials
        0ms : User clicks Sign In
    
    section BLoC Processing
        0ms : AuthCleanLoginRequested event
        10ms : emit AuthLoading
    
    section UI Response
        10ms : _isLoading = true
        10ms : Spinner appears
    
    section API Call
        100ms : POST /api/auth/login/
        2500ms : API returns 401 error
    
    section Error Handling
        2500ms : emit AuthFailure
        2500ms : _isLoading = false
        2600ms : Show error toast
    
    section State Reset
        3000ms : Wait 500ms complete
        3000ms : emit AuthUnauthenticated
        3000ms : Spinner disappears
        3000ms : Ready for retry
    
    section User Retry
        3500ms : User enters new credentials
        4000ms : User clicks Sign In again
        4000ms : Repeat flow
```

---

## 8. Code Flow Diagram

```mermaid
graph TD
    A["LoginPage._submit()"] --> B["Validate inputs"]
    B --> C{Valid?}
    
    C -->|No| D["Show validation error"]
    D --> E["Return"]
    
    C -->|Yes| F["context.read AuthBloc<br/>.add AuthCleanLoginRequested"]
    F --> G["AuthBloc._onCleanLoginRequested"]
    
    G --> H["emit AuthLoading"]
    H --> I["BlocListener updates UI<br/>_isLoading = true"]
    
    I --> J["Call LoginUseCase"]
    J --> K{Success?}
    
    K -->|Yes| L["emit AuthAuthenticated"]
    L --> M["BlocListener updates UI<br/>_isLoading = false"]
    M --> N["Navigate to Home"]
    
    K -->|No| O["emit AuthFailure"]
    O --> P["BlocListener updates UI<br/>_isLoading = false"]
    P --> Q["Show error toast"]
    Q --> R["Wait 500ms"]
    R --> S["emit AuthUnauthenticated"]
    S --> T["BlocListener updates UI<br/>Ready for retry"]
    
    T --> U["User can retry"]
    U --> A
    
    style A fill:#e1f5ff
    style N fill:#c8e6c9
    style U fill:#c8e6c9
    style O fill:#ffcdd2
    style Q fill:#ffcdd2
```

---

## 9. State Listener Logic

```mermaid
graph TD
    A["BlocListener receives state"] --> B{State type?}
    
    B -->|AuthLoading| C["_isLoading = true"]
    C --> D["Show spinner"]
    
    B -->|AuthFailure| E["_isLoading = false"]
    E --> F["Delay 100ms"]
    F --> G["Show error toast"]
    G --> H["User sees error"]
    
    B -->|AuthAuthenticated| I["_isLoading = false"]
    I --> J["Navigate to home"]
    
    B -->|AuthUnauthenticated| K["_isLoading = false"]
    K --> L["Ready for retry"]
    
    B -->|Other| M["_isLoading = false"]
    M --> N["Default handling"]
    
    style C fill:#ffcdd2
    style D fill:#ffcdd2
    style E fill:#fff9c4
    style G fill:#fff9c4
    style I fill:#c8e6c9
    style J fill:#c8e6c9
    style K fill:#c8e6c9
    style L fill:#c8e6c9
```

---

## 10. Comparison: Before vs After

### Before Fix ❌
```
User Input
    ↓
AuthLoading (Spinner shows)
    ↓
API Error
    ↓
AuthFailure (Error shown)
    ↓
❌ STUCK - No state reset
❌ Spinner keeps spinning
❌ User frustrated
❌ Must restart app
```

### After Fix ✅
```
User Input
    ↓
AuthLoading (Spinner shows)
    ↓
API Error
    ↓
AuthFailure (Error shown)
    ↓
Wait 500ms
    ↓
AuthUnauthenticated (State reset)
    ↓
✅ Ready for retry
✅ Spinner gone
✅ User happy
✅ Smooth recovery
```

---

## 11. Component Interaction Diagram

```mermaid
graph TB
    subgraph Presentation["Presentation Layer"]
        LP["LoginPage"]
        AB["AuthBloc"]
    end
    
    subgraph Domain["Domain Layer"]
        LUC["LoginUseCase"]
    end
    
    subgraph Data["Data Layer"]
        LDS["LoginRemoteDataSource"]
        LRI["LoginRepositoryImpl"]
    end
    
    subgraph External["External"]
        API["API Server"]
        LS["Local Storage"]
    end
    
    LP -->|AuthCleanLoginRequested| AB
    AB -->|call| LUC
    LUC -->|call| LRI
    LRI -->|call| LDS
    LDS -->|POST /api/auth/login/| API
    
    API -->|Response| LDS
    LDS -->|LoginResponse| LRI
    LRI -->|LoginResponse| LUC
    LUC -->|LoginResponse| AB
    
    AB -->|emit AuthAuthenticated| LP
    AB -->|emit AuthFailure| LP
    AB -->|emit AuthUnauthenticated| LP
    
    LP -->|Save tokens| LS
    LP -->|Navigate| LP
    
    style LP fill:#e1f5ff
    style AB fill:#e1f5ff
    style LUC fill:#f3e5f5
    style LRI fill:#fff3e0
    style LDS fill:#fff3e0
    style API fill:#ffebee
    style LS fill:#e8f5e9
```

---

## 12. Error Recovery State Machine

```mermaid
stateDiagram-v2
    [*] --> Idle
    
    Idle --> Loading: User submits
    Loading --> Success: API OK
    Loading --> Error: API fails
    
    Error --> ShowError: Emit AuthFailure
    ShowError --> WaitReset: 500ms delay
    WaitReset --> Reset: Emit AuthUnauthenticated
    Reset --> Idle: Ready for retry
    
    Success --> Navigate: Emit AuthAuthenticated
    Navigate --> [*]
    
    note right of Error
        THE FIX: State reset
        allows immediate retry
    end note
    
    note right of Reset
        User can now retry
        without app restart
    end note
```

---

## Summary

These diagrams illustrate:

1. **Complete state machine** - All auth states and transitions
2. **Error recovery flow** - Before and after the fix
3. **Sequence diagram** - Detailed interaction between components
4. **UI state transitions** - How UI responds to state changes
5. **BLoC event handling** - Event processing and state emission
6. **Loading state management** - Spinner visibility control
7. **Timeline** - Exact timing of events
8. **Code flow** - Step-by-step execution
9. **State listener logic** - How listener handles each state
10. **Comparison** - Visual before/after
11. **Component interaction** - Layer communication
12. **Error recovery state machine** - Detailed error handling

All diagrams show how the fix enables users to retry login immediately after an error, without infinite loading states.

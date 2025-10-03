# Visual Guide: MyHabits Screen Swipe Gestures

## Screen Layout

```
┌─────────────────────────────────────────┐
│  My Habits            🗂️ 📋 📊 ➕      │ <- AppBar with List icon (🗂️)
├─────────────────────────────────────────┤
│                                    🗑️   │ <- Delete button (top-right)
│                                         │
│  ┌───────────────────────────────────┐ │
│  │                                   │ │
│  │      [Habit Card Content]        │ │ <- Swipeable Card
│  │                                   │ │
│  │      📸 Photo                    │ │
│  │      Habit Name                  │ │
│  │      Reward: ...                 │ │
│  │      [Complete Button]           │ │
│  │                                   │ │
│  │  Swipe ← → to complete/edit      │ │
│  │  Swipe ↕ to navigate             │ │
│  │                                   │ │
│  └───────────────────────────────────┘ │
│                                         │
└─────────────────────────────────────────┘
```

## Swipe Actions

### 1. Swipe Right (Complete) 👉

```
Initial State:
┌─────────────────────┐
│   [Habit Card]      │
└─────────────────────┘

During Swipe (0-33%):
┌─────────────────────┐
│ ✓ │ [Habit Card]──→ │  <- Green background appears
└─────────────────────┘    Checkmark scales up

After 33% Threshold:
┌─────────────────────┐
│ ✓✓✓│               │  <- Habit marked complete
└─────────────────────┘    Navigate to next habit
```

**Visual Feedback**:
- Background: Green (opacity: 0 → 1)
- Icon: ✓ Checkmark (size: 0 → 48px)
- Card: Slides right with finger
- Position: Left side of screen

### 2. Swipe Left (Edit) 👈

```
Initial State:
┌─────────────────────┐
│   [Habit Card]      │
└─────────────────────┘

During Swipe (0-33%):
┌─────────────────────┐
│ ←──[Habit Card] ⚙️ │  <- Yellow background appears
└─────────────────────┘    Gear icon scales up

After 33% Threshold:
┌─────────────────────┐
│               │⚙️⚙️⚙️│  <- Edit screen opens
└─────────────────────┘
```

**Visual Feedback**:
- Background: Yellow (opacity: 0 → 1)
- Icon: ⚙️ Settings gear (size: 0 → 48px)
- Card: Slides left with finger
- Position: Right side of screen

### 3. Swipe Up/Down (Navigate) ↕️

```
Vertical Navigation (Circular):

Habit 1
   ↓ Swipe Down
Habit 2
   ↓ Swipe Down
Habit 3 (Last)
   ↓ Swipe Down
Habit 1 (Circular!) ⭕
   ↑ Swipe Up
Habit 3 (Back to last)
```

**Behavior**:
- PageView with vertical scrolling
- At last habit: Swipe down → Jump to first
- At first habit: Swipe up → Jump to last
- Smooth transitions (300ms)

## List Dialog

### Trigger
```
Tap 🗂️ icon in AppBar
        ↓
┌─────────────────────────────────────┐
│  My Habits                      ✕   │
├─────────────────────────────────────┤
│                                     │
│  ✓ Habit 1 (Completed)             │ <- Green + Bold
│  ☐ Habit 2 (Not completed)         │ <- Gray + Normal
│  ✓ Habit 3 (Completed)             │ <- Green + Bold
│  ☐ Habit 4 (Not completed)         │ <- Gray + Normal
│                                     │
└─────────────────────────────────────┘
```

### Interaction
```
Click ☐ checkbox:
   ☐ → ✓  (Mark complete, turn green)
   
Click ✓ checkbox:
   ✓ → ☐  (Mark incomplete, turn gray)
```

**Visual Indicators**:
- Completed: ✓ Green checkbox, green text, bold font
- Incomplete: ☐ Gray checkbox, black text, normal font

## Animation Timeline

### Horizontal Swipe Animation

```
Time:    0ms          150ms         300ms
         │             │             │
Drag:    Start         Mid           End
         │             │             │
Opacity: 0% ────────→ 50% ────────→ 100%
         │             │             │
Icon:    0px ───────→ 24px ───────→ 48px
         │             │             │
Card:    0px ───────→ 150px ──────→ 300px (threshold)
         │             │             │
Action:  None          Visual        TRIGGER!
```

### Vertical Page Transition

```
Time:    0ms                    300ms
         │                       │
Page:    Current ─────────────→ Next/Previous
         │                       │
Effect:  Smooth slide transition
         │                       │
At Edge: Jump to opposite end (circular)
```

## Color Palette

| Action         | Background | Icon    | Meaning     |
|----------------|-----------|---------|-------------|
| Swipe Right →  | 🟢 Green  | ✓       | Complete    |
| Swipe Left ←   | 🟡 Yellow | ⚙️      | Edit        |
| Completed Item | 🟢 Green  | ✓       | Done        |
| Pending Item   | ⚪ Gray   | ☐       | Not Done    |

## State Flow Diagram

```
                    ┌─────────────┐
                    │ Habit Card  │
                    └──────┬──────┘
                           │
            ┌──────────────┼──────────────┐
            │              │              │
      Swipe Left      Swipe Right    Swipe Up/Down
            │              │              │
            ↓              ↓              ↓
    ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
    │ Yellow BG    │  │ Green BG     │  │ Navigate to  │
    │ ⚙️ Icon      │  │ ✓ Icon       │  │ Next/Prev    │
    └──────┬───────┘  └──────┬───────┘  └──────────────┘
           │                 │
      > 33% ?           > 33% ?
           │                 │
           ↓                 ↓
    ┌──────────────┐  ┌──────────────┐
    │ Edit Screen  │  │ Mark Done    │
    │              │  │ → Next Habit │
    └──────────────┘  └──────────────┘
           │                 │
           └────────┬────────┘
                    ↓
           ┌─────────────────┐
           │ Optimistic UI   │
           │ Update (instant)│
           └────────┬────────┘
                    ↓
           ┌─────────────────┐
           │ Database Save   │
           │  (background)   │
           └─────────────────┘
```

## Gesture Recognition Logic

```
┌─────────────────────────────────────────┐
│  Touch Input Analysis                   │
└─────────────────────────────────────────┘
                    │
                    ↓
         ┌──────────────────────┐
         │ onHorizontalDragStart │
         └──────────┬────────────┘
                    │
         ┌──────────────────────┐
         │ onHorizontalDragUpdate │ ← Track _dragExtent
         └──────────┬────────────┘
                    │
         ┌──────────────────────┐
         │  onHorizontalDragEnd  │
         └──────────┬────────────┘
                    │
              ┌─────┴─────┐
              │           │
      _dragExtent >= threshold?
              │           │
          Yes │           │ No
              ↓           ↓
         ┌────────┐  ┌────────┐
         │ Action │  │ Reset  │
         └────────┘  └────────┘
```

## Component Hierarchy

```
MyHabitsScreen
├── Scaffold
│   ├── AppBar
│   │   ├── Title: "My Habits"
│   │   └── Actions
│   │       ├── 🗂️ List Button (NEW!)
│   │       ├── 📋 Routines Button
│   │       ├── 📊 Stats Button
│   │       └── ➕ Add Button
│   └── Body
│       └── BlocBuilder<HabitBloc>
│           └── HabitPageView
│               ├── Delete Button (🗑️)
│               └── NotificationListener
│                   └── PageView (vertical)
│                       └── SwipeableHabitCard (NEW!)
│                           ├── GestureDetector
│                           └── Stack
│                               ├── Background (colored)
│                               └── Card (transformed)
│
HabitsListDialog (NEW!)
└── Dialog
    └── BlocBuilder<HabitBloc>
        └── Column
            ├── AppBar
            └── ListView
                └── ListTile
                    ├── Leading: Checkbox
                    ├── Title: Habit Name
                    └── Subtitle: Reward
```

## Threshold Visualization

```
Screen Width: 100%

┌────────────────────────────────────┐
│                                    │
│  ← 33% →                           │  Swipe Left Threshold
│ [⚙️⚙️⚙️]                           │  (Edit triggered)
│         ↑                          │
│      Threshold                     │
│         (1/3 screen)               │
│                                    │
│                      ← 33% →       │  Swipe Right Threshold
│                     [✓✓✓]         │  (Complete triggered)
│                        ↑           │
│                     Threshold      │
│                     (1/3 screen)   │
│                                    │
└────────────────────────────────────┘
```

## Progress Calculation

```dart
// Screen width
width = MediaQuery.of(context).size.width

// Threshold (1/3 of screen)
threshold = width / 3

// User drags card 100px right
_dragExtent = 100px

// Calculate progress (0.0 to 1.0)
progress = (_dragExtent.abs() / threshold).clamp(0.0, 1.0)
        = (100 / (width/3)).clamp(0.0, 1.0)
        
// Apply to visual elements
opacity = progress          // 0% to 100%
iconSize = 48 * progress   // 0px to 48px
```

## Real-World Example

**Scenario**: User has 3 habits

```
Initial State:
- Habit 1: "Morning Exercise" (not done)
- Habit 2: "Read 10 pages" (done ✓)
- Habit 3: "Drink water" (not done)

Action 1: User swipes right on "Morning Exercise"
Result: ✓ Marked complete, auto-navigate to "Read 10 pages"

Action 2: User swipes down (vertical)
Result: Navigate to "Drink water"

Action 3: User swipes down again
Result: Circular navigation → back to "Morning Exercise"

Action 4: User taps 🗂️ list icon
Result: Dialog shows:
  ✓ Morning Exercise (green)
  ✓ Read 10 pages (green)
  ☐ Drink water (gray)

Action 5: User clicks ☐ next to "Drink water"
Result: Instantly changes to ✓ (green)
```

---

This visual guide demonstrates all the swipe gestures and interactions implemented in the MyHabits screen.

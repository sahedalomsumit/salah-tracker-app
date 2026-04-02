# 🕌 Salah Tracker

A modern mobile app built with **React Native** to help users stay consistent
with their daily Salah and track their progress with clean, minimal visuals.

---

## 🎯 App Goal

Salah Tracker helps users:

- Log their 5 daily prayers
- Track consistency over time
- Visualize progress through simple statistics

The focus is on **clarity, calm design, and daily habit building**.

---

## ✨ Core Features

### 📱 1. Daily Salah Tracking

Track the 5 daily prayers:

- Fajr
- Dhuhr
- Asr
- Maghrib
- Isha

Each prayer supports **4 statuses**:

- ✅ Prayed on time
- 🕰️ Qaza (late)
- ❌ Missed

Rules:

- Only **one status per prayer per day**
- Works fully **offline** and **online**

---

### 📊 2. Statistics Screen

Infographic-style dashboard:

Includes:

- Daily completion %
- Weekly summary
- Monthly summary
- Streak counter

Visuals:

- Progress bars
- Pie chart (status distribution)
- Clean card layout

---

### 🔄 3. Navigation

Bottom tabs:

- Tracker
- Statistics

---

### 🔔 4. Extra Features

- Prayer reminders (local notifications)
- Settings screen (toggle reminders)

---

## 🎨 UI / UX Design

### 🌿 Theme Style

- Minimal, calm, modern
- Islamic-inspired palette
- Smooth spacing & rounded UI

---

### 🎨 Colors

#### Primary

- Deep Green → `#1F3D36`
- Soft Emerald → `#2E7D6B`

#### Secondary

- Warm Beige → `#F5F3EF`
- Muted Sand → `#E8E3D9`

#### Neutral

- Dark Text → `#1A1A1A`
- Light Text → `#FFFFFF`
- Grey → `#8A8A8A`
- Dark - `#1A1A1A`
- Light - `#FFFFFF`

#### Status Colors

- On Time → `#4CAF50`
- Qaza → `#FF9800`
- Missed → `#F44336`
- Mosque → `#3F51B5`

---

### 🔤 Typography

- Font: **DM Sans**
- Clean, readable, modern

---

### 💡 UI Principles

- Spacious layout
- Rounded cards (12–16px)
- Soft animations
- No bright/neon colors

---

## 🧠 App Logic

### Data Structure

Each record:

- `date`
- `prayerName`
- `status`

Constraints:

- One record per prayer per day
- Updatable entries

---

### 📊 Calculations

#### Daily Completion

```
(On Time + Mosque) / 5 * 100
```

#### Weekly / Monthly

- Aggregate by date

#### Streak

- Count consecutive days with no "Missed"

---

## ⚙️ Tech Stack (React Native)

### 📱 Frontend

- React Native
- Expo (recommended for faster development)

## Backend

- Supabase

---

### 🧭 Navigation

- React Navigation (Bottom Tabs)

---

### 🎨 UI Components

- React Native Paper (Material Design)

---

### 🧠 State Management

- Redux Toolkit (if scaling later)

---

### 💾 Local Database (Offline First)

- SQLite

### 📊 Charts & Visualization

- react-native-chart-kit

---

### 📅 Date Handling

- dayjs (lightweight)

---

### 🔔 Notifications

- expo-notifications

---

### 🎨 Theming

- React Native Paper Theme System
- Custom color palette integration

---

## 📦 Key Components

### Screens

- Tracker Screen (daily input)
- Stats Screen (analytics)
- Settings Screen (notifications)

---

### Database

- SQLite schema for prayers
- CRUD operations

---

### State

- Global store for UI + data sync

---

### Utilities

- Date helpers
- Calculation logic

---

## 🚀 Development Goals

- Clean, production-ready code
- Fast and responsive UI
- Offline-first reliability
- Online reliability
- Simple user experience
- Cloud sync (Supabase

---

## 🧩 Future Improvements

- User accounts
- Backup & restore
- Advanced analytics
- Home screen widgets

---

## 📌 Notes for AI / Developers

- Keep logic simple
- Avoid over-engineering
- Focus on UX clarity
- Maintain consistent design
- Optimize for performance

---

## 🤲 Purpose

This app helps users build **consistency, discipline, and awareness** in daily
Salah through simple tracking and reflection.

---

**End of README**

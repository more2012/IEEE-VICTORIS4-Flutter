 Quick Actions Layout - Before & After

## Before (Horizontal Scrollable)
```
┌─────────────────────────────────────────────────────┐
│  [Add New Med] [Scan Medicine] [Find Alt] →         │
│  (Scrollable horizontally)                          │
└─────────────────────────────────────────────────────┘
```

## After (2x2 Static Grid)
```
┌─────────────────────────────────────────────────────┐
│  ┌──────────────┐  ┌──────────────┐                │
│  │      ➕      │  │      📷      │                │
│  │  Add New Med │  │Scan Medicine │                │
│  └──────────────┘  └──────────────┘                │
│                                                     │
│  ┌──────────────┐  ┌──────────────┐                │
│  │      🔍      │  │      💊      │                │
│  │   Find Alt   │  │   Nearby     │                │
│  │              │  │  Pharmacies  │                │
│  └──────────────┘  └──────────────┘                │
│  (Non-scrollable, fixed 2x2 grid)                  │
└─────────────────────────────────────────────────────┘
```

## Button Details

### 1. Add New Med
- **Icon**: ➕ (Icons.add)
- **Action**: Opens Add Medication Screen
- **Position**: Top-left

### 2. Scan Medicine
- **Icon**: 📷 (Icons.qr_code_scanner)
- **Action**: Opens Medication Scanner
- **Position**: Top-right

### 3. Find Alt
- **Icon**: 🔍 (Icons.search)
- **Action**: Opens Find Alternative Screen
- **Position**: Bottom-left

### 4. Nearby Pharmacies (NEW)
- **Icon**: 💊 (Icons.local_pharmacy)
- **Action**: Opens Google Maps with nearby pharmacies
- **Position**: Bottom-right

## User Flow for "Nearby Pharmacies"

```
User taps button
      ↓
Check location services
      ↓
Request permissions (if needed)
      ↓
Show loading indicator
      ↓
Get GPS coordinates
      ↓
Build Google Maps URL
      ↓
Launch Google Maps app
      ↓
Show nearby pharmacies (صيدلية)
```

## Technical Specifications

### Grid Configuration
- **Type**: `GridView.count`
- **Columns**: 2
- **Physics**: `NeverScrollableScrollPhysics()`
- **Aspect Ratio**: 1.5
- **Spacing**: 12px (both main and cross)

### Button Styling
- **Background**: `Color(0xff0284C7)` (Blue)
- **Border Radius**: 12px
- **Padding**: 12px horizontal, 8px vertical
- **Icon Size**: 28px
- **Text Size**: 13px (bold, white)
- **Layout**: Vertical (icon above text)

### Google Maps URL Format
```
https://www.google.com/maps/search/?api=1&query=صيدلية&center={latitude},{longitude}
```

### Error Handling
1. ⚠️ Location services disabled → Orange snackbar
2. ❌ Permission denied → Red snackbar
3. ❌ Permission permanently denied → Red snackbar
4. ⏳ Loading location → Blue snackbar with spinner
5. ❌ Maps launch failed → Red snackbar
6. ❌ Any other error → Red snackbar with details

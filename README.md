# Frontend Architecture Specification

---

# 1. Global Theming & UI/UX Standards

To ensure a premium, modern feel across all platforms, the application relies on strict theming rules and responsive layout constraints.

## **Color Palette**

* **Light Theme:** `Background Color(0xFFF9F6F0)`
* **Dark Theme:** `Background Color(0xFF1E1A18)`
* **Primary Accent:** `Vibrant Orange Color(0xFFFF6D00)`

## **Component Styling**

### **Glassmorphism**

Cards and inputs utilize semi-transparent fills (`Colors.white.withOpacity(0.05)` for dark mode) with subtle borders and background blurs (`BackdropFilter`).

### **Inputs**

Highly rounded, pill-shaped text fields (`BorderRadius.circular(30)`) applied globally across all authentication and onboarding screens.

### **Performance**

All logo assets must use:

* `filterQuality: FilterQuality.high`
* `isAntiAlias: true`

Layouts must utilize:

* `SingleChildScrollView`
* `Wrap`

to prevent **RenderFlex overflow** errors on smaller screens.

---

# 2. Authentication: The Login Screen

The login screen is the gateway. It must load seamlessly after the splash animation finishes.

## **Layout Structure**

### **Splash Synchronization**

Form fields start at `opacity: 0.0` and fade in smoothly only after the initial logo morphing animation completes.

### **Form Elements**

* **Title:** *"Welcome"*
* **Subtitle:** *"Login with your account"*

#### **Email Input**

* Glassmorphic pill shape
* `Icons.email_outlined` prefix

#### **Password Input**

* Glassmorphic pill shape
* Lock prefix
* Obscure text toggle (eye icon)

#### **Login Button**

* Full-width
* Vibrant Orange
* Elevated with a subtle shadow

### **Interactivity**

Text links like **"Create a clinic account"** must include hover states (`MouseRegion`) that underline the text and darken the color when accessed via web/desktop.

---

# 3. Onboarding: 5-Step Admin Sign-Up Wizard

A heavy data-entry process broken down into a frictionless, animated wizard using a `PageView` with `NeverScrollableScrollPhysics()`.

## **Wizard Architecture**

### **Progress Tracking**

A sleek `LinearProgressIndicator` attached directly to the inside top of the main scrolling glassmorphic form card, paired with dynamic text:

```text
STEP 1 OF 5
```

### **Navigation Footer**

A compact bottom row featuring:

* Muted **← Back** button
* Vibrant Orange **Next →** button

## **The 5 Steps**

### **Personal Info**

* Side-by-side generic inputs for **First Name** and **Last Name** (`Row + Expanded`)
* Username
* Email
* Phone Number

### **Clinic/Hospital Details**

Sequential inputs for:

* Clinic Name
* Registration/License Number
* Clinic Type dropdown
* Contact Number
* Email
* Full localized address fields

### **Verification**

* Clean 6-digit OTP input row
* Email verification
* Hover-enabled **"Resend OTP"** link

### **Security Setup**

* Password
* Confirm Password

Includes:

* Real-time animated password strength bar (**Red / Yellow / Green**)
* Visual checklist for:

  * Uppercase
  * Number
  * Special Character

### **Welcome / Success**

A minimalist confirmation screen featuring:

* Success emblem
* Brief paragraph explaining the AI-native hospital intelligence capabilities
* Final **"Go to Admin Dashboard"** button

---

# 4. Core Hub: The Admin Dashboard

The dashboard uses a shell architecture, combining an Instagram-style bottom navigation bar with a custom sliding drawer for maximum accessibility.

## **Navigation Shell**

### **Bottom Navigation**

5 icons corresponding to the primary tabs.

* Tapping animates the `PageController`
* Swiping left/right updates the active tab icon

### **Custom Drawer (Top-Left)**

#### **Header**

* Logo
* Clinic Name
* Admin Role

#### **Menu**

* Dashboard
* Schedule
* Users
* Logs
* Profile

#### **Disabled State**

**Future Modules**

* Billing
* Pharmacy
* Telemedicine

Displayed with:

* `0.4` opacity
* Lock icon

#### **Animation**

* Staggered **400ms** slide-and-fade
* Drawer dims the main screen behind it

---

# **Tab 1: Overview**

## **Dynamic Header**

* Time-based greeting (**Good Morning 👋**)
* Current date

## **KPI Grid**

4 cards showing:

* Today's Patients
* Today's Visits
* SOAP Notes
* Prescriptions

## **System Health**

Horizontally scrolling pills indicating:

* 🟢 Firebase
* 🟠 Database
* 🔴 Status

## **Recent Activity**

Condensed `ListView` tracking system events with timestamps.

---

# **Tab 2: Doctor Schedule**

## **Top Bar**

* Search input
* Time filters (**Today / Week**)
* Department dropdown

## **Grid Content**

Glassmorphic cards displaying:

* Doctor Name
* Time
* Room Number
* Status (**Available / Busy / On Leave**)

## **Actions**

* **+ Add Schedule** FAB

Each card includes a `PopupMenuButton` for:

* Edit
* Cancel
* Mark Leave
* Emergency Assignment

---

# **Tab 3: User Management**

## **Top Bar**

* Search
* Role filters
* Bulk Actions dropdown
* **+ Add Team Member** button

## **Directory**

User cards showing:

* Avatar
* Role
* Department
* Active / Inactive status pills

## **Detail Panel**

**View Profile** opens a modal bottom sheet containing:

* Employee ID
* License

Permission toggles:

* Edit Patients
* Create SOAP Notes

---

# **Tab 4: Audit Logs**

## **Top Bar**

Export menu:

* PDF
* Excel
* Print

## **Security Alerts**

High-priority scrolling row of warning cards:

* Failed Logins
* Account Locks

## **Log List**

`ExpansionTile`

### **Collapsed View**

* Success / Fail icon
* Action
* User

### **Expanded View**

* Device
* IP
* Location

---

# **Tab 5: Profile**

`SingleChildScrollView`

## **Personal Info**

* Editable fields
* Profile avatar updater

## **Verification**

* OTP triggers
* 2FA toggle

## **Security**

* Password changes
* Active device list
* Red **Logout All Devices** button

## **Preferences**

* Dark Mode
* Language
* Time Zone

---

# Installation

## **1. Clone the repository**

```bash
git clone https://github.com/kamalesh-medfliq/MedfilqApp.git
cd MedfilqApp
```

## **2. Install dependencies**

```bash
flutter pub get
```

## **3. Run the app**

```bash
flutter run
```

---

# 5. Full-Stack Integration (Recent Updates)

## **Networking & API**
- **ApiClient (`dio`)**: Implemented a robust singleton `ApiClient` to manage network requests across Web, Android, and iOS.
- **JWT Authentication**: Integrated `flutter_secure_storage` to securely cache JWT tokens. A global Dio Interceptor automatically attaches `Authorization: Bearer <token>` to all protected routes.
- **State Management**: Built `AuthProvider` to centralize the `registerClinic` and `login` logic, gracefully handling `_isLoading` UI states and error parsing.

## **UI Polish & Theming**
- **System Overlay**: Added `SystemUiOverlayStyle` to blend the Android system bottom navigation bar flawlessly with the application's edge-to-edge dark/light theme.
- **Typography**: Upgraded the entire application's font stack to **Roboto Regular 400** via `google_fonts` for maximum readability and a premium feel.
- **Micro-Animations**: Enhanced the bottom navigation bar with WhatsApp-style `AnimatedScale` pop animations and `HapticFeedback.lightImpact()` on tap.
- **Dynamic Routing**: Configured the App Bar to dynamically update titles (e.g., "Doctor Schedule", "User Management") based on the actively selected shell tab.

## **Data Hydration**
- **User Management Tab**: Connected the dashboard directory to the backend `GET /users` API. Replaced static dummy placeholders with real, secure data parsed directly from the PostgreSQL database.

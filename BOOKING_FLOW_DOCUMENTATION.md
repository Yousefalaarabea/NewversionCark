# 🚗 Complete Booking Flow Documentation

## Overview
This document describes the complete booking flow for the Cark application, covering both renter and owner journeys from signup to trip completion.

## 🔄 Complete Flow Overview

### 👤 Renter Flow (Without Driver)

1. **Sign Up** → **Search Screen** → **Home Screen** → **Car Selection** → **Booking Request** → **Owner Acceptance** → **Deposit Payment** → **Owner Handover** → **Renter Handover** → **Trip Management**

### 👤 Owner Flow

1. **Receive Booking Request** → **Accept/Decline** → **Receive Deposit Notification** → **Complete Handover** → **Receive Renter Handover Notification** → **Trip Monitoring**

## 📋 Detailed Flow Breakdown

### Step 1: Sign Up & Navigation
- **Screen**: `SignUpScreen`
- **Action**: User completes registration
- **Navigation**: `SignUpScreen` → `RentalSearchScreen`
- **FCM Token**: Automatically saved to Firestore

### Step 2: Search & Location Selection
- **Screen**: `RentalSearchScreen`
- **Actions**:
  - Select pickup/drop-off locations
  - Choose dates
  - Select payment method
  - Choose driver option (with/without)
- **Navigation**: `RentalSearchScreen` → `HomeScreen`

### Step 3: Car Selection
- **Screen**: `HomeScreen`
- **Actions**:
  - Browse available cars
  - View car details
  - Select car for booking
- **Navigation**: `HomeScreen` → `CarDetailsScreen`

### Step 4: Booking Request Creation
- **Screen**: `BookingSummaryScreen`
- **Actions**:
  - Review booking details
  - Agree to terms
  - Create booking request
- **Notifications**: 
  - Owner receives FCM notification
  - Owner receives in-app notification
- **Navigation**: `BookingSummaryScreen` → `HomeScreen` (with confirmation dialog)

### Step 5: Owner Response
- **Screen**: `OwnerNotificationScreen`
- **Actions**:
  - Owner receives booking request notification
  - Owner can Accept or Decline
- **Notifications**:
  - Renter receives acceptance/decline notification
- **Navigation**: If accepted → Renter proceeds to deposit payment

### Step 6: Deposit Payment
- **Screen**: `DepositPaymentScreen`
- **Actions**:
  - Renter pays deposit (20% of total price)
  - Booking status updated to 'deposit_paid'
- **Notifications**:
  - Owner receives deposit paid notification
  - Owner receives handover ready notification
- **Navigation**: `DepositPaymentScreen` → `HomeScreen`

### Step 7: Owner Handover
- **Screen**: `HandoverScreen`
- **Actions**:
  - Owner uploads contract
  - Owner confirms handover conditions
  - Owner submits handover
- **Notifications**:
  - Renter receives owner handover completed notification
- **Navigation**: `HandoverScreen` → `RenterHandoverScreen`

### Step 8: Renter Handover
- **Screen**: `RenterHandoverScreen`
- **Actions**:
  - Renter uploads car images
  - Renter enters odometer reading
  - Renter pays remaining amount
  - Renter confirms contract
  - Renter submits handover
- **Notifications**:
  - Owner receives renter handover completed notification
- **Navigation**: `RenterHandoverScreen` → `TripManagementScreen`

### Step 9: Trip Management
- **Screen**: `TripManagementScreen`
- **Actions**:
  - Start trip
  - Monitor trip progress
  - Complete trip
  - Final payment
- **Navigation**: `TripManagementScreen` → `PaymentScreen` → `HomeScreen`

## 🔧 Technical Implementation

### FCM Token Management
```dart
// Enhanced FCM token saving with retry mechanism
Future<void> saveFcmTokenWithRetry({int maxRetries = 3}) async {
  // Implementation in AuthCubit
}
```

### Notification Service
```dart
// Complete notification methods
- sendCarBookedNotification()
- sendBookingAcceptanceNotification()
- sendHandoverNotificationToOwner()
- sendOwnerHandoverCompletedNotification()
- sendRenterHandoverCompletedNotification()
```

### Booking Cubit States
```dart
// Complete state management
- BookingRequestCreated
- BookingRequestAccepted
- BookingRequestDeclined
- DepositPaid
- OwnerHandoverCompleted
- RenterHandoverCompleted
- TripStarted
- TripCompleted
```

### Firestore Collections
```dart
// Data persistence
- users (with fcm_token field)
- booking_requests (complete booking lifecycle)
- notifications (in-app notifications)
- bookings (booking history)
```

## 🛡️ Error Handling & Robustness

### Mounted Checks
- All async operations check `if (!mounted) return;`
- Prevents calling context after widget disposal

### Graceful Error Handling
- FCM token failures don't crash the app
- Notification failures don't block booking flow
- Firestore errors are logged but don't throw exceptions

### Retry Mechanisms
- FCM token saving with exponential backoff
- Network operation retries where appropriate

## 📱 Screen Navigation Map

```
SignUpScreen
    ↓
RentalSearchScreen
    ↓
HomeScreen
    ↓
CarDetailsScreen
    ↓
BookingSummaryScreen
    ↓
[Owner receives notification]
    ↓
OwnerNotificationScreen
    ↓
[If accepted] → DepositPaymentScreen
    ↓
[Owner receives notification] → HandoverScreen
    ↓
[Renter receives notification] → RenterHandoverScreen
    ↓
[Owner receives notification] → TripManagementScreen
    ↓
PaymentScreen
    ↓
HomeScreen
```

## 🔔 Notification Flow

### Owner Notifications
1. **New Booking Request** (FCM + In-app)
2. **Deposit Paid** (FCM + In-app)
3. **Handover Ready** (FCM + In-app)
4. **Renter Handover Completed** (FCM + In-app)

### Renter Notifications
1. **Booking Request Accepted** (FCM + In-app)
2. **Booking Request Declined** (FCM + In-app)
3. **Owner Handover Completed** (FCM + In-app)

## 🎯 Key Features

### ✅ Completed Features
- Complete FCM token management
- Robust notification delivery
- Full booking lifecycle management
- Error handling and mounted checks
- Comprehensive state management
- Complete navigation flow
- Data persistence in Firestore

### 🔄 Booking Status Flow
```
pending → accepted → deposit_paid → owner_handover_completed → trip_started → completed
```

### 📊 Data Tracking
- All booking requests tracked in Firestore
- Complete notification history
- User FCM tokens for push notifications
- Booking history for users

## 🚀 Getting Started

1. **Setup Firebase**: Ensure Firebase project is configured
2. **FCM Configuration**: Add FCM configuration files
3. **Firestore Rules**: Configure appropriate security rules
4. **Testing**: Test the complete flow with both renter and owner accounts

## 📝 Notes

- The flow supports both "with driver" and "without driver" options
- All notifications are sent both via FCM and stored in Firestore
- The system gracefully handles missing FCM tokens
- Error handling prevents app crashes while maintaining functionality
- The booking flow is fully integrated with the existing UI components 
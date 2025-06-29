# Owner Pick-Up Handover Feature

## Overview
This feature implements a complete handover process for car rental owners to finalize the rental agreement. It includes deposit verification, contract upload, confirmations, and handover completion.

## Architecture

### Clean Architecture Structure
```
lib/features/handover/
├── presentation/
│   ├── cubits/
│   │   ├── contract_upload_cubit.dart
│   │   ├── contract_upload_state.dart
│   │   ├── handover_cubit.dart
│   │   └── handover_state.dart
│   ├── models/
│   │   └── contract_model.dart
│   ├── screens/
│   │   ├── handover_screen.dart
│   │   └── handover_test_screen.dart
│   └── widgets/
│       ├── contract_upload_widget.dart
│       ├── deposit_status_widget.dart
│       └── confirmation_checkboxes_widget.dart
└── README.md
```

## Components Explanation

### 1. Models

#### ContractModel
- **Purpose**: Represents the contract data and handover state
- **Key Properties**:
  - `depositAmount`: The required deposit amount
  - `isDepositPaid`: Whether deposit has been paid
  - `contractImagePath`: Path to uploaded contract image
  - `isContractSigned`: Confirmation of contract signing
  - `isRemainingAmountReceived`: Confirmation of remaining amount
  - `status`: Current handover status ('pending', 'completed', 'cancelled')

### 2. Cubits (State Management)

#### ContractUploadCubit
- **Purpose**: Manages contract image upload functionality
- **Key Methods**:
  - `pickContractImage()`: Pick image from camera or gallery
  - `clearContractImage()`: Remove uploaded image
  - `hasContractImage`: Check if image is uploaded

#### HandoverCubit
- **Purpose**: Manages the complete handover process
- **Key Methods**:
  - `loadContractData()`: Load initial contract data
  - `updateContractSigned()`: Update contract signing confirmation
  - `updateRemainingAmountReceived()`: Update remaining amount confirmation
  - `sendHandover()`: Complete handover process
  - `cancelHandover()`: Cancel and refund deposit
  - `canSendHandover`: Check if handover can be sent

### 3. UI Widgets

#### ContractUploadWidget
- **Features**:
  - Image picker with camera/gallery options
  - Image preview with remove functionality
  - Loading states and error handling
  - Responsive design

#### DepositStatusWidget
- **Features**:
  - Visual deposit status indicator
  - Color-coded status (green for paid, red for unpaid)
  - Amount display

#### ConfirmationCheckboxesWidget
- **Features**:
  - Interactive checkboxes for confirmations
  - Visual feedback for selected states
  - Clear instructions for each confirmation

### 4. Main Screen

#### HandoverScreen
- **Features**:
  - Complete handover workflow
  - Conditional UI based on deposit status
  - Action buttons (Send Handover, Cancel)
  - Success/error notifications
  - Help dialog
  - Responsive design

## Key Features Implemented

### ✅ Deposit Status Check
- Shows if deposit has been paid or not
- Disables further actions if deposit is unpaid
- Visual warning message for unpaid deposits

### ✅ Contract Image Upload
- Camera and gallery image picker
- Image preview with remove option
- Error handling for upload failures
- Image quality optimization

### ✅ Confirmation Checkboxes
- Contract signing confirmation
- Remaining amount receipt confirmation
- Visual feedback for selections
- Required for handover completion

### ✅ Send Handover Button
- Only enabled when all requirements are met:
  - Deposit is paid
  - Contract image is uploaded
  - Both confirmations are checked
- Loading state during processing
- Success/error feedback

### ✅ Cancel Functionality
- Confirmation dialog before cancellation
- Simulates deposit refund to wallet
- Success notification
- Navigation back to previous screen

### ✅ State Management
- Proper loading states
- Error handling
- Success notifications
- Clean state transitions

### ✅ UI/UX Features
- Responsive design
- Consistent with app theme
- Loading indicators
- Error messages
- Success notifications
- Help dialog

## Usage

### Navigation
```dart
// Navigate to handover screen
Navigator.pushNamed(context, ScreensName.handoverScreen);
```

### Testing
Use the `HandoverTestScreen` to test the feature:
```dart
// Navigate to test screen
Navigator.pushNamed(context, '/handoverTest');
```

## Dependencies
- `flutter_bloc`: State management
- `image_picker`: Image selection from camera/gallery
- `dart:io`: File handling for images

## Mock Data
The implementation uses mock data for demonstration:
- Contract data is loaded from `ContractModel.mock()`
- API calls are simulated with delays
- Deposit status can be modified in the mock data

## Customization
To integrate with real APIs:
1. Replace mock data loading in `HandoverCubit.loadContractData()`
2. Implement real API calls in `sendHandover()` and `cancelHandover()`
3. Update `ContractModel` to match your API response structure
4. Add proper error handling for network failures

## Error Handling
- Image upload failures
- Network errors
- Invalid states
- User cancellations
- All errors are displayed via snackbars

## Future Enhancements
- Real API integration
- Image compression
- Multiple image uploads
- Digital signature support
- Offline support
- Push notifications
- Analytics tracking 
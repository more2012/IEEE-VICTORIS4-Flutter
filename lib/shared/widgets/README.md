 Shared Widgets

## 📁 Structure

```
lib/shared/widgets/
├── custom_text_field.dart    # Enhanced TextFormField widget
├── otp_input_widget.dart     # OTP input widget
└── README.md                 # This file
```

## 🎨 Custom TextField Widget

### **Features**
- **Enhanced UI Design**: Modern, clean design with shadows and animations
- **Multiple Input Types**: Email, password, name, phone, OTP, confirm password
- **Auto Icons**: Automatic prefix icons based on input type
- **Password Visibility**: Toggle password visibility with eye icon
- **Focus States**: Visual feedback on focus with color changes and shadows
- **Validation Support**: Built-in validation with custom error styling
- **Customizable**: Support for custom icons, hints, and styling

### **Usage**

```dart
// Basic usage
CustomTextField(
  controller: emailController,
  labelText: 'Email',
  type: TextFieldType.email,
  validator: validateEmail,
)

// With custom hint
CustomTextField(
  controller: passwordController,
  labelText: 'Password',
  type: TextFieldType.password,
  hintText: 'Enter your password',
  validator: validatePassword,
)

// With custom icon
CustomTextField(
  controller: nameController,
  labelText: 'Full Name',
  type: TextFieldType.name,
  prefixIcon: Icon(Icons.person),
  validator: validateName,
)
```

### **TextField Types**

| Type | Description | Icon | Keyboard |
|------|-------------|------|----------|
| `email` | Email input | 📧 | Email |
| `password` | Password input | 🔒 | Text |
| `name` | Name input | 👤 | Text |
| `phone` | Phone input | 📱 | Phone |
| `otp` | OTP input | 🔐 | Number |
| `confirmPassword` | Confirm password | 🔒 | Text |

### **Properties**

| Property | Type | Description |
|----------|------|-------------|
| `controller` | `TextEditingController` | Text controller |
| `labelText` | `String` | Field label |
| `type` | `TextFieldType` | Input type |
| `validator` | `String? Function(String?)?` | Validation function |
| `hintText` | `String?` | Placeholder text |
| `enabled` | `bool` | Enable/disable field |
| `maxLength` | `int?` | Maximum character length |
| `keyboardType` | `TextInputType?` | Keyboard type |
| `prefixIcon` | `Widget?` | Custom prefix icon |
| `suffixIcon` | `Widget?` | Custom suffix icon |
| `onTap` | `VoidCallback?` | Tap callback |
| `onChanged` | `ValueChanged<String>?` | Change callback |
| `focusNode` | `FocusNode?` | Focus node |
| `textInputAction` | `TextInputAction?` | Input action |
| `onSubmitted` | `VoidCallback?` | Submit callback |

## 🔢 OTP Input Widget

### **Features**
- **Multiple Digits**: Configurable number of OTP digits (default: 6)
- **Auto Focus**: Automatic focus movement between fields
- **Auto Complete**: Callback when all digits are entered
- **Custom Styling**: Modern design with shadows and animations
- **Easy Integration**: Simple to use with existing forms

### **Usage**

```dart
// Basic usage
OTPInputWidget(
  length: 6,
  onCompleted: (otp) {
    print('OTP: $otp');
  },
)

// With change callback
OTPInputWidget(
  length: 4,
  onChanged: (otp) {
    print('Current OTP: $otp');
  },
  onCompleted: (otp) {
    // Verify OTP
    verifyOTP(otp);
  },
)

// With key for external access
final GlobalKey<OTPInputWidgetState> otpKey = GlobalKey<OTPInputWidgetState>();

OTPInputWidget(
  key: otpKey,
  length: 6,
  onCompleted: (otp) {
    // Auto-verify
  },
)

// Get OTP programmatically
String otp = otpKey.currentState?.getOTP() ?? '';
```

### **Properties**

| Property | Type | Description |
|----------|------|-------------|
| `length` | `int` | Number of OTP digits (default: 6) |
| `onCompleted` | `ValueChanged<String>?` | Called when all digits entered |
| `onChanged` | `ValueChanged<String>?` | Called on each digit change |
| `enabled` | `bool` | Enable/disable widget |

### **Methods**

| Method | Description |
|--------|-------------|
| `getOTP()` | Get current OTP string |
| `clearOTP()` | Clear all digits and focus first field |

## 🎨 Design Features

### **Visual Enhancements**
- **Shadows**: Subtle shadows for depth
- **Focus States**: Blue border and shadow on focus
- **Smooth Animations**: Smooth transitions between states
- **Modern Styling**: Rounded corners and clean design
- **Color Scheme**: Consistent with app theme

### **Accessibility**
- **Screen Reader Support**: Proper labels and hints
- **Keyboard Navigation**: Full keyboard support
- **High Contrast**: Clear visual feedback
- **Touch Targets**: Adequate touch target sizes

### **Performance**
- **Efficient Rendering**: Optimized widget tree
- **Memory Management**: Proper disposal of controllers
- **Minimal Rebuilds**: Efficient state management

## 🔧 Customization

### **Theme Integration**
The widgets automatically integrate with your app's theme:
- Uses `Colors.blue` for primary color
- Adapts to light/dark themes
- Consistent with Material Design

### **Custom Styling**
You can customize the appearance by:
- Providing custom icons
- Overriding keyboard types
- Adding custom validators
- Using custom focus nodes

## 📱 Examples

### **Login Form**
```dart
Column(
  children: [
    CustomTextField(
      controller: emailController,
      labelText: 'Email',
      type: TextFieldType.email,
      validator: validateEmail,
    ),
    SizedBox(height: 20),
    CustomTextField(
      controller: passwordController,
      labelText: 'Password',
      type: TextFieldType.password,
      validator: validatePassword,
    ),
  ],
)
```

### **Registration Form**
```dart
Column(
  children: [
    CustomTextField(
      controller: nameController,
      labelText: 'Full Name',
      type: TextFieldType.name,
      validator: validateName,
    ),
    SizedBox(height: 20),
    CustomTextField(
      controller: emailController,
      labelText: 'Email',
      type: TextFieldType.email,
      validator: validateEmail,
    ),
    SizedBox(height: 20),
    CustomTextField(
      controller: phoneController,
      labelText: 'Phone',
      type: TextFieldType.phone,
      validator: validatePhone,
    ),
    SizedBox(height: 20),
    CustomTextField(
      controller: passwordController,
      labelText: 'Password',
      type: TextFieldType.password,
      validator: validatePassword,
    ),
    SizedBox(height: 20),
    CustomTextField(
      controller: confirmPasswordController,
      labelText: 'Confirm Password',
      type: TextFieldType.confirmPassword,
      validator: validateConfirmPassword,
    ),
  ],
)
```

### **OTP Verification**
```dart
Column(
  children: [
    Text('Enter OTP sent to your phone'),
    SizedBox(height: 20),
    OTPInputWidget(
      length: 6,
      onCompleted: (otp) {
        verifyOTP(otp);
      },
    ),
  ],
)
```

## 🚀 Future Enhancements

- [ ] Animation support for focus states
- [ ] Custom color themes
- [ ] More input types (date, time, etc.)
- [ ] Auto-formatting for phone numbers
- [ ] Biometric authentication integration
- [ ] Voice input support
- [ ] Multi-language support

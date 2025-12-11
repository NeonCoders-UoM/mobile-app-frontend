# Tech Stack Documentation

## Overview
This is a **Flutter-based mobile application** for vehicle management and service tracking. The application follows a clean architecture pattern with separation of concerns across presentation, business logic, and data layers.

## Core Technology

### Framework & Language
- **Flutter SDK**: Cross-platform mobile application framework
  - SDK Version: `^3.6.0`
  - Language: **Dart** (version ^3.6.0)
  - Cross-platform support: Android, iOS, Web, Windows, Linux, macOS

### Architecture Pattern
The application follows a **layered architecture** with clear separation:
- **Presentation Layer** (`lib/presentation/`): UI components, pages, templates
- **State Management Layer** (`lib/state/`): BLoCs and Providers
- **Data Layer** (`lib/data/`): Models and Repositories
- **Core Layer** (`lib/core/`): Configuration, constants, utilities, services, network, theme
- **Services Layer** (`lib/services/`): Business services (e.g., authentication)

## State Management

### Primary State Management
- **Provider** (v6.0.5): The main state management solution
  - Used for dependency injection
  - Manages application-wide state (VehicleProvider, etc.)
  - ChangeNotifierProvider pattern for reactive state updates

### State Organization
- **BLoCs**: Business Logic Components located in `lib/state/blocs/`
- **Providers**: State providers located in `lib/state/providers/`

## Key Dependencies

### HTTP & Networking
- **http** (v1.2.2): Standard HTTP client for REST API calls
- **dio** (v5.8.0+1): Advanced HTTP client with interceptors and better error handling
- Backend Integration: Connects to a backend API (default: `http://localhost:5039`)

### UI & Design
- **Material Design**: Primary design system (uses-material-design: true)
- **Cupertino Icons** (v1.0.8): iOS-style icons
- **Google Fonts** (v6.2.1): Custom typography
- **flutter_svg** (v2.0.17): SVG rendering support
- **dash_painter** (v1.0.2): Custom painting utilities
- **fl_chart** (v0.70.2): Data visualization and charts (for fuel usage graphs, etc.)
- **flutter_html** (v3.0.0-beta.2): HTML rendering
- **dotted_border** (v2.1.0): Custom border decorations

### Maps & Location
- **google_maps_flutter** (v2.9.0): Google Maps integration for location services
- **geolocator** (v12.0.0): Location and geolocation services

### Data Persistence
- **shared_preferences** (v2.5.3): Local key-value storage for user preferences and settings

### Document & File Management
- **file_picker** (v6.1.1): File selection from device storage
- **path_provider** (v2.1.1): Access to commonly used file system locations
- **flutter_pdfview** (v1.3.2): PDF viewing capabilities

### Utilities
- **intl** (v0.17.0): Internationalization and date/time formatting
- **url_launcher** (v6.1.11): Launch URLs, phone calls, emails, etc.

### Payment Integration
- **payhere_mobilesdk_flutter** (v3.1.1): PayHere payment gateway integration for Sri Lankan payment processing

## Development Tools

### Code Quality
- **flutter_lints** (v5.0.0): Recommended linting rules for Flutter
- **analysis_options.yaml**: Dart analyzer configuration following `package:flutter_lints/flutter.yaml`

### Testing
- **flutter_test**: Flutter's testing framework (SDK package)
- Test directory structure: `test/` folder with various integration and unit tests

## Platform-Specific Configuration

### Android
- **Namespace**: `com.example.mobile_app_frontend`
- **Build System**: Gradle
- **SDK Configuration**: Uses Flutter's compileSdkVersion
- **Manifest Files**: Profile, Debug, and Main manifests for different build types

### iOS
- **Configuration**: Standard iOS Runner setup
- **Build System**: CocoaPods (Podfile)
- **Info.plist**: iOS app configuration

### Web Support
- Web deployment scripts: `start-web.bat` and `start-web.ps1`
- Web-specific configurations in `web/` directory

### Desktop Support
- **Windows**: Native Windows support with dedicated configuration
- **Linux**: Linux desktop support
- **macOS**: macOS desktop application support

## Assets & Resources

### Custom Fonts
- **Montserrat** font family (Regular, Bold, Italic)

### Icons & Images
- SVG icons for various features (fuel efficiency, service history, emergency, etc.)
- PNG images for UI elements
- Animated GIFs for enhanced UX
- Payment card icons (Visa, Mastercard, Amex, PayPal)

## Application Features (Based on Dependencies)

1. **Vehicle Management**: Track and manage vehicle information
2. **Service History**: Record and view service records
3. **Fuel Efficiency Tracking**: Monitor and visualize fuel consumption
4. **Reminders**: Set maintenance and service reminders
5. **Emergency Services**: Quick access to emergency contacts/services
6. **Appointments**: Schedule service appointments
7. **Document Management**: Upload and view vehicle documents (PDFs)
8. **Payment Processing**: Integrated PayHere payment gateway
9. **Location Services**: Google Maps integration for service centers
10. **Loyalty Points**: Customer loyalty program integration
11. **Feedback System**: User feedback collection
12. **Authentication**: User authentication and authorization

## Backend Integration

### API Communication
- **Base URL**: Configurable (default: `http://localhost:5039`)
- **Authentication**: Token-based authentication system
- **Data Transfer Objects (DTOs)**: Backend integration with structured DTOs
- **CORS Configuration**: Cross-Origin Resource Sharing setup documented

### Data Synchronization
- Real-time data sync with backend
- Proper date formatting and handling
- Cost tracking and validation
- Customer data flow management

## Build & Development Scripts

- Standard Flutter build commands (`flutter build`)
- Web deployment scripts for easy web version launching
- Debug utilities for testing specific features
- Multiple test harness files for backend integration testing

## Version Control & Documentation

### Git Configuration
- `.gitignore`: Properly configured to exclude build artifacts and IDE files
- Multiple feature implementation documentation files (MD files)
- Comprehensive integration guides for various features

## Development Workflow

### Quality Assurance
1. Linting with `flutter analyze` using `flutter_lints` rules
2. Testing with `flutter test`
3. Debug utilities for specific feature testing
4. Backend integration testing

### Code Organization
- Clean architecture principles
- Separation of concerns
- Repository pattern for data access
- Provider pattern for state management
- Modular feature organization

## Summary

This is a **production-ready Flutter application** using modern development practices:
- **Cross-platform**: Supports Android, iOS, Web, and Desktop
- **State Management**: Provider-based architecture
- **Backend Integration**: RESTful API communication with proper authentication
- **Rich Features**: Maps, payments, documents, charts, and more
- **Quality**: Linting, testing, and clean architecture
- **Scalable**: Modular design with clear separation of concerns

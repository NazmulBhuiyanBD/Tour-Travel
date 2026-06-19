# NAZTRAVEL - Tour & Travel Management System

A comprehensive, full-stack Tour and Travel Management system built with a Flutter cross-platform mobile application and an ASP.NET Core Web API backend. 

## 🚀 Features

### User Mobile App
* **Interactive UI:** Smooth transitions, rich UI design, and an intuitive dashboard.
* **Authentication & Profiles:** Secure login, signup, and profile management for travelers.
* **Travel Booking:** Discover, search, and book flights, hotels, and guided tour packages globally.
* **Real-time Live Chat:** Connect securely with customer support via SignalR powered live chat.
* **Curated Content:** View trending packages, top destinations, and popular airlines dynamically managed by admins.

### Admin Console
* **Multi-Tier Admin Roles:** Role-based access control protecting critical actions with Super Admin & Standard Admin separation.
* **Dashboard Analytics:** High-level metrics for revenue, active users, and recent bookings.
* **Asset Management:** Fully integrated CMS to Create, Edit, and Delete data for Users, Air Tickets, Hotels, and Tours.
* **Support System Management:** Respond to active user queries in real-time through the dedicated Admin Chat interface.
* **Featured Content Curation:** Control what goes on the front page by managing top destinations, featured hotels, and popular airlines.

## 🛠 Technology Stack

**Frontend (Mobile & Cross-Platform)**
* **Flutter framework** with Dart
* **GetX** for Reactive State Management, Dependency Injection, and Routing
* **HTTP** for RESTful API Integration
* **SignalR Client** for WebSockets & Real-time Chat

**Backend (RESTful API)**
* **C# / ASP.NET Core Web API**
* **Entity Framework Core** for ORM
* **JWT (JSON Web Tokens)** for secure Stateless Authentication
* **SignalR** for low-latency Real-time Messaging Protcols

---

## 📸 Screenshots

### User App

#### Authentication
| Onboarding Screen 1 | Onboarding Screen 2 | Login |
|:---:|:---:|:---:|
| <img src="screenshots/onbroading_screen.png" width="250"/> | <img src="screenshots/onbroading_screen2.png" width="250"/> | <img src="screenshots/user_login.png" width="250"/> |

| Registration | Forgot Password | Email Verification |
|:---:|:---:|:---:|
| <img src="screenshots/user_registration.png" width="250"/> | <img src="screenshots/forget_password.png" width="250"/> | <img src="screenshots/verify_email.png" width="250"/> |

#### Home & Navigation
| Dashboard | Home | Menu |
|:---:|:---:|:---:|
| <img src="screenshots/user_dashboard.png" width="250"/> | <img src="screenshots/user_home.png" width="250"/> | <img src="screenshots/user_menu.png" width="250"/> |

#### Services - Browsing
| Browse Tours | Browse Flights | Browse Hotels |
|:---:|:---:|:---:|
| <img src="screenshots/user_tour.png" width="250"/> | <img src="screenshots/browse_flight.png" width="250"/> | <img src="screenshots/user_hotels.png" width="250"/> |

#### Services - Booking
| Flight Booking | Tour Booking | Hotel Booking |
|:---:|:---:|:---:|
| <img src="screenshots/flight_booking.png" width="250"/> | <img src="screenshots/tour_booking.png" width="250"/> | <img src="screenshots/hotel_booking.png" width="250"/> |

#### User Features
| Flights | Notifications | Reviews |
|:---:|:---:|:---:|
| <img src="screenshots/user_flight.png" width="250"/> | <img src="screenshots/user_notification .png" width="250"/> | <img src="screenshots/user_review.png" width="250"/> |

#### Support & Help
| Help & Support | Support Tickets |
|:---:|:---:|
| <img src="screenshots/user_help_support.png" width="250"/> | <img src="screenshots/user_support_tickets.png" width="250"/> |

### Admin Console

#### Authentication & Dashboard
| Admin Login | Dashboard | Revenue |
|:---:|:---:|:---:|
| <img src="screenshots/admin_login.png" width="250"/> | <img src="screenshots/admin_dashboard.png" width="250"/> | <img src="screenshots/admin_revenue.png" width="250"/> |

#### Inventory Management
| Tours Management | Air Tickets | Hotels |
|:---:|:---:|:---:|
| <img src="screenshots/admin_tours.png" width="250"/> | <img src="screenshots/admin_air_tickets.png" width="250"/> | <img src="screenshots/admin_hotel.png" width="250"/> |

#### Content Control
| Top Destinations | Popular Airlines |
|:---:|:---:|
| <img src="screenshots/admin_top_destination.png" width="250"/> | <img src="screenshots/admin_popular_airlines.png" width="250"/> |

#### User & Transaction Management
| Manage Users | Bookings | Refunds |
|:---:|:---:|:---:|
| <img src="screenshots/admin_manage_user.png" width="250"/> | <img src="screenshots/admin_booking.png" width="250"/> | <img src="screenshots/admin_refund.png" width="250"/> |

#### Support & Communication
| Support Management |
|:---:|
| <img src="screenshots/admin_support.png" width="250"/> |

---

## 🏗 Setup & Installation

### 1. Backend (ASP.NET Core)
1. Navigate to the backend directory:
   ```bash
   cd backend/Tour_&_Travel_api
   ```
2. Update the `appsettings.json` with your preferred database connection string and JWT secret properties.
3. Apply database migrations to build your schema:
   ```bash
   dotnet ef database update
   ```
4. Run the API:
   ```bash
   dotnet run
   ```

### 2. Frontend (Flutter)
1. Navigate to the frontend directory:
   ```bash
   cd front-end/tour_and_travel
   ```
2. Get the necessary packages:
   ```bash
   flutter pub get
   ```
3. Update your local backend IP address/endpoints in `lib/core/constant/api_constants.dart` if needed.
4. Run the application:
   ```bash
   flutter run
   ```

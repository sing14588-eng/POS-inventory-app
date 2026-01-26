# POS & Inventory Mobile App MVP

This is an MVP for a Balloon & Cushion business POS system.
It consists of a Node.js Backend and a Flutter Mobile App.

## Prerequisites
- Node.js (v14+)
- MongoDB (Running locally on default port 27017)
- Flutter SDK (v3.0+)

## Project Structure
- `backend/`: Node.js + Express API
- `mobile_app/`: Flutter App

## Setup & Run Instructions

### 1. Backend Setup
1. Navigate to the backend folder:
   ```bash
   cd backend
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Start MongoDB if not running:
   ```bash
   mongod
   ```
4. Start the server:
   ```bash
   node server.js
   ```
   Server runs on `http://localhost:5000`.

### 2. Mobile App Setup
1. Navigate to the mobile app folder:
   ```bash
   cd mobile_app
   ```
2. Get dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

## User Roles (Login Credentials)
First time start, run the seed endpoint or use the verification script.
Or use these default credentials if seeded:

| Role      | Email             | Password |
|-----------|-------------------|----------|
| Sales     | sales@test.com    | 123      |
| Picker    | picker@test.com   | 123      |
| Accountant| acc@test.com      | 123      |
| Warehouse | ware@test.com     | 123      |

## Features MVP
- **Auth**: Role-based login.
- **Warehouse**: Add Products, Update Stock.
- **POS (Sales)**: Add items to cart, Checkout (Piece/Weight), Stock validation.
- **Picker**: View pending orders, Mark as prepared.
- **Reports**: Daily sales, VAT (15%), Credit sales stats.

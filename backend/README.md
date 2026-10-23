# CampusVerse — REST API Backend Server

This is the standalone **Node.js Express REST API server** for **CampusVerse**, providing shared multi-device event registration, atomic QR ticket verification, and gate check-in synchronization.

---

## 1. Quick Start

### Prerequisites
- Node.js (v18+) installed.

### Setup & Run
```bash
# Navigate to backend directory
cd backend

# Install dependencies (Express, CORS)
npm install

# Start the server
npm start
```

The server starts on port `3000`:
- **Health Check**: `http://localhost:3000/health`
- **Events API**: `http://localhost:3000/api/v1/events`
- **Auth API**: `http://localhost:3000/api/v1/auth/login`
- **Ticket Verification API**: `http://localhost:3000/api/v1/tickets/verify`

---

## 2. Connecting the Flutter Application

1. Open the **CampusVerse** Flutter app.
2. Navigate to **Profile** → **Developer & API Configuration**.
3. Set the **Remote API Base URL** to:
   ```text
   http://localhost:3000/api/v1
   ```
4. Tap **"Test Connection"** to measure live round-trip latency.
5. Toggle **"Live REST API Mode"** ON.
6. The app will now fetch and synchronize registrations and ticket check-ins against this live backend!

---

## 3. Endpoints Documentation

| Method | Endpoint | Description | Auth Required |
|---|---|---|:---:|
| `GET` | `/health` | Server health check & database count | No |
| `GET` | `/api/v1/events` | List campus events (supports `?category=` and `?search=`) | No |
| `GET` | `/api/v1/events/:id` | Get event by ID | No |
| `POST` | `/api/v1/events` | Create new event | Organizer |
| `DELETE` | `/api/v1/events/:id` | Delete event | Organizer |
| `POST` | `/api/v1/auth/register` | Register student account with salted SHA-256 hash | No |
| `POST` | `/api/v1/auth/login` | Authenticate student or organizer | No |
| `POST` | `/api/v1/events/:id/register` | Register student for event with collision-proof UUID pass | Student |
| `GET` | `/api/v1/registrations` | Get registrations (`?studentRoll=` or `?eventId=`) | Yes |
| `POST` | `/api/v1/tickets/verify` | Atomically verify QR ticket format, event match, check-in state | Organizer |
| `POST` | `/api/v1/tickets/check-in` | Atomically admit student and mark ticket as checked in | Organizer |

# LifeGuard Finance API Usage Guide

## Authentication

All endpoints (except health check) require a Firebase ID Token in the Authorization header:

```
Authorization: Bearer <firebase_id_token>
```

### Step 1: Login via Flutter
Your Flutter app handles Firebase login and obtains an ID token.

### Step 2: Sync User
After first login, sync the user to the backend:

```
POST /api/v1/auth/sync-user
Content-Type: application/json
Authorization: Bearer <token>

{
  "firebaseUid": "abc123",
  "email": "user@example.com",
  "displayName": "John Doe"
}
```

Response:
```json
{
  "success": true,
  "message": "User synced successfully",
  "data": {
    "id": "uuid",
    "firebaseUid": "abc123",
    "email": "user@example.com",
    "displayName": "John Doe",
    "roles": ["USER"]
  }
}
```

### Step 3: Use API
All subsequent requests use the same Bearer token.

---

## Response Format

### Success
```json
{
  "success": true,
  "message": "Success",
  "data": { ... },
  "meta": { ... }
}
```

### Error
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": [
    { "field": "body.amount", "message": "Expected number, received string" }
  ]
}
```

### Paginated
```json
{
  "success": true,
  "message": "Success",
  "data": [ ... ],
  "meta": {
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 50,
      "totalPages": 3,
      "hasNext": true,
      "hasPrevious": false
    }
  }
}
```

---

## CRUD Operations Example (Incomes)

### Create Income
```
POST /api/v1/incomes
{
  "source": "Gaji Bulanan",
  "amount": 15000000,
  "frequency": "MONTHLY",
  "description": "Gaji PT ABC"
}
```

### List Incomes
```
GET /api/v1/incomes?page=1&limit=10&frequency=MONTHLY
```

### Get Income
```
GET /api/v1/incomes/:id
```

### Update Income
```
PATCH /api/v1/incomes/:id
{
  "amount": 17000000
}
```

### Delete Income
```
DELETE /api/v1/incomes/:id
```

---

## FVS Workflow

### Calculate FVS
```
POST /api/v1/fvs/calculate
```
No body needed. Backend loads all your financial data and sends to ML service.

Response:
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "score": 72.5,
    "category": "MODERATE",
    "modelVersion": "1.0.0",
    "indicators": [
      {
        "indicatorName": "income_stability",
        "value": 85.0,
        "weight": 0.25,
        "status": "GOOD"
      }
    ]
  }
}
```

### Get Latest FVS
```
GET /api/v1/fvs/latest
```

### Get FVS History
```
GET /api/v1/fvs/history?page=1&limit=10
```

---

## Error Codes

| Status | Meaning |
|--------|---------|
| 400 | Bad Request / Validation Error |
| 401 | Unauthorized (invalid/missing token) |
| 403 | Forbidden (insufficient permissions) |
| 404 | Resource Not Found |
| 409 | Conflict (duplicate record) |
| 429 | Too Many Requests |
| 500 | Internal Server Error |
| 503 | Service Unavailable (ML service down) |

---

## Rate Limits

| Endpoint Group | Limit |
|---------------|-------|
| General | 100 req / 15 min |
| Auth | 30 req / 15 min |
| ML Operations | 10 req / 15 min |
| Write Operations | 50 req / 15 min |

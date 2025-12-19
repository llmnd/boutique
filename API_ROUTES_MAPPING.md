# 📋 Routes Backend & Appels HTTP Flutter

## 🔐 AUTH Routes (`/api/auth/*`)

### 1. Quick Registration
- **Route**: `POST /api/auth/register-quick`
- **Flutter Call**: 
```dart
http.post(Uri.parse('$apiHost/auth/register-quick'),
  headers: {'Content-Type': 'application/json'},
  body: json.encode({'phone': phone, 'country_code': code})
)
```

### 2. Login Phone
- **Route**: `POST /api/auth/login-phone`
- **Flutter Call**:
```dart
http.post(Uri.parse('$apiHost/auth/login-phone'),
  headers: {'Content-Type': 'application/json'},
  body: json.encode({'phone': phone})
)
```

### 3. Register PIN
- **Route**: `POST /api/auth/register-pin`
- **Flutter Call**:
```dart
http.post(Uri.parse('$apiHost/auth/register-pin'),
  headers: {'Content-Type': 'application/json', 'x-owner': phone},
  body: json.encode({'pin_hash': pinHash})
)
```

### 4. Full Registration
- **Route**: `POST /api/auth/register`
- **Flutter Call**: Used after PIN setup

### 5. Login
- **Route**: `POST /api/auth/login`
- **Flutter Call**:
```dart
http.post(Uri.parse('$apiHost/auth/login'),
  headers: {'Content-Type': 'application/json'},
  body: json.encode({'phone': phone, 'pin_hash': pinHash})
)
```

### 6. Verify Token
- **Route**: `POST /api/auth/verify-token`
- **Flutter Call**:
```dart
http.post(Uri.parse('$apiHost/auth/verify-token'),
  headers: {'Content-Type': 'application/json'},
  body: json.encode({'auth_token': token})
)
```

### 7. Logout
- **Route**: `POST /api/auth/logout`
- **Flutter Call**:
```dart
http.post(Uri.parse('$apiHost/auth/logout'),
  headers: {'Authorization': 'Bearer $token'}
)
```

### 8. Profile Update
- **Route**: `PATCH /api/auth/profile`
- **Flutter Call**:
```dart
http.patch(Uri.parse('$apiHost/auth/profile'),
  headers: {'Authorization': 'Bearer $token'},
  body: json.encode({...profileData})
)
```

### 9. Complete Profile
- **Route**: `PATCH /api/auth/complete-profile`
- **Flutter Call**:
```dart
http.patch(Uri.parse('$apiHost/auth/complete-profile'),
  headers: {'Authorization': 'Bearer $token'},
  body: json.encode({'first_name': fn, 'last_name': ln, ...})
)
```

### 10. Set PIN
- **Route**: `POST /api/auth/set-pin`
- **Flutter Call**:
```dart
http.post(Uri.parse('$apiHost/auth/set-pin'),
  headers: {'Authorization': 'Bearer $token'},
  body: json.encode({'pin_hash': pinHash})
)
```

### 11. Login with PIN
- **Route**: `POST /api/auth/login-pin`
- **Flutter Call**:
```dart
http.post(Uri.parse('$apiHost/auth/login-pin'),
  headers: {'Authorization': 'Bearer $token'},
  body: json.encode({'pin_hash': pinHash})
)
```

### 12. Update Boutique Mode
- **Route**: `POST /api/auth/update-boutique-mode`
- **Flutter Call**:
```dart
http.post(Uri.parse('$apiHost/auth/update-boutique-mode'),
  headers: {'Authorization': 'Bearer $token'},
  body: json.encode({'boutique_mode_enabled': enabled})
)
```

---

## 👥 CLIENTS Routes (`/api/clients/*`)

### 1. Get All Clients
- **Route**: `GET /api/clients`
- **Flutter Call**:
```dart
http.get(Uri.parse('$apiHost/clients'),
  headers: {'x-owner': ownerPhone}
)
```

### 2. Create Client
- **Route**: `POST /api/clients`
- **Flutter Call**:
```dart
http.post(Uri.parse('$apiHost/clients'),
  headers: {'x-owner': ownerPhone, 'Content-Type': 'application/json'},
  body: json.encode({'name': name, 'phone': phone, ...})
)
```

### 3. Get Client by ID
- **Route**: `GET /api/clients/:id`
- **Flutter Call**:
```dart
http.get(Uri.parse('$apiHost/clients/$clientId'),
  headers: {'x-owner': ownerPhone}
)
```

### 4. Update Client
- **Route**: `PUT /api/clients/:id`
- **Flutter Call**:
```dart
http.put(Uri.parse('$apiHost/clients/$clientId'),
  headers: {'x-owner': ownerPhone, 'Content-Type': 'application/json'},
  body: json.encode({...updatedData})
)
```

### 5. Delete Client
- **Route**: `DELETE /api/clients/:id`
- **Flutter Call**:
```dart
http.delete(Uri.parse('$apiHost/clients/$clientId'),
  headers: {'x-owner': ownerPhone}
)
```

### 6. Get Client's Debts
- **Route**: `GET /api/clients/:id/debts`
- **Flutter Call**:
```dart
http.get(Uri.parse('$apiHost/clients/$clientId/debts'),
  headers: {'x-owner': ownerPhone}
)
```

---

## 💰 DEBTS Routes (`/api/debts/*`)

### 1. Get All Debts
- **Route**: `GET /api/debts`
- **Flutter Call**:
```dart
http.get(Uri.parse('$apiHost/debts'),
  headers: {'x-owner': ownerPhone}
)
```

### 2. Get Debt by ID
- **Route**: `GET /api/debts/:id`
- **Flutter Call**:
```dart
http.get(Uri.parse('$apiHost/debts/$debtId'),
  headers: {'x-owner': ownerPhone}
)
```

### 3. Create Debt (Prêt)
- **Route**: `POST /api/debts`
- **Flutter Call**:
```dart
http.post(Uri.parse('$apiHost/debts'),
  headers: {'x-owner': ownerPhone, 'Content-Type': 'application/json'},
  body: json.encode({'client_id': cid, 'amount': amt, 'type': 'debt', ...})
)
```

### 4. Create Loan (Emprunt)
- **Route**: `POST /api/debts/loans`
- **Flutter Call**:
```dart
http.post(Uri.parse('$apiHost/debts/loans'),
  headers: {'x-owner': ownerPhone, 'Content-Type': 'application/json'},
  body: json.encode({'client_id': cid, 'amount': amt, 'type': 'loan', ...})
)
```

### 5. Update Debt
- **Route**: `PUT /api/debts/:id`
- **Flutter Call**:
```dart
http.put(Uri.parse('$apiHost/debts/$debtId'),
  headers: {'x-owner': ownerPhone, 'Content-Type': 'application/json'},
  body: json.encode({...updatedData})
)
```

### 6. Delete Debt
- **Route**: `DELETE /api/debts/:id`
- **Flutter Call**:
```dart
http.delete(Uri.parse('$apiHost/debts/$debtId'),
  headers: {'x-owner': ownerPhone}
)
```

### 7. Pay Debt
- **Route**: `POST /api/debts/:id/pay`
- **Flutter Call**:
```dart
http.post(Uri.parse('$apiHost/debts/$debtId/pay'),
  headers: {'x-owner': ownerPhone, 'Content-Type': 'application/json'},
  body: json.encode({'amount': amt, 'paid_at': date})
)
```

### 8. Get Payments for Debt
- **Route**: `GET /api/debts/:id/payments`
- **Flutter Call**:
```dart
http.get(Uri.parse('$apiHost/debts/$debtId/payments'),
  headers: {'x-owner': ownerPhone}
)
```

### 9. Add Amount to Debt
- **Route**: `POST /api/debts/:id/add`
- **Flutter Call**:
```dart
http.post(Uri.parse('$apiHost/debts/$debtId/add'),
  headers: {'x-owner': ownerPhone, 'Content-Type': 'application/json'},
  body: json.encode({'amount': amt, 'notes': notes})
)
```

### 10. Get Additions for Debt
- **Route**: `GET /api/debts/:id/additions`
- **Flutter Call**:
```dart
http.get(Uri.parse('$apiHost/debts/$debtId/additions'),
  headers: {'x-owner': ownerPhone}
)
```

### 11. Delete Addition
- **Route**: `DELETE /api/debts/:id/additions/:additionId`
- **Flutter Call**:
```dart
http.delete(Uri.parse('$apiHost/debts/$debtId/additions/$addId'),
  headers: {'x-owner': ownerPhone}
)
```

### 12. Get Debts for Client
- **Route**: `GET /api/debts/client/:clientId`
- **Flutter Call**:
```dart
http.get(Uri.parse('$apiHost/debts/client/$clientId'),
  headers: {'x-owner': ownerPhone}
)
```

### 13. Get Balances
- **Route**: `GET /api/debts/balances/:user`
- **Flutter Call**:
```dart
http.get(Uri.parse('$apiHost/debts/balances/$ownerPhone'),
  headers: {'x-owner': ownerPhone}
)
```

### 14. Create Dispute
- **Route**: `POST /api/debts/:id/disputes`
- **Flutter Call**:
```dart
http.post(Uri.parse('$apiHost/debts/$debtId/disputes'),
  headers: {'x-owner': ownerPhone, 'Content-Type': 'application/json'},
  body: json.encode({'reason': reason, ...})
)
```

### 15. Get Disputes
- **Route**: `GET /api/debts/:id/disputes`
- **Flutter Call**:
```dart
http.get(Uri.parse('$apiHost/debts/$debtId/disputes'),
  headers: {'x-owner': ownerPhone}
)
```

### 16. Resolve Dispute
- **Route**: `PATCH /api/debts/:id/disputes/:disputeId/resolve`
- **Flutter Call**:
```dart
http.patch(Uri.parse('$apiHost/debts/$debtId/disputes/$disputeId/resolve'),
  headers: {'x-owner': ownerPhone, 'Content-Type': 'application/json'},
  body: json.encode({'resolution': res})
)
```

---

## 🌍 COUNTRIES Routes (`/api/countries/*`)

### 1. Get All Countries
- **Route**: `GET /api/countries`
- **Flutter Call**:
```dart
http.get(Uri.parse('$apiHost/countries'))
```

### 2. Get Country by Code
- **Route**: `GET /api/countries/:code`
- **Flutter Call**:
```dart
http.get(Uri.parse('$apiHost/countries/SN'))
```

---

## 👨‍💼 TEAM Routes (`/api/team/*`)

### 1. Get Team Members
- **Route**: `GET /api/team/members`
- **Flutter Call**:
```dart
http.get(Uri.parse('$apiHost/team/members'),
  headers: {'x-owner': ownerPhone}
)
```

### 2. Invite Member
- **Route**: `POST /api/team/invite`
- **Flutter Call**:
```dart
http.post(Uri.parse('$apiHost/team/invite'),
  headers: {'x-owner': ownerPhone, 'Content-Type': 'application/json'},
  body: json.encode({'email': email, 'role': role})
)
```

### 3. Update Member
- **Route**: `PUT /api/team/members/:id`
- **Flutter Call**:
```dart
http.put(Uri.parse('$apiHost/team/members/$memberId'),
  headers: {'x-owner': ownerPhone, 'Content-Type': 'application/json'},
  body: json.encode({...updatedData})
)
```

### 4. Remove Member
- **Route**: `DELETE /api/team/members/:id`
- **Flutter Call**:
```dart
http.delete(Uri.parse('$apiHost/team/members/$memberId'),
  headers: {'x-owner': ownerPhone}
)
```

### 5. Get Activity
- **Route**: `GET /api/team/activity`
- **Flutter Call**:
```dart
http.get(Uri.parse('$apiHost/team/activity'),
  headers: {'x-owner': ownerPhone}
)
```

### 6. Log Activity
- **Route**: `POST /api/team/activity`
- **Flutter Call**:
```dart
http.post(Uri.parse('$apiHost/team/activity'),
  headers: {'x-owner': ownerPhone, 'Content-Type': 'application/json'},
  body: json.encode({'action': action, ...})
)
```

---

## 📊 SYNC Routes (main.js direct)

### 1. Get All Debt Additions (for sync)
- **Route**: `GET /api/debt-additions?owner_phone=<phone>`
- **Flutter Call** (HiveServiceManager):
```dart
http.get(Uri.parse('$apiHost/debt-additions?owner_phone=$phone'),
  headers: {'x-owner': phone}
)
```

### 2. Get All Payments (for sync)
- **Route**: `GET /api/payments?owner_phone=<phone>`
- **Flutter Call** (HiveServiceManager):
```dart
http.get(Uri.parse('$apiHost/payments?owner_phone=$phone'),
  headers: {'x-owner': phone}
)
```

---

## 📝 Résumé des Headers Courants

| Header | Valeur | Usage |
|--------|--------|-------|
| `Content-Type` | `application/json` | Toutes les requêtes avec body |
| `x-owner` | `{phone}` | Identifier le propriétaire |
| `Authorization` | `Bearer {token}` | Requêtes authentifiées (optionnel) |

## 📍 Base URL

- **Production**: `https://vocal-fernandina-llmndg-0b759290.koyeb.app/api`
- **Web**: `https://vocal-fernandina-llmndg-0b759290.koyeb.app/api`
- **Android Emulator**: `http://10.0.2.2:3000/api` (local dev)
- **Défini par**: `ApiConfig.getBaseUrl()` dans [mobile/lib/config/api_config.dart](mobile/lib/config/api_config.dart)


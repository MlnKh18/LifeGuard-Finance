# API Verification Scenarios

## Scenario 1: Healthy Financial Profile (Safe)

### Request
```json
{
  "monthly_income": 20000000.0,
  "monthly_expenses": 4000000.0,
  "total_debt": 0.0,
  "number_of_dependents": 1,
  "protection_coverage": 1200000000.0,
  "emergency_fund": 50000000.0
}
```

### Expected Response
- **Expected Category**: `Safe`
- **Expected FVS Score Range**: 85.0 - 100.0
- **Strengths**: Emergency fund buffer, zero debt burden, healthy surplus.

---

## Scenario 2: Moderate Financial Profile

### Request
```json
{
  "monthly_income": 10000000.0,
  "monthly_expenses": 5000000.0,
  "total_debt": 10000000.0,
  "number_of_dependents": 2,
  "protection_coverage": 300000000.0,
  "emergency_fund": 15000000.0
}
```

### Expected Response
- **Expected Category**: `Moderate`
- **Expected FVS Score Range**: 60.0 - 79.9

---

## Scenario 3: High Debt Burden

### Request
```json
{
  "monthly_income": 6000000.0,
  "monthly_expenses": 3000000.0,
  "total_debt": 80000000.0,
  "number_of_dependents": 2,
  "protection_coverage": 50000000.0,
  "emergency_fund": 2000000.0
}
```

### Expected Response
- **Expected Category**: `Warning` or `Critical`
- **Vulnerability**: "High debt burden consumes a significant portion of your monthly income."

---

## Scenario 4: No Emergency Fund

### Request
```json
{
  "monthly_income": 10000000.0,
  "monthly_expenses": 5000000.0,
  "total_debt": 0.0,
  "number_of_dependents": 1,
  "protection_coverage": 500000000.0,
  "emergency_fund": 0.0
}
```

### Expected Response
- **Expected Category**: `Moderate` or `Warning`
- **Vulnerability**: "Critically low or absent emergency fund increases risk during job loss or emergencies."

---

## Scenario 5: Many Dependents

### Request
```json
{
  "monthly_income": 8000000.0,
  "monthly_expenses": 4000000.0,
  "total_debt": 5000000.0,
  "number_of_dependents": 5,
  "protection_coverage": 100000000.0,
  "emergency_fund": 10000000.0
}
```

### Expected Response
- **Expected Category**: `Warning` or `Critical`

---

## Scenario 6: Critical Financial Risk

### Request
```json
{
  "monthly_income": 3000000.0,
  "monthly_expenses": 4000000.0,
  "total_debt": 60000000.0,
  "number_of_dependents": 4,
  "protection_coverage": 0.0,
  "emergency_fund": 0.0
}
```

### Expected Response
- **Expected Category**: `Critical`
- **Expected FVS Score Range**: 0.0 - 39.9

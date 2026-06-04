=== FILE: docs/API_SURFACE.md ===
Why agents read this: This document defines the public contract for all services, ensuring agents generate code that interacts with the system correctly and predictably.

## API Contract Rules

1.  **Never Remove:** Do not remove any public function or endpoint without first marking it as deprecated and providing a clear migration path.
2.  **Version Before Breaking:** If a change is breaking, it must be versioned (e.g., `/v2/users`) and the old endpoint must remain active for a minimum of two major versions.
3.  **Validation is Mandatory:** All inputs must pass through defined validation schemas before being processed to prevent runtime errors.

| Endpoint | Description | Request Body Schema | Response Schema |
| :--- | :--- | :--- | :--- |
| `/users/get` | Retrieves user details by ID. | `{ "userId": string }` | `{ "id": string, "name": string, "email": string }` |
| `/products/create` | Creates a new product entry. | `{ "name": string, "price": number }` | `{ "success": boolean, "productId": string }` |
| `/auth/login` | Authenticates user credentials. | `{ "email": string, "password": string }` | `{ "token": string }` |

## Usage Examples

**GET /users/get**
`GET /users/get?userId=user-123`

**POST /products/create**
`POST /products/create`
Body: `{"name": "New Widget", "price": 19.99}`

## Deprecation Notice

The `/legacy/v1/` endpoints are scheduled for removal by Q4 2024. Please migrate to the modern `/v2/` endpoints.

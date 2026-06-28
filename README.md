# AI4Good

Flutter app for AI4Good authentication, profile management, and AI Data Review workflows.

## Backend Integration

The app defaults to the production HTTPS backend:

- `https://d2x9le8skhxjh4.cloudfront.net`

That endpoint is the backend CloudFront URL in front of the FastAPI ALB, so it
works from deployed HTTPS Flutter web builds without browser mixed-content
blocking. You can still override the backend at build/run time:

```bash
flutter build web --dart-define=API_BASE_URL=https://your-backend.example.com
```

## Local Web Development

The production FastAPI backend allows browser requests from these local origins:

- `http://localhost:3000`
- `http://localhost:8080`
- `http://localhost:5000`

When running Flutter web against the production backend, use one of those ports:

```bash
flutter run -d chrome --web-hostname localhost --web-port 3000
```

or:

```bash
flutter run -d chrome --web-hostname localhost --web-port 8080
```

Using Flutter's random web port can make the browser block upload/API requests
with a CORS-style `Failed to fetch` error unless that origin is added to the
backend CORS allowlist.

For local backend development, override the API base URL:

```bash
flutter run -d chrome --web-hostname localhost --web-port 3000 --dart-define=API_BASE_URL=http://localhost:8000
```

For local HTTP testing against the ALB instead of CloudFront:

```bash
flutter run -d chrome --web-hostname localhost --web-port 3000 --dart-define=API_BASE_URL=http://ai-dat-LoadB-8liHDRYQDOe8-1492154657.us-west-2.elb.amazonaws.com
```

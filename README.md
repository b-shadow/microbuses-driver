# mobile-driver

Aplicación Flutter para conductores SIG Microbuses.

## Ejecutar
```bash
flutter pub get
flutter run --dart-define=API_BASE=http://localhost:8000/api/v1
```

## Incluye en MVP actual
- Splash + login conductor
- Resolución de estado PENDING/REJECTED/APPROVED
- Home conductor
- Perfil conductor (`/auth/me`)
- Registro de microbús (`POST /buses`)
- Listado de microbuses
- Selección de microbús y persistencia local
- Cambio de línea (`POST /buses/{id}/change-line`)
- Inicio de viaje activo (`POST /active-trips/start`)
- Envío de tracking cada 10 segundos (`/tracking/location`)
- Cola local de puntos cuando falla red
- Sincronización batch de cola (`/tracking/batch`)
- Finalización de viaje (`/active-trips/{id}/finish`)
- Vista simple de auditoría (`/audit`)
- Settings (cerrar sesión)
- Tema claro/oscuro persistente

## Nota
En este entorno, `flutter analyze` puede colgar por timeout. Validar localmente con:
```bash
flutter analyze
```

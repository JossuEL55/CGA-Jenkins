# Operación del pipeline DevSecOps

## Orden del flujo

1. Un push o PR contra `master` ejecuta CI, auditoría NuGet, CodeQL y, si cambió YAML, validación Kubernetes.
2. CI restaura, compila, ejecuta pruebas y publica un ZIP con SHA-256.
3. Solo un CI exitoso de `master` dispara `Container`.
4. La imagen local se analiza con Trivy. Los `CRITICAL` corregibles bloquean publicación.
5. La imagen se publica en GHCR con tags `sha-<completo>`, `sha-<corto>` y `latest` solo para `master`.
6. Se registra el digest y se genera una attestation de procedencia.
7. Actions abre un PR que modifica únicamente `spec.template.spec.containers[].image` en `argocd-manifests/app-deployment.yaml`.
8. Tras revisión y merge, Argo CD sincroniza Kubernetes. El smoke test y DAST se ejecutan contra el entorno accesible.

## Permisos y configuración manual

Configure en **Settings → Actions → General**:

- Workflow permissions: lectura y escritura.
- Permitir que GitHub Actions cree Pull Requests.
- GitHub Code Security/Code scanning para CodeQL y SARIF.

El pipeline usa únicamente `GITHUB_TOKEN`; no requiere secretos GitHub propios. El clúster sí necesita `cga-postgres-secret`, creado fuera del repositorio. Para un paquete GHCR privado, Kubernetes necesita además `ghcr-pull-secret` con un token de solo lectura de paquetes.

## Controles y excepciones

- `permissions` se declaran explícitamente por workflow.
- Los PR no pueden publicar imágenes ni escribir manifiestos.
- El build de seguridad se realiza antes del login y push a GHCR.
- Trivy informa HIGH/CRITICAL sin ocultarlos y bloquea CRITICAL con solución disponible. `ignore-unfixed` evita bloquear por CVE de imagen base sin parche; esta excepción debe revisarse periódicamente.
- Trivy config es observacional en la primera adopción; kubeconform sí bloquea errores YAML o estructurales.
- ZAP Baseline es observacional con reportes persistentes. Una futura política puede retirar `-I` cuando exista una línea base aprobada.
- `database/Dockerfile` se conserva como evidencia y para quien necesite `uuid-ossp`; el despliegue vigente usa la imagen oficial `postgres:16-alpine`, pues las entidades actuales no requieren esa imagen personalizada.

## Validación local

```powershell
dotnet restore CGA.MetrologySystem.slnx
dotnet build CGA.MetrologySystem.slnx --configuration Release --no-restore
dotnet test CGA.MetrologySystem.slnx --configuration Release --no-build --collect "XPlat Code Coverage"
dotnet publish CGA.MetrologySystem/CGA.MetrologySystem.csproj --configuration Release --no-build --output artifacts/publish
docker build -f CGA.MetrologySystem/Dockerfile -t cga-app:local .
kubectl apply --dry-run=client -f argocd-manifests/ -n cga-metrology
```

Kubeconform 0.7.0:

```bash
kubeconform -strict -summary -ignore-missing-schemas k8s argocd-manifests argocd
trivy config --severity MEDIUM,HIGH,CRITICAL .
```

## Trazabilidad

- Commit: etiqueta OCI `org.opencontainers.image.revision` y tag `sha-<commit>`.
- Workflow: `container-metadata/image.json` contiene `workflow_run`.
- Artefacto .NET: nombre con SHA corto y checksum SHA-256.
- Imagen: referencia `image@sha256:digest` y attestation vinculada al repositorio.
- Despliegue: PR GitOps con commit, digest y enlace lógico al workflow run.

## Bootstrap

El manifiesto versionado no puede conocer el digest de una imagen que todavía no se ha construido. El valor inicial por SHA se sustituye así:

1. Fusionar esta implementación en `master`.
2. Confirmar CI y CodeQL.
3. Confirmar que `Container` publicó la imagen y pasó Trivy.
4. Revisar y fusionar el PR `chore(gitops): deploy cga-app <sha>`.
5. Hacer público el paquete o crear `ghcr-pull-secret`.
6. Crear `cga-postgres-secret` y aplicar `argocd/application.yaml`.
7. Confirmar Argo CD `Synced/Healthy`, ejecutar smoke test y luego DAST.

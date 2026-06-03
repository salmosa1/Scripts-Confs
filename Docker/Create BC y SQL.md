# Crear BC (Docker) — Guía paso a paso
Esta guía explica cómo:

- Restaurar un archivo BACPAC en tu servidor SQL usando SQL Server Management Studio (SSMS).
- Crear un contenedor de Microsoft Dynamics 365 Business Central que apunte a esa base de datos.

Orientada a Windows + Docker Desktop + PowerShell 7+.

0. Prerrequisitos
Antes de empezar, asegúrate de tener instalado:

# Crear BC y SQL (Docker) — Guía paso a paso

Guía reproducible para crear un entorno local con:

- Un contenedor SQL Server
- Restauración de una base de datos desde un BACPAC en ese contenedor
- Un contenedor de Microsoft Dynamics 365 Business Central apuntando al SQL externo

Orientada a Windows + Docker Desktop + PowerShell 7+.

## Guión (resumen rápido)

1. Preparar carpetas y copiar BACPAC
2. Restaurar el BACPAC con SQL Server Management Studio (SSMS)
3. Crear contenedor Business Central con `BcContainerHelper`
4. Verificar y ajustar acceso

---

## Índice

- [Prerrequisitos](#prerrequisitos)
- [Estructura de carpetas](#estructura-de-carpetas)
- [Restaurar el BACPAC](#restaurar-el-bacpac)
- [Crear contenedor Business Central](#crear-contenedor-business-central)
- [Verificaciones y acceso](#verificaciones-y-acceso)
- [Comandos útiles](#comandos-útiles)
- [Notas importantes y seguridad](#notas-importantes-y-seguridad)
- [Script de automatización (ejemplo)](#script-de-automatización-ejemplo)

---

## Prerrequisitos

- Windows 10/11
- Docker Desktop (contenedores Linux habilitados)
- PowerShell 7+ (recomendado)
- `BcContainerHelper` instalado

Instalar `BcContainerHelper` (si aún no está):

```powershell
Install-Module BcContainerHelper -Force -Scope CurrentUser
``` 

Comprueba que Docker Desktop esté en funcionamiento y que la integración de WSL2 esté activa si procede.

## Estructura de carpetas

Crea la carpeta de trabajo y coloca tu BACPAC allí:

```powershell
mkdir C:\BCDocker
mkdir C:\BCDocker\Sql
# Copia tu archivo .bacpac a C:\BCDocker\Sql\database.bacpac
``` 

Puedes usar cualquier nombre para el BACPAC, en esta guía usaremos `database.bacpac`.

## Conexión Servidor SQL Azure
Cadena de conexión: 
Data Source=demodynamizatic.database.windows.net;Persist Security Info=True;User ID=dynamizatic;Password=Dyn@m1z@T1C;Pooling=False;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Application Name="SQL Server Management Studio";Command Timeout=0

## Restaurar el BACPAC con SQL Server Management Studio (SSMS)

Esta sección explica cómo importar un archivo `.bacpac` usando SQL Server Management Studio, sin PowerShell.

Requisitos previos:
- Tener el archivo `database.bacpac` accesible desde la máquina donde ejecutas SSMS (p.ej. `C:\BCDocker\Sql\database.bacpac`) o en una ubicación de red accesible.
- Contar con credenciales de administrador del servidor SQL de destino (o permisos equivalentes).

Pasos (SSMS):

1. Abre SQL Server Management Studio y conéctate al servidor destino (puede ser un SQL en VM, en Azure o local).
2. En el Explorador de objetos, haz clic derecho en `Databases` y selecciona `Import Data-tier Application...`.
3. En el asistente, elige `Import from local disk` y selecciona el fichero `.bacpac`.
4. En `Database Settings`, indica el nombre que deseas para la base de datos destino (p.ej. `BCDatabase`).
5. Revisa las opciones de edición/servicio si aplica (especialmente si importas hacia Azure) y continúa.
6. Haz clic en `Finish` y supervisa el progreso en la ventana de resultados. Cuando termine, revisa los mensajes para confirmar que la importación fue correcta.

Notas y recomendaciones:
- Si el servidor está en Azure, asegúrate de que la IP desde la que te conectas esté permitida en el firewall del servidor o utiliza un Private Endpoint.
- Para BACPACs muy grandes considera subir el `.bacpac` a Azure Blob Storage y usar el import desde el portal de Azure (más fiable para archivos grandes).
- Si aparecen errores comunes (falta de permisos, timeouts, incompatibilidades), copia el mensaje de error y te ayudo a diagnosticarlos.

## Crear contenedor Business Central

Usaremos `BcContainerHelper` para crear el contenedor BC apuntando a la base de datos que ya has restaurado (vía SSMS).

### Variables de ejemplo (PowerShell)

```powershell
$containerName = "BC CLIENTE"
$artifactUrl = Get-BcArtifactUrl -type 'Sandbox' -country 'es' -select Latest -version 27
$auth = 'UserPassword'
# Reemplaza por la IP o el nombre DNS de la VM que corre SQL
$sqlServer     = "demodynamizatic.database.windows.net"
$sqlDb         = "AQUI LA BBDD"
$sqlUser       = "dynamizatic"
$sqlPassword   = "Dyn@m1z@T1C"

# Credenciales de administrador de BC (se solicitarán interactivamente)
$credential = New-Object pscredential 'smorales', (ConvertTo-SecureString -String 'Sm16092024.' -AsPlainText -Force)
```

### Comando para crear el contenedor BC
```powershell
New-BcContainer `
    -accept_eula `
    -accept_outdated `
    -updateHosts `
    -useBestContainerOS `
    -artifactUrl $artifactUrl `
    -containerName $containerName `
    -auth $auth `
    -credential $credential `
    -assignPremiumPlan `
    -includeTestToolkit `
    -includeAL `
    -EnableTaskScheduler:$false `
    -databaseServer $SqlServer `
    -databaseName $SqlDb `
    -databaseUserName $SqlUser `
    -databasePassword $SqlPassword `
```

Notas:
- `-databaseServer` debe ser la IP o el FQDN del servidor SQL donde importaste el BACPAC.
- `-updateHosts` intentará añadir la entrada `bc` en el `hosts` del host para resolver la dirección del contenedor.

## Verificaciones y acceso

- Ver contenedores activos:

```powershell
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
```


- Deberías ver `bc`.

- Acceder a Business Central en el navegador:

```
http://bc
```

Credenciales:
- El usuario/contraseña que configuraste al crear el contenedor (con `Get-Credential`).

Si `http://bc` no resuelve, abre `http://localhost:8080` (o el puerto que haya expuesto `New-BcContainer`) o añade entrada en `/etc/hosts`/`C:\Windows\System32\drivers\etc\hosts` según necesites.

## Comandos útiles

- Parar contenedores:

```powershell
docker stop bc
```

- Arrancar contenedores:

```powershell
docker start bc
```

- Eliminar (fase de limpieza):

```powershell
docker rm -f bc
```

## Notas importantes y seguridad

- No uses contraseñas de ejemplo en entornos reales.
- Evita SQL Express para restauraciones grandes: puede fallar con BACPACs grandes.
- Asegura los puertos y el acceso a la red según tus políticas.

## Siguientes pasos recomendados

- Publicar extensiones: `Publish-BcContainerApp`.
- Habilitar debugging y publicar símbolos.
- Conectar VS Code y configurar launch.json para debugging de AL.
- Automatizar el proceso con un script `.ps1` (ejemplo abajo).

---

## Script de automatización (ejemplo PowerShell)

Ejemplo mínimo que asume que ya has restaurado el BACPAC mediante SSMS. El script valida que el `.bacpac` exista localmente y crea el contenedor BC apuntando a la base de datos que ya existe.

```powershell
<#
  Script: Create-BC-Only.ps1
  Uso: Ejecutar en PowerShell 7+ con permisos adecuados.
#>

param(
  [string]$BcDockerPath = 'C:\BCDocker',
  [string]$BacpacName = 'database.bacpac',
  [string]$DbServer = '<DB_SERVER_OR_FQDN>',
  [string]$DbName = '<DATABASE_NAME>',
  [string]$DbUser = '<DB_USER>',
  [string]$DbPassword = '<DB_PASSWORD>',
  [string]$BcContainerName = 'bc',
  [string]$BcVersion = 'latest'
)

Set-StrictMode -Version Latest

# Verificar que el BACPAC exista (informativo)
New-Item -ItemType Directory -Path (Join-Path $BcDockerPath 'Sql') -Force | Out-Null
$bacpacPath = Join-Path $BcDockerPath 'Sql' $BacpacName
if (-not (Test-Path $bacpacPath)) {
  Write-Warning "No se encontró el BACPAC en $bacpacPath. Si ya importaste via SSMS ignora este aviso."
}

Write-Output 'Crear contenedor Business Central (interactivo para credenciales)...'
$credential = Get-Credential -Message 'Introduce las credenciales de administración de Business Central'
New-BcContainer \
  -accept_eula \
  -containerName $BcContainerName \
  -artifactUrl (Get-BcArtifactUrl -type OnPrem -country es -version $BcVersion) \
  -auth UserPassword \
  -Credential $credential \
  -databaseServer $DbServer \
  -databaseName $DbName \
  -databaseUserName $DbUser \
  -databasePassword $DbPassword \
  -updateHosts \
  -shortcuts Desktop

Write-Output 'Proceso completado. Verifica contenedores con: docker ps'
```
---

Si quieres, puedo:

- Crear el script `Create-BCWithSQL.ps1` como archivo separado en el repositorio.
- Añadir instrucciones para publicar extensiones y activar debugging.
- Añadir validaciones adicionales (comprobación de puertos, estado del contenedor SQL, tiempos de espera).

Archivo actualizado: [Docker/Create BC y SQL.md](Docker/Create%20BC%20y%20SQL.md)

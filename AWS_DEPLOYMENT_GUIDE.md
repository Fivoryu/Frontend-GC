# Guía de Despliegue AWS - Frontend React

## 🚀 Opciones de Despliegue para Frontend

### 1. AWS S3 + CloudFront (Recomendado)
- **Ventajas**: Económico, rápido, CDN global, SSL gratuito
- **Ideal para**: Aplicaciones SPA (Single Page Applications)
- **Costo**: ~$1-5/mes

### 2. AWS Amplify
- **Ventajas**: CI/CD automático, fácil configuración
- **Ideal para**: Desarrollo rápido, equipos pequeños
- **Costo**: ~$5-15/mes

### 3. AWS EC2 + Nginx
- **Ventajas**: Control total, servidores dedicados
- **Ideal para**: Aplicaciones complejas, múltiples servicios
- **Costo**: ~$8-50/mes

## 📋 Prerrequisitos

### 1. Instalar AWS CLI
```bash
# Windows (con Chocolatey)
choco install awscli

# O descargar desde: https://aws.amazon.com/cli/
```

### 2. Configurar credenciales AWS
```bash
aws configure
# AWS Access Key ID: [Tu Access Key]
# AWS Secret Access Key: [Tu Secret Key]
# Default region name: us-east-1
# Default output format: json
```

### 3. Verificar configuración
```bash
aws sts get-caller-identity
```

## 🔧 Despliegue con S3 + CloudFront

### Opción 1: Script Automatizado (Recomendado)

#### Windows PowerShell:
```powershell
# Despliegue básico
.\deploy-aws.ps1

# Con parámetros personalizados
.\deploy-aws.ps1 -BucketName "mi-app-frontend" -Region "us-west-2"

# Con infraestructura completa (S3 + CloudFront)
.\deploy-aws.ps1 -CreateInfrastructure -DomainName "miapp.com"
```

#### Linux/Mac:
```bash
# Despliegue básico
./deploy-aws.sh

# Con parámetros personalizados
./deploy-aws.sh "mi-app-frontend" "us-west-2"

# Con infraestructura completa
./deploy-aws.sh "mi-app-frontend" "us-west-2" "miapp.com" true
```

### Opción 2: Comandos Manuales

#### 1. Construir la aplicación
```bash
npm run build
```

#### 2. Crear bucket S3
```bash
# Crear bucket
aws s3 mb s3://mi-app-frontend --region us-east-1

# Configurar para hosting web
aws s3 website s3://mi-app-frontend --index-document index.html --error-document index.html

# Aplicar política pública
aws s3api put-bucket-policy --bucket mi-app-frontend --policy file://aws-s3-policy.json
```

#### 3. Subir archivos
```bash
# Subir todos los archivos
aws s3 sync ./dist s3://mi-app-frontend --delete

# Configurar cache headers
aws s3 cp ./dist s3://mi-app-frontend --recursive --exclude "*" --include "*.js" --cache-control "max-age=31536000"
aws s3 cp ./dist s3://mi-app-frontend --recursive --exclude "*" --include "*.css" --cache-control "max-age=31536000"
aws s3 cp ./dist s3://mi-app-frontend --recursive --exclude "*" --include "*.html" --cache-control "no-cache"
```

## 🌐 Configuración de CloudFront (CDN)

### Crear distribución CloudFront
```bash
aws cloudformation create-stack \
  --stack-name frontend-infrastructure \
  --template-body file://aws-cloudformation.json \
  --parameters ParameterKey=BucketName,ParameterValue=mi-app-frontend
```

### Invalidar cache de CloudFront
```bash
# Después de cada actualización
aws cloudfront create-invalidation \
  --distribution-id E1234567890123 \
  --paths "/*"
```

## 🔒 Configuración de Dominio Personalizado

### 1. Certificado SSL con AWS Certificate Manager
```bash
# Solicitar certificado SSL
aws acm request-certificate \
  --domain-name miapp.com \
  --subject-alternative-names "*.miapp.com" \
  --validation-method DNS \
  --region us-east-1
```

### 2. Configurar Route 53
1. Ve a AWS Console > Route 53
2. Crea zona hosted para tu dominio
3. Configura registro CNAME o ALIAS apuntando a CloudFront

### 3. Actualizar CloudFront
```bash
# Modificar distribución para usar dominio personalizado
aws cloudfront update-distribution \
  --id E1234567890123 \
  --distribution-config file://cloudfront-config.json
```

## 🔧 Variables de Entorno

### Desarrollo (.env.local)
```env
VITE_API_URL=http://localhost:8000
VITE_APP_NAME=Condominium Management
```

### Producción (.env.production)
```env
VITE_API_URL=https://condominium-production.elasticbeanstalk.com
VITE_APP_NAME=Condominium Management
VITE_AWS_REGION=us-east-1
```

## 📊 Optimización de Performance

### 1. Compresión Gzip
```json
// vite.config.js
export default {
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
          router: ['react-router-dom']
        }
      }
    }
  }
}
```

### 2. Headers de Cache
- **HTML**: `no-cache` (siempre verificar)
- **JS/CSS**: `max-age=31536000` (1 año)
- **Assets**: `max-age=31536000` (1 año)

### 3. CloudFront Configuration
```json
{
  "PriceClass": "PriceClass_100",
  "Compress": true,
  "ViewerProtocolPolicy": "redirect-to-https"
}
```

## 🔄 CI/CD con GitHub Actions

### Crear workflow (.github/workflows/deploy.yml)
```yaml
name: Deploy to AWS S3

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    
    - name: Setup Node.js
      uses: actions/setup-node@v2
      with:
        node-version: '18'
        
    - name: Install dependencies
      run: npm install
      
    - name: Build
      run: npm run build
      
    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v1
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-east-1
        
    - name: Deploy to S3
      run: aws s3 sync ./dist s3://mi-bucket-frontend --delete
      
    - name: Invalidate CloudFront
      run: aws cloudfront create-invalidation --distribution-id ${{ secrets.CLOUDFRONT_DISTRIBUTION_ID }} --paths "/*"
```

## 💰 Estimación de Costos

### S3 + CloudFront
- **S3 Storage**: $0.023/GB/mes
- **S3 Requests**: $0.0004/1K requests
- **CloudFront**: $0.085/GB transferencia
- **Total aproximado**: $1-5/mes para aplicaciones pequeñas

### Optimización de costos
- Usar CloudFront PriceClass_100 (solo América y Europa)
- Configurar lifecycle policies en S3
- Monitorear uso con AWS Cost Explorer

## 🔧 Comandos Útiles

```bash
# Ver contenido del bucket
aws s3 ls s3://mi-bucket-frontend --recursive

# Sincronizar solo archivos modificados
aws s3 sync ./dist s3://mi-bucket-frontend --delete --exclude "*.html"

# Ver distribuciones CloudFront
aws cloudfront list-distributions

# Monitorear logs de CloudFront
aws logs describe-log-groups --log-group-name-prefix "/aws/cloudfront"

# Eliminar stack completo
aws cloudformation delete-stack --stack-name frontend-infrastructure
```

## 🆘 Troubleshooting

### Error: Access Denied
```bash
# Verificar política del bucket
aws s3api get-bucket-policy --bucket mi-bucket-frontend

# Verificar ACLs
aws s3api get-bucket-acl --bucket mi-bucket-frontend
```

### Error: Route 53 no resuelve
```bash
# Verificar registros DNS
dig miapp.com
nslookup miapp.com
```

### Error: CloudFront no actualiza
```bash
# Crear invalidación manual
aws cloudfront create-invalidation --distribution-id E1234567890123 --paths "/*"

# Verificar estado de la invalidación
aws cloudfront get-invalidation --distribution-id E1234567890123 --id I1234567890123
```

### Error en el build
```bash
# Verificar variables de entorno
cat .env.production

# Limpiar cache de Vite
rm -rf node_modules/.vite
npm run build
```

## ✅ Checklist de Despliegue

- [ ] AWS CLI configurado
- [ ] Variables de entorno configuradas
- [ ] Build de producción exitoso
- [ ] Bucket S3 creado y configurado
- [ ] CloudFront configurado
- [ ] SSL/TLS configurado
- [ ] Dominio personalizado (opcional)
- [ ] CI/CD configurado (opcional)
- [ ] Monitoreo configurado
- [ ] Variables del backend actualizadas con nueva URL

## 📚 Recursos Adicionales

- [AWS S3 Static Website Hosting](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html)
- [CloudFront Distribution](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/)
- [AWS Certificate Manager](https://docs.aws.amazon.com/acm/)
- [React Deployment Guide](https://create-react-app.dev/docs/deployment/)
# CI/CD Setup with GitHub Actions

## 📋 Overview

Automated deployment to Azure Container Apps on every push to `main` branch.

## 🔧 Setup Instructions

### 1. Create Azure Service Principal

```bash
# Login to Azure
az login

# Create service principal with contributor role
az ad sp create-for-rbac \
  --name "async-fastapi-github-actions" \
  --role contributor \
  --scopes /subscriptions/<YOUR_SUBSCRIPTION_ID>/resourceGroups/async-fastapi-rg \
  --sdk-auth

# Save the JSON output - you'll need it for GitHub Secrets
```

The output will look like:
```json
{
  "clientId": "...",
  "clientSecret": "...",
  "subscriptionId": "...",
  "tenantId": "...",
  ...
}
```

### 2. Add GitHub Secret

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Name: `AZURE_CREDENTIALS`
5. Value: Paste the entire JSON output from step 1
6. Click **Add secret**

### 3. Update Workflow Variables (if needed)

Edit `.github/workflows/azure-deploy.yml` and update these if you used different names:

```yaml
env:
  RESOURCE_GROUP: async-fastapi-rg      # Your resource group name
  ACR_NAME: asyncfastapiacr             # Your ACR name (must match deployed)
  IMAGE_NAME: async-fastapi             # Your image name
```

### 4. Test the Workflow

#### Option A: Push to main branch
```bash
git add .
git commit -m "Setup CI/CD"
git push origin main
```

#### Option B: Manual trigger
1. Go to **Actions** tab in GitHub
2. Select **Deploy to Azure Container Apps**
3. Click **Run workflow**
4. Select branch and click **Run workflow**

## 📊 Workflow Details

### Triggers
- **Automatic**: Push to `main` branch
- **Manual**: Via GitHub Actions UI (workflow_dispatch)

### Steps
1. ✅ Checkout code
2. ✅ Login to Azure
3. ✅ Build Docker image
4. ✅ Push to ACR
5. ✅ Update FastAPI Container App
6. ✅ Update Celery Worker
7. ✅ Update Celery Beat
8. ✅ Update Flower
9. ✅ Display deployment URLs

### What Gets Updated
- All container apps with new image
- Zero-downtime rolling update
- Automatic health checks

## 🔍 Monitor Deployment

1. Go to **Actions** tab in GitHub
2. Click on the running workflow
3. Watch real-time logs
4. See deployment summary with URLs

## 🎯 Best Practices

### Branch Protection
Protect your `main` branch:
1. Settings → Branches
2. Add branch protection rule for `main`
3. Require pull request reviews
4. Require status checks to pass

### Environment Secrets
For multiple environments (dev/staging/prod):

1. Settings → Environments
2. Create environments: `development`, `staging`, `production`
3. Add environment-specific secrets
4. Modify workflow to use environments

Example:
```yaml
jobs:
  deploy-staging:
    runs-on: ubuntu-latest
    environment: staging
    # ... steps
  
  deploy-production:
    runs-on: ubuntu-latest
    environment: production
    needs: deploy-staging
    # ... steps
```

### Image Tagging Strategy
Current strategy: `YYYYMMDD-HHMMSS` + `latest`

Alternative strategies:
- Git commit SHA: `${{ github.sha }}`
- Git tag: `${{ github.ref_name }}`
- Semantic versioning: `v1.0.0`

Update in workflow:
```yaml
- name: Build and push image
  run: |
    IMAGE_TAG=${{ github.sha }}
    # ... rest of the command
```

## 🔐 Security Considerations

1. **Service Principal Permissions**
   - Use least privilege principle
   - Scope to specific resource group
   - Rotate credentials regularly

2. **Secrets Management**
   - Never commit secrets to Git
   - Use GitHub encrypted secrets
   - Consider Azure Key Vault for production

3. **Image Scanning**
   Add security scanning:
   ```yaml
   - name: Scan image for vulnerabilities
     uses: azure/container-scan@v0
     with:
       image-name: ${{ env.ACR_NAME }}.azurecr.io/${{ env.IMAGE_NAME }}:latest
   ```

## 🧪 Testing Before Deployment

Add testing step before deployment:

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.13'
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install pytest
      - name: Run tests
        run: pytest

  deploy:
    needs: test
    runs-on: ubuntu-latest
    # ... deployment steps
```

## 📝 Troubleshooting

### Authentication Failed
- Verify `AZURE_CREDENTIALS` secret is set correctly
- Check service principal has correct permissions
- Ensure service principal is not expired

### ACR Not Found
- Verify `ACR_NAME` matches your deployed ACR
- Check service principal has access to ACR

### Container App Update Failed
- Check container app names match
- Verify resource group name is correct
- Check Azure Portal for more details

### Deployment Timeout
- Increase timeout in workflow (default: 360 minutes)
```yaml
jobs:
  build-and-deploy:
    timeout-minutes: 60
```

## 🔄 Rollback

To rollback to a previous version:

1. Find the previous image tag in ACR
2. Manually update container apps:
```bash
az containerapp update \
  --name fastapi-app \
  --resource-group async-fastapi-rg \
  --image asyncfastapiacr.azurecr.io/async-fastapi:PREVIOUS_TAG
```

Or use GitHub Actions:
1. Go to Actions tab
2. Find successful deployment
3. Click "Re-run all jobs"

## 📊 Monitoring

### Deployment Notifications
Add Slack/Teams/Email notifications:

```yaml
- name: Notify deployment success
  if: success()
  uses: 8398a7/action-slack@v3
  with:
    status: success
    text: 'Deployment successful!'
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}

- name: Notify deployment failure
  if: failure()
  uses: 8398a7/action-slack@v3
  with:
    status: failure
    text: 'Deployment failed!'
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

## 🎉 You're All Set!

Your CI/CD pipeline is now configured. Every push to `main` will automatically deploy to Azure!

**Next steps:**
1. Make a code change
2. Commit and push to `main`
3. Watch the magic happen in Actions tab
4. Access your updated application

For more advanced scenarios, see [GitHub Actions documentation](https://docs.github.com/en/actions).

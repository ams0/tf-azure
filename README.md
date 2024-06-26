# tf-azure
A sample repo to deploy stuff in azure via github actions


1. Create a Github Action secret `AZURE_CREDENTIALS` with the json output of the command:

```bash
az ad sp create-for-rbac --role Contributor --scopes /subscriptions/<sub-id> -o json
```

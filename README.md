# tf-azure
A sample repo to deploy stuff in azure via github actions


1. Create a Github Action secret `AZURE_CREDENTIALS` modiyfing the json output of the command:

```bash
az ad sp create-for-rbac --role Contributor --scopes /subscriptions/<sub-id> -o json
```

to look like ([source](https://github.com/azure/login)):

```bash
{
    "clientSecret":  "******",
    "subscriptionId":  "******",
    "tenantId":  "******",
    "clientId":  "******"
}
```

you can retrieve the subscription id from the portal or using `az account show` command.

2. State store

We're using an S3 (or compatible ) storage to store the state between runs. Using Minio, you can generate and download credentials, and add it as `S3_CREDENTIALS` to GitHub as repository secret. The format is:

```bash
{"url":"https://s3.example.io/api/v1/service-account-credentials","accessKey":"xxxxx","secretKey":"xxxx","api":"s3v4","path":"auto"}
```




# Perseo

## Contents

<details>
<summary><strong>Details</strong></summary>

-   [Sanity check for Perseo](#sanity-check-for-perseo)
-   [Related information](#related-information)

</details>

## Sanity check for Perseo

Once Perseo is running, you can check the status by the following command:

#### Request:

```bash
ngsi version --host perseo.local --pretty
```

#### Response:

```json
{
  "error": null,
  "data": {
    "name": "perseo",
    "description": "IOT CEP front End",
    "version": "1.27.0"
  }
}
```

## Related information

-   [Perseo Context-Aware CEP - GitHub](https://github.com/telefonicaid/perseo-fe)
-   [Perseo-core (EPL server) - GitHub](https://github.com/telefonicaid/perseo-core)
-   [NGSI Go tutorial for Perseo](https://ngsi-go.letsfiware.jp/tutorial/perseo/)
-   [telefonicaiot/perseo-fe - Docker Hub](https://hub.docker.com/r/telefonicaiot/perseo-fe)
-   [telefonicaiot/perseo-core - Docker Hub](https://hub.docker.com/r/telefonicaiot/perseo-core)

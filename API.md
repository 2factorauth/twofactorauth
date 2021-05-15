# API usage
## Introduction

The data collected for the 2fa.directory website is also available as JSON files in order to enable developers to use it in their own programs. It is recommended to use the API with the highest version number, since older versions might not include all available information.

### URL & Domain matching

If you're using our API to match client URLs with our dataset make sure you only use the domain of the `url`-element, as a website commonly uses subdomains and subdirectories. Please note that there are exceptions like `.co.uk`, `.com.au` or `.co.nz` where the actual domain is found at a lower level.

### Caching

If you intend to query our JSON files often and with a lot of traffic, you may be blocked by Cloudflare, our reverse proxy provider. We therefore recommend that you cache the files locally for any large traffic cases.

### Avoid downloading unnecessary data

If you only intent on using a specific dataset, like all sites supporting RFC-6238, we recommend that you use the URI which lists just that. See [URIs](#uris-1) for a list of available paths. The smaller the better.

## Version 2

### URIs

|Coverage|Unsigned file|Signed file|
|--------|-------------|-----------|
|All sites|https://2fa.directory/api/v2/all.json|https://2fa.directory/api/v2/all.json.sig|
|All 2FA-supporting sites|https://2fa.directory/api/v2/tfa.json|https://2fa.directory/api/v2/tfa.json.sig|
|SMS|https://2fa.directory/api/v2/sms.json|https://2fa.directory/api/v2/sms.json.sig|
|Phone calls|https://2fa.directory/api/v2/phone.json|https://2fa.directory/api/v2/phone.json.sig|
|Email 2FA|https://2fa.directory/api/v2/email.json|https://2fa.directory/api/v2/email.json.sig|
|non-U2F hardware 2FA tokens|https://2fa.directory/api/v2/hardware.json|https://2fa.directory/api/v2/hardware.json.sig|
|U2F hardware tokens|https://2fa.directory/api/v2/u2f.json|https://2fa.directory/api/v2/u2f.json.sig|
|RFC-6238|https://2fa.directory/api/v2/totp.json|https://2fa.directory/api/v2/totp.json.sig|
|non-RFC-6238 software 2FA|https://2fa.directory/api/v2/proprietary.json|https://2fa.directory/api/v2/proprietary.json.sig|


### Elements

|Key|Value|Always defined|Description|
|---|-----|---------------|-----------|
|url|URL|:heavy_check_mark:|URL to the main page of the site/service|
|img|String|:heavy_check_mark:|Image name used|
|tfa|Array\<String>||Array containing all supported 2FA methods|
|doc|URL||URL to documentation page|
|exception|String||Text describing any discrepancies in the 2FA implementation|
|twitter|String||Twitter handle|
|facebook|String||Facebook page name|
|email_address|String||Email address to support|

### Example website with 2FA enabled

```JSON
{
  "Category name": {
    "Website name": {
      "url": "https://example.com/",
      "img": "example.png",
      "tfa": [
        "sms",
        "phone",
        "hardware",
        "totp",
        "proprietary",
        "u2f"
      ],
      "doc": "https://example.com/documention/enable-2fa/",
      "exception": "Text describing any discrepancies in the 2FA implementation."
    }
  }
}
```

### Example website with 2FA disabled

```JSON
{
  "Category name": {
    "Website name": {
      "url": "https://example.com/",
      "img": "example.png",
      "twitter": "example",
      "facebook": "example",
      "email_address": "email@example.com"
    }  
  }
}
```

## Version 1 (Deprecated) :warning:

### URIs

|Coverage|Unsigned file|Signed file|
|--------|-------------|-----------|
|All sites|https://2fa.directory/api/v1/data.json|https://2fa.directory/api/v1/data.json.sig|

### Elements

|Key|Value|Always defined|Description|
|---|-----|---------------|-----------|
|url|URL|:heavy_check_mark:|URL to the main page of the site/service|
|img|String|:heavy_check_mark:|Image name used|
|tfa|Boolean|:heavy_check_mark:|2FA support|
|sms|Boolean||SMS token support|
|phone|Boolean||Phone call support|
|email|Boolean||Email token support|
|software|Boolean||Software token support (including RFC-6238)|
|hardware|Boolean||Hardware token support (including U2F tokens)|
|doc|URL||URL to documentation page|
|exceptions|Object\<"text": String>||Object containing the key `text` describing any discrepancies in the 2FA implementation|
|twitter|String||Twitter handle|
|facebook|String||Facebook page name|
|email_address|String||Email address to support|

### Example website with 2FA disabled

```JSON
{
  "Category name": {
    "Website name": {
      "name": "Website name",
      "url": "https://example.com/",
      "img": "example.png",
      "tfa": false
    }   
  }
}
```

### Example website with 2FA enabled

```JSON
{
  "Category name": {
    "Website name": {
      "name": "Website name",
      "url": "https://example.com/",
      "img": "example.png",
      "tfa": true,
      "sms": true,
      "phone": true,
      "email": true,
      "software": true,
      "hardware": true,
      "doc": "https://example.com/documention/enable-2fa/",
      "exceptions": {
        "text": "Text describing any discrepancies in the 2FA implementation."
      }
    }   
  }
}
```

If a website only supports some 2FA methods, the unsupported 2FA methods won't be listed (i.e. NULL).

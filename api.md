# API usage
## Introduction

The data collected for the 2fa.directory website is also available as JSON files in order to enable developers to use it in their own programs. It is recommended to use the API with the highest version number, since older versions might not include all available information.

### Caching

If you intend to query our JSON files often and with a lot of traffic, you may be blocked by Cloudflare, our reverse proxy provider. We therefore recommend that you cache the files locally for any large traffic cases.

### Avoid downloading unnecessary data

If you only intent on using a specific dataset, like all sites supporting RFC-6238, we recommend that you use the URI which lists just that. See [URIs](#uris) for a list of available paths. The smaller the better.

## Version 3

### URIs

|Coverage|Unsigned file|Signed file|
|--------|-------------|-----------|
|All sites|https://2fa.directory/api/v3/all.json|https://2fa.directory/api/v3/all.json.sig|
|All 2FA-supporting sites|https://2fa.directory/api/v3/tfa.json|https://2fa.directory/api/v3/tfa.json.sig|
|SMS|https://2fa.directory/api/v3/sms.json|https://2fa.directory/api/v3/sms.json.sig|
|Phone calls|https://2fa.directory/api/v3/call.json|https://2fa.directory/api/v3/call.json.sig|
|Email 2FA|https://2fa.directory/api/v3/email.json|https://2fa.directory/api/v3/email.json.sig|
|non-U2F hardware 2FA tokens|https://2fa.directory/api/v3/custom-hardware.json|https://2fa.directory/api/v3/custom-hardware.json.sig|
|U2F hardware tokens|https://2fa.directory/api/v3/u2f.json|https://2fa.directory/api/v3/u2f.json.sig|
|RFC-6238 (TOTP)|https://2fa.directory/api/v3/totp.json|https://2fa.directory/api/v3/totp.json.sig|
|non-RFC-6238 software 2FA|https://2fa.directory/api/v3/custom-software.json|https://2fa.directory/api/v3/custom-software.json.sig|


### Elements

|Key|Value|Always defined|Description|
|---|-----|---------------|-----------|
|domain|hostname|:heavy_check_mark:|The domain name of the service|
|img|String||Image name used. If this is not defined, the image name is `domain`.svg|
|url|URL||URL of the site. If this is not defined, the url is https://`domain`|
|tfa|Array\<String>||Array containing all supported 2FA methods|
|documentation|URL||URL to documentation page|
|recovery|URL||URL to recovery documentation page|
|notes|String||Text describing any discrepancies in the 2FA implementation|
|contact|Object||Object containing contact details. See table below for elements|
|regions|array\<String>||Array containing ISO 3166-1 country codes of the regions in which the site is available|
|additional-domains|Array\<hostname>||Array of domains that the site exists at in addition to the main domain listed in the `domain` field.|
|custom-(software\|hardware)|Array\<String>||Array of custom software/hardware methods that the site supports. Only present if the `tfa` element contains one of these 2FA types|
|keywords|Array\<String>|:heavy_check_mark:|Array of categories to which the site belongs|

#### Contact Object Elements
|Key|Value|Always defined|Description|
|---|-----|---------------|-----------|
|twitter|String||Twitter handle|
|facebook|String||Facebook page name|
|email|String||Email address to support|
|language|String||Lowercase ISO 639-1 language code for the site if it is not in English|

### Example website with 2FA enabled

```JSON
[
  [
    "Site Name",
    {
      "domain": "example.com",
      "additional-domains": [
        "example.net"
      ],
      "tfa": [
        "sms",
        "call",
        "email",
        "totp",
        "u2f",
        "custom-software",
        "custom-hardware"
      ],
      "custom-software": [
        "Authy"
      ],
      "documentation": "<link to site TFA documentation>",
      "recovery": "<link to site TFA recovery documentation>",
      "keywords": [
        "keyword1",
        "keyword2"
      ]
    }
  ]
]
```

### Example website with 2FA disabled

```JSON
[
  [
    "Site Name", 
    {
      "domain": "example.com",
      "contact": {
        "twitter": "example",
        "facebook": "example",
        "email": "example@example.com"
      },
      "keywords": [
        "keyword1",
        "keyword2"
      ]
    }
  ]
]
```

## Version 2 (Deprecated) :warning:

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
|RFC-6238 (TOTP)|https://2fa.directory/api/v2/totp.json|https://2fa.directory/api/v2/totp.json.sig|
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

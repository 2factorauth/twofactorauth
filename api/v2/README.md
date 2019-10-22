# API v2 layout

## Example website with 2FA enabled:
```JSON
{
  "Category name": {
    "Example Website": {
      "name": "Example Website",
      "url": "https://example.com/",
      "img": "example.png",
      "tfa": [
        "sms",
        "phone",
        "software",
        "hardware",
        "totp",
        "proprietary",
        "u2f"
      ],
      "doc": "https://example.com/doc/2fa-documentation"
    }  
  }
}
```
Mandatory tags for websites with 2fa are:
- name
- url
- img
- tfa (Array containing any or all of the above strings)

Optional tags for websites with 2fa are:
- doc
- exception (either as a Boolean or map containing `text` key with string value)


## Example website with 2FA disabled:
```JSON
{
  "Category name": {
    "Example Website": {
      "name": "Example Website",
      "url": "https://example.com/",
      "img": "example.png",
      "twitter": "example",
      "facebook": "example",
      "email_address": "email@example.com"
    }  
  }
}
```
Mandatory tags for websites without 2fa are:
- name
- url
- img

Optional tags for websites without 2fa are:
- twitter
- facebook
- email_address
- status (url to status page)

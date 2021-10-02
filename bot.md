# 2FactorAuth Web bots

In order to validate user contributions we use scripts or "bots".  
These scripts only make requests to your website when someone tries to edit data about your site on 2fa.directory.   
As a result you will most likely only receive a couple of requests each year. We would be very thankful if you didn't block these HTTP requests.

## User agents:

|User-Agent|Script source|
|----------|-------------|
|2FactorAuth/URLValidator|/tests/validate-urls.rb|
|2FactorAuth/LanguageValidator|/tests/language-codes.rb|
|2FactorAuth/RegionValidator|/tests/region-codes.rb|
|2FactorAuth/FacebookValidator|/tests/facebook.rb|

## robots.txt

Since each script only makes one request per website, the same number as if we would have fetched any robots.txt file, we have opted to not comply with robots.txt files.

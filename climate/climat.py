import sys
#import re
#import matplotlib.pyplot as plt
import urllib2
import json

def eprint(message):
    sys.stderr.write(message + "\n")

countryUrl = "http://www.worldweather.org/en/json/Country_en.xml"
cityUrlTemplate = "http://www.worldweather.org/en/json/{}_en.xml"

countryDataRaw = '{}'
if len(sys.argv) > 1:
    countryFile = open(sys.argv[1], 'r')
    eprint("Getting cities list from FILE {}...".format(sys.argv[1]))
    countryDataRaw = countryFile.read()
else:
    eprint("Getting cities list from URL {}...".format(countryUrl))
    countryRequest = urllib2.urlopen(countryUrl)
    countryDataRaw = countryRequest.read()

eprint("Data received")
countryData = json.loads(countryDataRaw)

countryKeys = countryData["member"].keys();
eprint( "Got {} countries to process".format(len(countryKeys)) )
counter = 0
for countryId in sorted(countryKeys):
    counter += 1
    currentCountry = countryData["member"][countryId]
    if type(currentCountry) is not dict:
        eprint("{} IS NOT A DICTIONARY, moving on.".format(countryId))
        continue
    #if int(counter) > 2:
    #    break

    eprint("Processing country {} ({})...".format(countryId, currentCountry['memName']))
    for cityRecord in currentCountry['city']:
        cityUrl = cityUrlTemplate.format(cityRecord['cityId'])
        eprint("Getting data for city {} from {}".format(cityRecord['cityName'], cityUrl))
        cityRequest = ''
        cityRecord['climate'] = {}
        cityRecord['forecast'] = {}
        try:
            cityRequest = urllib2.urlopen(cityUrl)
        except urllib2.URLError as e:
            eprint("Call failed ({})!".format(e.reason))
            continue
        cityDataRaw = cityRequest.read()
        eprint("Climate data retrieved")
        cityData = json.loads(cityDataRaw)
        cityRecord['climate'] = cityData['city']['climate']
        cityRecord['forecast'] = cityData['city']['forecast']

print json.dumps(countryData, sort_keys=True, indent=4)
